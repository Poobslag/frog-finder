extends Node

export (NodePath) var _main_menu_panel_path: NodePath
export (NodePath) var _gameplay_panel_path: NodePath
export (NodePath) var _intermission_panel_path: NodePath
export (NodePath) var _hand_path: NodePath
export (NodePath) var _background_path: NodePath
export (NodePath) var _music_player_path: NodePath
export (NodePath) var _player_data_path: NodePath

onready var _main_menu_panel: MainMenuPanel = get_node(_main_menu_panel_path)
onready var _gameplay_panel: GameplayPanel = get_node(_gameplay_panel_path)
onready var _intermission_panel: IntermissionPanel = get_node(_intermission_panel_path)
onready var _hand: Hand = get_node(_hand_path)
onready var _background: Background = get_node(_background_path)
onready var _music_player: MusicPlayer = get_node(_music_player_path)
onready var _player_data: PlayerData = get_node(_player_data_path)

func _ready() -> void:
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_hide_panels()
	
	yield(get_tree(), "idle_frame")
	_main_menu_panel.show_menu()


func _hide_panels() -> void:
	_main_menu_panel.visible = false
	_gameplay_panel.visible = false
	_intermission_panel.visible = false


func _show_intermission_panel(card: CardControl) -> void:
	_hide_panels()
	_intermission_panel.add_level_result(card)
	_intermission_panel.show_intermission_panel()
	if card.card_front_type == CardControl.CardType.SHARK:
		if _intermission_panel.is_full():
			# 10th shark; lose all our fingers (oh no!)
			_intermission_panel.start_shark_spawn_timer(_hand.fingers)
		else:
			# lose one finger
			_intermission_panel.start_shark_spawn_timer()
	else:
		# yay! we found a frog
		if _intermission_panel.is_full():
			# we won!
			_music_player.fade_out(4.0)
			yield(get_tree().create_timer(3.0), "timeout")
			if _music_player.music_preference != MusicPlayer.MusicPreference.OFF:
				_music_player.play_ending_song()
			if _player_data.hardest_difficulty_cleared < _gameplay_panel.game_difficulty:
				_player_data.hardest_difficulty_cleared = _gameplay_panel.game_difficulty
				_player_data.save_player_data()
			match _gameplay_panel.game_difficulty:
				GameplayPanel.GameDifficulty.HARD:
					_intermission_panel.start_frog_hug_timer(3, 30)
				GameplayPanel.GameDifficulty.MEDIUM:
					_intermission_panel.start_frog_hug_timer(2, 12)
				GameplayPanel.GameDifficulty.EASY, _:
					_intermission_panel.start_frog_hug_timer(1, 5)
		else:
			yield(get_tree().create_timer(3.0), "timeout")
			_end_intermission()


func _end_intermission() -> void:
	if _hand.fingers == 0:
		# we lose
		_hide_panels()
		_intermission_panel.reset() # free any sharks/frogs
		_player_data.save_player_data()
		_main_menu_panel.show_menu()
	elif _intermission_panel.is_full():
		# we win
		_hide_panels()
		_intermission_panel.reset() # free any sharks/frogs
		_player_data.save_player_data()
		_main_menu_panel.show_menu()
	else:
		_hide_panels()
		_background.change()
		_gameplay_panel.show_puzzle()


func _on_MainMenuPanel_start_button_pressed(difficulty: int) -> void:
	# save, in case the user changed their music preference
	_player_data.save_player_data()
	
	# we just beat the game (or lost to sharks); start a new song
	if not _music_player.is_playing_frog_song() \
			and _music_player.music_preference != MusicPlayer.MusicPreference.OFF:
		_music_player.play_preferred_song()
	
	_hide_panels()
	_hand.reset()
	_intermission_panel.restart(difficulty)
	_gameplay_panel.restart(difficulty)
	_gameplay_panel.show_puzzle()


func _on_GameplayPanel_before_shark_found(_card: CardControl) -> void:
	if _music_player.is_playing_frog_song():
		_music_player.play_shark_song()


func _on_GameplayPanel_before_frog_found(_card: CardControl) -> void:
	if _music_player.is_playing_shark_song():
		# we don't play a shark song if there's no current song (music is off)
		_music_player.play_preferred_song()


func _on_GameplayPanel_shark_found(card: CardControl) -> void:
	_player_data.shark_count += 1
	_show_intermission_panel(card)


func _on_GameplayPanel_frog_found(card: CardControl) -> void:
	_player_data.frog_count += 1
	_show_intermission_panel(card)


func _on_Hand_finger_bitten() -> void:
	if _hand.biteable_fingers == 0:
		yield(get_tree().create_timer(4.0), "timeout")
		_hand.biteable_fingers = -1
		_end_intermission()


func _on_MainMenuPanel_frog_found(_card: CardControl) -> void:
	_player_data.frog_count += 1


func _on_MainMenuPanel_shark_found(_card: CardControl) -> void:
	_player_data.shark_count += 1


func _on_MainMenuPanel_before_shark_found(_card: CardControl) -> void:
	if _music_player.is_playing_frog_song():
		# we don't play a shark song if there's no current song (music is off)
		_music_player.play_shark_song()


func _on_MainMenuPanel_before_frog_found(_card: CardControl) -> void:
	if _music_player.is_playing_shark_song():
		_music_player.play_preferred_song()


func _on_IntermissionPanel_bye_button_pressed() -> void:
	_end_intermission()

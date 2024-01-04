extends Node
## Tracks which panel should be shown: The main menu panel, gameplay panel, or intermission panel.

@export var main_menu_panel: MainMenuPanel
@export var gameplay_panel: GameplayPanel
@export var intermission_panel: IntermissionPanel
@export var hand: Hand
@export var background: Background

## Holds all temporary timers. These timers are not created by get_tree().create_timer() because we need to clean them
## up if the game is interrupted. Otherwise for example, we might schedule an intermission to appear 3 seconds from
## now, but then the player quits to the main menu and the intermission appears anyway.
@onready var _timers := $Timers

func _ready() -> void:
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_hide_panels()
	
	await get_tree().process_frame
	main_menu_panel.show_menu()
	
	MusicPlayer.play_preferred_song()
	PlayerData.music_preference_changed.connect(_on_player_data_music_preference_changed)
	PlayerData.world_index_changed.connect(_on_player_data_world_index_changed)


func _hide_panels() -> void:
	main_menu_panel.visible = false
	gameplay_panel.visible = false
	intermission_panel.visible = false


func _show_intermission_panel(card: CardControl) -> void:
	_hide_panels()
	intermission_panel.add_level_result(card)
	intermission_panel.show_intermission_panel()
	if card.card_front_type == CardControl.CardType.SHARK:
		if intermission_panel.is_full():
			# 10th shark; lose all our fingers (oh no!)
			intermission_panel.start_shark_spawn_timer(hand.fingers)
		else:
			# lose one finger
			intermission_panel.start_shark_spawn_timer()
	else:
		# yay! we found a frog
		if intermission_panel.is_full():
			_play_ending()
		else:
			_start_timer(3.0).timeout.connect(_on_timer_timeout_end_intermission)


## Creates and starts a one-shot timer.
##
## This timer is freed when it times out or when the level is interrupted.
##
## Parameters:
## 	'wait_time': The amount of time to wait. A value of '0.0' will result in an error.
##
## Returns:
## 	A timer which has been added to the scene tree, and is currently active.
func _start_timer(wait_time: float) -> Timer:
	var timer := _add_timer(wait_time)
	timer.start()
	return timer


## Creates a one-shot timer, but does not start it.
##
## This timer is freed when it times out or when the level is interrupted.
##
## Parameters:
## 	'wait_time': The amount of time to wait. A value of '0.0' will result in an error.
##
## Returns:
## 	A timer which has been added to the scene tree, but is not yet active.
func _add_timer(wait_time: float) -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = wait_time
	timer.timeout.connect(_on_timer_timeout_queue_free.bind(timer))
	_timers.add_child(timer)
	return timer


func _end_intermission() -> void:
	if hand.fingers == 0:
		# we lose; return to the main menu
		_hide_panels()
		hand.reset_fingers() # restore any bitten fingers
		intermission_panel.reset() # free any sharks/frogs
		PlayerData.set_mission_cleared(gameplay_panel.mission_string, PlayerData.MissionResult.SHARK)
		PlayerData.save_player_data()
		main_menu_panel.show_menu()
	elif intermission_panel.is_full():
		# we win; return to the main menu
		_hide_panels()
		hand.reset_fingers() # restore any bitten fingers
		intermission_panel.reset() # free any sharks/frogs
		PlayerData.set_mission_cleared(gameplay_panel.mission_string, PlayerData.MissionResult.FROG)
		PlayerData.save_player_data()
		main_menu_panel.show_menu()
	else:
		# restore the hand to an index finger
		hand.biteable_fingers = -1
		
		# show the next puzzle
		_hide_panels()
		background.change()
		gameplay_panel.show_puzzle()


func _play_ending() -> void:
	# we won!
	match gameplay_panel.mission_string:
		"1-1", "2-1", "3-1":
			intermission_panel.start_frog_ribbon()
		"1-2", "2-2", "3-2":
			var dancer_count := FrogArrangements.get_dancer_count(PlayerData.frog_dance_count)
			intermission_panel.start_frog_dance(dancer_count)
			PlayerData.frog_dance_count += 1
		"1-3":
			_schedule_frog_hug_ending(1, 5)
		"2-3":
			_schedule_frog_hug_ending(2, 12)
		"3-3":
			_schedule_frog_hug_ending(3, 30)
		_:
			_schedule_frog_hug_ending(1, 5)


## After a delay, spawns frogs which hug the cursor.
func _schedule_frog_hug_ending(huggable_fingers: int, new_max_frogs: int) -> void:
	MusicPlayer.fade_out(4.0)
	_start_timer(3.0).timeout.connect(_on_timer_timeout_play_frog_hug_ending.bind(huggable_fingers, new_max_frogs))


## Spawns frogs which hug the cursor.
func _on_timer_timeout_play_frog_hug_ending(huggable_fingers: int, new_max_frogs: int) -> void:
	if PlayerData.music_preference != PlayerData.MusicPreference.OFF:
		MusicPlayer.play_ending_song()
	intermission_panel.start_frog_hug_timer(huggable_fingers, new_max_frogs)


func _on_main_menu_panel_start_pressed(mission_string: String) -> void:
	# save, in case the user changed their music preference
	PlayerData.save_player_data()
	
	# we just beat the game (or lost to sharks); start a new song
	if not MusicPlayer.is_playing_frog_song() \
			and PlayerData.music_preference != PlayerData.MusicPreference.OFF:
		MusicPlayer.play_preferred_song()
	
	_hide_panels()
	hand.reset_fingers()
	intermission_panel.restart(mission_string)
	gameplay_panel.restart(mission_string)
	gameplay_panel.show_puzzle()


func _on_gameplay_panel_before_shark_found(_card: CardControl) -> void:
	if MusicPlayer.is_playing_frog_song() or MusicPlayer.is_playing_ending_song():
		MusicPlayer.play_shark_song()


func _on_gameplay_panel_before_frog_found(_card: CardControl) -> void:
	if MusicPlayer.is_playing_shark_song():
		MusicPlayer.play_preferred_song()


func _on_gameplay_panel_shark_found(card: CardControl) -> void:
	PlayerData.shark_count += 1
	_show_intermission_panel(card)


func _on_gameplay_panel_frog_found(card: CardControl) -> void:
	PlayerData.frog_count += 1
	_show_intermission_panel(card)


func _on_hand_finger_bitten() -> void:
	if hand.biteable_fingers == 0:
		_start_timer(4.0).timeout.connect(_on_timer_timeout_end_intermission)


func _on_main_menu_panel_frog_found(_card: CardControl) -> void:
	PlayerData.frog_count += 1


func _on_main_menu_panel_shark_found(_card: CardControl) -> void:
	PlayerData.shark_count += 1


func _on_main_menu_panel_before_shark_found(_card: CardControl) -> void:
	if MusicPlayer.is_playing_frog_song():
		# we don't play a shark song if there's no current song (music is off)
		MusicPlayer.play_shark_song()


func _on_main_menu_panel_before_frog_found(_card: CardControl) -> void:
	if MusicPlayer.is_playing_shark_song():
		MusicPlayer.play_preferred_song()


func _on_intermission_panel_bye_pressed() -> void:
	_end_intermission()


func _on_timer_timeout_queue_free(timer: Timer) -> void:
	timer.queue_free()


func _on_timer_timeout_end_intermission() -> void:
	_end_intermission()


func _on_cheat_code_detector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	match cheat:
		"onefrog":
			if main_menu_panel.visible:
				CardArrangements.one_frog_cheat = !CardArrangements.one_frog_cheat
				detector.play_cheat_sound(CardArrangements.one_frog_cheat)


func _on_player_data_music_preference_changed() -> void:
	MusicPlayer.play_preferred_song()


func _on_player_data_world_index_changed() -> void:
	MusicPlayer.play_preferred_song()

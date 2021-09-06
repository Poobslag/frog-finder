class_name MainMenuPanel
extends Panel

signal start_button_pressed(difficulty)
signal before_frog_found
signal frog_found
signal before_shark_found
signal shark_found

export (NodePath) var player_data_path: NodePath

onready var _game_state := $TitleGameState
onready var _player_data: PlayerData = get_node(player_data_path)

func _on_StartButton_button_pressed(difficulty: int) -> void:
	emit_signal("start_button_pressed", difficulty)


func _ready() -> void:
	$Card1F.show_front()
	$Card1R.show_front()
	$Card1O.connect("before_frog_found", self, "_on_CardControl_before_frog_found")
	$Card1O.connect("frog_found", self, "_on_CardControl_frog_found")
	$Card1O.connect("before_shark_found", self, "_on_CardControl_before_shark_found")
	$Card1O.connect("shark_found", self, "_on_CardControl_shark_found")
	$Card1G.show_front()
	$Card2F.show_front()
	$Card2I.connect("before_frog_found", self, "_on_CardControl_before_frog_found")
	$Card2I.connect("frog_found", self, "_on_CardControl_frog_found")
	$Card2I.connect("before_shark_found", self, "_on_CardControl_before_shark_found")
	$Card2I.connect("shark_found", self, "_on_CardControl_shark_found")
	$Card2N.show_front()
	$Card2D.show_front()
	$Card2E.show_front()
	$Card2R.show_front()


func show_menu() -> void:
	visible = true
	_game_state.reset()
	$Card1O.reset()
	$Card2I.reset()
	
	$Card1O.card_front_type = CardControl.CardType.SHARK if randf() < 0.15 else CardControl.CardType.FROG
	$Card2I.card_front_type = CardControl.CardType.SHARK if randf() < 0.15 else CardControl.CardType.FROG
	
	$EasyButtons.visible = false
	$MediumButtons.visible = false
	$HardButtons.visible = false
	match _player_data.hardest_difficulty_cleared:
		GameplayPanel.GameDifficulty.EASY:
			$MediumButtons.visible = true
		GameplayPanel.GameDifficulty.MEDIUM, GameplayPanel.GameDifficulty.HARD:
			$HardButtons.visible = true
		_: $EasyButtons.visible = true


func _on_MusicPlayer_music_preference_changed() -> void:
	$MusicControl.refresh_sprite()


func _on_CardControl_before_frog_found() -> void:
	emit_signal("before_frog_found")


func _on_CardControl_before_shark_found() -> void:
	emit_signal("before_shark_found")


func _on_CardControl_frog_found() -> void:
	emit_signal("frog_found")


func _on_CardControl_shark_found() -> void:
	emit_signal("shark_found")

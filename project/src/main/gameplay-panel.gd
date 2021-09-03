extends Panel

signal player_lost
signal player_won

onready var _game_state := $GameState

func show_puzzle() -> void:
	visible = true
	_game_state.reset()
	$CardControl0.reset()
	$CardControl1.reset()


func _on_FrogButton_pressed() -> void:
	emit_signal("player_won")


func _on_SharkButton_pressed() -> void:
	emit_signal("player_lost")


func _on_CardControl_frog_found() -> void:
	emit_signal("player_won")


func _on_CardControl_shark_found() -> void:
	emit_signal("player_lost")

extends Panel

signal player_lost
signal player_won

func show_puzzle() -> void:
	visible = true


func _on_FrogButton_pressed() -> void:
	emit_signal("player_won")


func _on_SharkButton_pressed() -> void:
	emit_signal("player_lost")

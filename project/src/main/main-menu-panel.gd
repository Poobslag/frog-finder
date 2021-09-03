extends Panel

signal start_button_pressed

func _on_StartButton_pressed() -> void:
	emit_signal("start_button_pressed")

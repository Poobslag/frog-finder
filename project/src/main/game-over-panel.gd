extends Panel

signal start_button_pressed

onready var _label: Label = $Label

func show_player_won() -> void:
	_label.text = "You win!"
	visible = true


func show_player_lost() -> void:
	_label.text = "You lose..."
	visible = true


func _on_StartButton_pressed() -> void:
	emit_signal("start_button_pressed")

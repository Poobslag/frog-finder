class_name BackgroundDemoPickerRow
extends HBoxContainer
## A picker row for the BackgroundDemo which lets the player choose or randomize a color.

signal go_button_pressed(color: Color)
signal color_picked(color: Color)
signal shuffle_button_pressed

var color: Color:
	set(new_color):
		%ColorPickerButton.color = new_color
	get:
		return %ColorPickerButton.color


func _on_color_picker_button_popup_closed() -> void:
	color_picked.emit(%ColorPickerButton.color)


func _on_go_button_pressed() -> void:
	go_button_pressed.emit(%ColorPickerButton.color)


func _on_shuffle_button_pressed() -> void:
	shuffle_button_pressed.emit()

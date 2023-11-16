class_name BackgroundDemoPickerRow
extends HBoxContainer
## A picker row for the BackgroundDemo which lets the player choose or randomize a color.

signal go_button_pressed(color: Color)
signal color_picked(color: Color)
signal shuffle_button_pressed

var color: Color : set = set_color, get = get_color

@onready var _color_picker_button := $ColorPickerButton

func set_color(new_color: Color) -> void:
	_color_picker_button.color = new_color


func get_color() -> Color:
	return _color_picker_button.color


func _on_color_picker_button_popup_closed() -> void:
	color_picked.emit(_color_picker_button.color)


func _on_go_button_pressed() -> void:
	go_button_pressed.emit(_color_picker_button.color)


func _on_shuffle_button_pressed() -> void:
	shuffle_button_pressed.emit()

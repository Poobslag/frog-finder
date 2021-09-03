extends Control


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		rect_position = event.position

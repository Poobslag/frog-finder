extends Node
## Demonstrates the background.
##
## Keys:
## 	[B]: Cycle the background
## 	[Shift + B]: Cycle the background immediately, with no transition

@onready var _background: Background = $Background

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_B:
			_background.change(true if Input.is_key_pressed(KEY_SHIFT) else false)

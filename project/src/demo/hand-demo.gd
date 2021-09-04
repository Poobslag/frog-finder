extends Node

onready var _hand: Hand = $Hand

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _input(event: InputEvent) -> void:
	match key_scancode(event):
		KEY_B:
			_hand.set_biteable_fingers(1)
			_hand.bite()
		KEY_MINUS:
			_hand.set_biteable_fingers(clamp(_hand.biteable_fingers - 1, -1, 3))
		KEY_EQUAL:
			_hand.set_biteable_fingers(clamp(_hand.biteable_fingers + 1, -1, 3))
		KEY_3:
			_hand.set_fingers(3)


"""
Returns the scancode for a keypress event, or -1 if the event is not a keypress event.
"""
static func key_scancode(event: InputEvent) -> int:
	var scancode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	return scancode

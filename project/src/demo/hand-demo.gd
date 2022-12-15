extends Node
## Demonstrates the hand sprite.
##
## Keys:
## 	[B]: Bite a finger
## 	[3]: Restore all three fingers
## 	[=/-]: Change the number of biteable fingers
## 	[brace right]: Maximize the number of huggable fingers
## 	[brace left]: Minimize the number of huggable fingers

onready var _hand: Hand = $Hand

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_B:
			_hand.set_biteable_fingers(1)
			_hand.bite()
		KEY_MINUS:
			_hand.set_biteable_fingers(clamp(_hand.biteable_fingers - 1, -1, 3))
		KEY_EQUAL:
			_hand.set_biteable_fingers(clamp(_hand.biteable_fingers + 1, -1, 3))
		KEY_3:
			_hand.set_fingers(3)
		KEY_BRACKETRIGHT:
			_hand.huggable_fingers = 3
			_hand.hug()
		KEY_BRACKETLEFT:
			_hand.huggable_fingers = 0
			_hand.hugged_fingers = 0

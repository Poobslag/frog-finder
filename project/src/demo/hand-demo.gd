extends Node
## Demonstrates the hand sprite.
##
## Keys:
## 	[B]: Bite a finger
## 	[R]: Toggle ribbon
## 	[3]: Restore all three fingers
## 	[=/-]: Change the number of biteable fingers
## 	[brace keys]: Change the number of hugged fingers

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_B:
			%Hand.biteable_fingers = 1
			%Hand.bite()
		KEY_R:
			%Hand.ribbon = !%Hand.ribbon
		KEY_3:
			%Hand.set_fingers(3)
		KEY_MINUS:
			%Hand.biteable_fingers = int(clamp(%Hand.biteable_fingers - 1, -1, 3))
		KEY_EQUAL:
			%Hand.biteable_fingers = int(clamp(%Hand.biteable_fingers + 1, -1, 3))
		KEY_BRACKETLEFT:
			%Hand.huggable_fingers = 0
			%Hand.hugged_fingers = 0
		KEY_BRACKETRIGHT:
			%Hand.huggable_fingers = 3
			%Hand.hug()

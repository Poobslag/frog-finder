class_name Hand
extends Control

signal finger_bitten

var fingers := 3 setget set_fingers
var biteable_fingers := -1 setget set_biteable_fingers

onready var _hand_sprite := $HandSprite

func _ready() -> void:
	_refresh_hand_sprite()


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		rect_position = event.position


func bite() -> void:
	if biteable_fingers <= 0:
		return
	
	biteable_fingers -= 1
	fingers -= 1
	_refresh_hand_sprite()
	# play an appropriate animation
	match(fingers):
		0: $FingerSprite0.bite(2)
		1: $FingerSprite1.bite(1)
		2: $FingerSprite2.bite(0)
	
	emit_signal("finger_bitten")


func set_fingers(new_fingers: int) -> void:
	fingers = new_fingers
	_refresh_hand_sprite()


func set_biteable_fingers(new_biteable_fingers: int) -> void:
	biteable_fingers = new_biteable_fingers
	_refresh_hand_sprite()


func _refresh_hand_sprite() -> void:
	if not is_inside_tree():
		return
	
	if biteable_fingers == -1:
		# no fingers can be eaten; just show the pointer, like a cursor
		_hand_sprite.set_state(HandSprite.State.ONE_FINGER)
	else:
		match fingers:
			3: _hand_sprite.set_state(HandSprite.State.THREE_FINGERS)
			2: _hand_sprite.set_state(HandSprite.State.TWO_FINGERS)
			1: _hand_sprite.set_state(HandSprite.State.ONE_FINGER)
			0: _hand_sprite.set_state(HandSprite.State.NO_FINGERS)

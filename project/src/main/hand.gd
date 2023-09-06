class_name Hand
extends Control
## Sprite2D which shows the player's cursor.
##
## The player's cursor is made up of a main hand sprite, as well as sometimes detached fingers, hearts or even frogs.

signal finger_bitten
signal hug_finished

var fingers := 3 : set = set_fingers

## Number of fingers remaining on the player's hand which can be bitten by sharks.
##
## If this number is 0 or greater, the player is in a chase and the hand shows the number of fingers remaining.
##
## If this number is -1, then the player is in a puzzle or on the main menu and the hand shows an index finger.
var biteable_fingers := -1 : set = set_biteable_fingers
var huggable_fingers := 0 : set = set_huggable_fingers
var hugged_fingers := 0
var resting := false

var _previous_rect_position: Vector2

@onready var _hand_sprite := $HandSprite
@onready var _hug_sprite := $HugSprite

func _ready() -> void:
	_refresh_hand_sprite()


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		position = event.position
		if hugged_fingers > 0:
			_finish_hug()


func reset() -> void:
	fingers = 3
	biteable_fingers = -1
	huggable_fingers = 0
	hugged_fingers = 0
	_refresh_hand_sprite()


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
	
	finger_bitten.emit()


func hug() -> void:
	if huggable_fingers <= 0:
		return
	
	hugged_fingers = int(clamp(hugged_fingers + 1, 0, 3))
	_refresh_hand_sprite()
	_hug_sprite.assign_wiggle_frame()
	
	match(hugged_fingers):
		1: $FingerSprite0.hug(0)
		2: $FingerSprite1.hug(2)
		3: $FingerSprite2.hug(1)


func set_fingers(new_fingers: int) -> void:
	fingers = new_fingers
	_refresh_hand_sprite()


func set_biteable_fingers(new_biteable_fingers: int) -> void:
	biteable_fingers = new_biteable_fingers
	_refresh_hand_sprite()


func set_huggable_fingers(new_huggable_fingers: int) -> void:
	huggable_fingers = new_huggable_fingers
	_refresh_hand_sprite()


func _finish_hug() -> void:
	hugged_fingers = 0
	_refresh_hand_sprite()
	_hug_sprite.assign_wiggle_frame()
	hug_finished.emit()


func _refresh_hand_sprite() -> void:
	if not is_inside_tree():
		return
	
	if huggable_fingers > 0:
		match hugged_fingers:
			0: _hug_sprite.wiggle_frames = [0] as Array[int]
			1: _hug_sprite.wiggle_frames = [1, 2] as Array[int]
			2: _hug_sprite.wiggle_frames = [3, 4] as Array[int]
			3: _hug_sprite.wiggle_frames = [5, 6] as Array[int]
	else:
		_hug_sprite.wiggle_frames = [] as Array[int]
		_hug_sprite.frame = 0
	
	if biteable_fingers >= 0:
		match fingers:
			3: _hand_sprite.set_state(HandSprite.State.THREE_FINGERS)
			2: _hand_sprite.set_state(HandSprite.State.TWO_FINGERS)
			1: _hand_sprite.set_state(HandSprite.State.ONE_FINGER)
			0: _hand_sprite.set_state(HandSprite.State.NO_FINGERS)
	else:
		# no fingers can be eaten/bitten; just show the pointer, like a cursor
		_hand_sprite.set_state(HandSprite.State.ONE_FINGER)


func _on_rest_timer_timeout() -> void:
	resting = true if _previous_rect_position == position else false
	_previous_rect_position = position

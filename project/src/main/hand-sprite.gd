class_name HandSprite
extends Sprite

enum State {
	NONE,
	THREE_FINGERS,
	TWO_FINGERS,
	ONE_FINGER,
	NO_FINGERS,
}

var state: int = State.ONE_FINGER setget set_state

var wiggle_frames := []

func _ready() -> void:
	_refresh_state()


func set_state(new_state: int) -> void:
	state = new_state
	_refresh_state()


func _refresh_state() -> void:
	if not is_inside_tree():
		return
	
	match state:
		State.NONE:
			wiggle_frames = [0]
		State.THREE_FINGERS:
			wiggle_frames = [1, 2]
		State.TWO_FINGERS:
			wiggle_frames = [3, 4]
		State.ONE_FINGER:
			wiggle_frames = [5, 6, 7, 8]
		State.NO_FINGERS:
			wiggle_frames = [9, 10]
	$WiggleTimer.assign_wiggle_frame()

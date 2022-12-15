extends Control
## A 'wow sprite' which is wide enough to surround multiple clickable icons at once.
##
## Clickable menu icons look like cards used in puzzles, but can be clicked while they are face-up. For this reason we
## surround them with a 'wow sprite' so that the player understands they are interactive.

## List of potential wiggle frame pairs corresponding to the left half of a 'wow sprite'
const ALL_LEFT_WIGGLE_FRAMES := [[0, 2], [4, 6], [8, 10], [12, 14]]

## List of potential wiggle frame pairs corresponding to the right half of a 'wow sprite'
const ALL_RIGHT_WIGGLE_FRAMES := [[1, 3], [5, 7], [9, 11], [13, 15]]

var _left_wiggle_frames := []
var _right_wiggle_frames := []

onready var _wiggle_timer := $WiggleTimer
onready var _left := $Left
onready var _right := $Right

func _ready() -> void:
	_left_wiggle_frames = Utils.rand_value(ALL_LEFT_WIGGLE_FRAMES)
	_right_wiggle_frames = Utils.rand_value(ALL_RIGHT_WIGGLE_FRAMES)
	reset_wiggle()


func reset_wiggle() -> void:
	if not is_inside_tree():
		# avoid 'Timer was not added to the SceneTree' warnings
		return
	
	_wiggle_timer.start(rand_range(WiggleTimer.MIN_WIGGLE_TIME, WiggleTimer.MAX_WIGGLE_TIME))


## Updates the sprites' frames to the next 'wiggle frame'.
##
## Defaults to '0' if the current frame isn't a wiggle frame.
func assign_wiggle_frame() -> void:
	var wiggle_index:int = (_left_wiggle_frames.find(_left.frame) + 1) % _left_wiggle_frames.size()
	_left.frame = _left_wiggle_frames[wiggle_index]
	_right.frame = _right_wiggle_frames[wiggle_index]


func _on_WiggleTimer_timeout() -> void:
	assign_wiggle_frame()
	_wiggle_timer.wait_time = rand_range(WiggleTimer.MIN_WIGGLE_TIME, WiggleTimer.MAX_WIGGLE_TIME)

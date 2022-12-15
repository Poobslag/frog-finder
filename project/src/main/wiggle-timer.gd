class_name WiggleTimer
extends Timer
## A timer which alternates between two animation frames to give a squigglevision effect, emulating the effect of
## sketchily hand-drawn animation.

const MIN_WIGGLE_TIME := 0.35
const MAX_WIGGLE_TIME := 0.45

onready var _sprite := get_parent()

func _ready() -> void:
	reset_wiggle()


func reset_wiggle() -> void:
	if not is_inside_tree():
		# avoid 'Timer was not added to the SceneTree' warnings
		return
	
	start(rand_range(MIN_WIGGLE_TIME, MAX_WIGGLE_TIME))


## Updates the sprite's frame to the next 'wiggle frame'.
##
## Defaults to '0' if the current frame isn't a wiggle frame.
func assign_wiggle_frame() -> void:
	var wiggle_index:int = (_sprite.wiggle_frames.find(_sprite.frame) + 1) % _sprite.wiggle_frames.size()
	if _sprite.wiggle_frames[wiggle_index] >= _sprite.vframes * _sprite.hframes:
		push_warning("Invalid wiggle frame %s for %s" % [_sprite.wiggle_frames[wiggle_index], _sprite.get_path()])
	_sprite.frame = _sprite.wiggle_frames[wiggle_index]


func _on_timeout() -> void:
	if not "wiggle_frames" in _sprite or not _sprite.wiggle_frames:
		return
	
	assign_wiggle_frame()
	wait_time = rand_range(MIN_WIGGLE_TIME, MAX_WIGGLE_TIME)

extends Sprite

const MIN_WIGGLE_TIME := 0.35
const MAX_WIGGLE_TIME := 0.45

export (Array, int) var wiggle_frames := []

var _wiggle_index := 0

onready var _wiggle_timer := $WiggleTimer

func _on_WiggleTimer_timeout() -> void:
	if not wiggle_frames:
		return
	
	_wiggle_index = (_wiggle_index + 1) % wiggle_frames.size()
	frame = wiggle_frames[_wiggle_index]
	_wiggle_timer.wait_time = rand_range(MIN_WIGGLE_TIME, MAX_WIGGLE_TIME)

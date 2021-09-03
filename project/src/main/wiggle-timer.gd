extends Timer

const MIN_WIGGLE_TIME := 0.35
const MAX_WIGGLE_TIME := 0.45

var _wiggle_index := 0

onready var _sprite := get_parent()

func _ready() -> void:
	start(rand_range(0, MAX_WIGGLE_TIME))


func _on_timeout() -> void:
	if not "wiggle_frames" in _sprite or not _sprite.wiggle_frames:
		return
	
	_wiggle_index = (_wiggle_index + 1) % _sprite.wiggle_frames.size()
	_sprite.frame = _sprite.wiggle_frames[_wiggle_index]
	wait_time = rand_range(MIN_WIGGLE_TIME, MAX_WIGGLE_TIME)

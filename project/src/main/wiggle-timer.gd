extends Timer

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


func _on_timeout() -> void:
	if not "wiggle_frames" in _sprite or not _sprite.wiggle_frames:
		return
	
	# find the index of the next 'wiggle frame'; default to '0' if the current frame isn't a wiggle frame
	var wiggle_index :int = (_sprite.wiggle_frames.find(_sprite.frame) + 1) % _sprite.wiggle_frames.size()
	_sprite.frame = _sprite.wiggle_frames[wiggle_index]
	wait_time = rand_range(MIN_WIGGLE_TIME, MAX_WIGGLE_TIME)

extends Sprite

const WIGGLE_FRAMES_BY_BITTEN_FINGER := {
	0: [1, 2],
	1: [3, 4],
	2: [5, 6],
}

const WIGGLE_FRAMES_BY_HUGGED_FINGER := {
	0: [7, 8],
	1: [9, 10],
	2: [11, 12],
}

export (Array, int) var wiggle_frames := []

onready var _wiggle_timer := $WiggleTimer

onready var _hug_sounds := [
	preload("res://assets/main/sfx/frog-hug-0.wav"),
	preload("res://assets/main/sfx/frog-hug-1.wav"),
	preload("res://assets/main/sfx/frog-hug-2.wav"),
	preload("res://assets/main/sfx/frog-hug-3.wav"),
	preload("res://assets/main/sfx/frog-hug-4.wav"),
	preload("res://assets/main/sfx/frog-hug-5.wav"),
	preload("res://assets/main/sfx/frog-hug-6.wav"),
	preload("res://assets/main/sfx/frog-hug-7.wav"),
]

func _ready() -> void:
	$AnimationPlayer.play("reset")


"""
Parameters:
	'finger_index': 2 = pinky finger, 1 = naughty finger, 0 = pointer finger
"""
func bite(finger_index: int) -> void:
	wiggle_frames = WIGGLE_FRAMES_BY_BITTEN_FINGER[finger_index]
	_wiggle_timer.assign_wiggle_frame()
	
	# the animationplayer assigns the modulate/offset a frame too late.
	# we set them manually to avoid an ugly blink effect
	modulate = Color.white
	offset = Vector2(0, 0)
	$AnimationPlayer.play("bite")
	
	$CartoonBiteSfx.pitch_scale = rand_range(0.95, 1.01)
	$CartoonBiteSfx.play()


"""
Parameters:
	'finger_index': 0 = right frog, 2 = left frog, 1 = middle frog
"""
func hug(finger_index: int) -> void:
	wiggle_frames = WIGGLE_FRAMES_BY_HUGGED_FINGER[finger_index]
	_wiggle_timer.assign_wiggle_frame()
	
	# the animationplayer assigns the modulate/offset a frame too late.
	# we set them manually to avoid an ugly blink effect
	modulate = Color.white
	offset = Vector2(0, 0)
	
	$AnimationPlayer.play("hug%s" % [finger_index])
	$HugSfx.pitch_scale = rand_range(0.8, 1.2)
	$HugSfx.stream = _hug_sounds[randi() % _hug_sounds.size()]
	
	$HugSfx.play()

extends Sprite2D
## Draws a part of the player's hand sprite.
##
## The hand is usually drawn as a single unit, but sometimes we draw separate parts of it. When a shark bites off a
## finger, the finger detaches and is drawn as a separate sprite. When a frog hugs the player's hand, a heart sprite
## appears and floats away. This sprite handles drawing both detached fingers and floating hearts.

## key: (int) index of bitten finger
## value: (Array, int) pair of wiggle frames to show when the finger is bitten
const WIGGLE_FRAMES_BY_BITTEN_FINGER := {
	0: [1, 2],
	1: [3, 4],
	2: [5, 6],
}

## key: (int) index of hugged finger
## value: (Array, int) pair of wiggle frames to show when the finger is hugged
const WIGGLE_FRAMES_BY_HUGGED_FINGER := {
	0: [7, 8],
	1: [9, 10],
	2: [11, 12],
}

@export var wiggle_frames: Array[int] = []

@onready var _wiggle_timer := $WiggleTimer

@onready var _hug_sounds := [
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


## Parameters:
## 	'finger_index': 2 = pinky finger, 1 = naughty finger, 0 = pointer finger
func bite(finger_index: int) -> void:
	# Workaround for Godot #72627 (https://github.com/godotengine/godot/issues/72627); Cannot cast typed arrays using
	# type hints
	wiggle_frames.assign(WIGGLE_FRAMES_BY_BITTEN_FINGER[finger_index])
	_wiggle_timer.assign_wiggle_frame()
	
	# the animationplayer assigns the modulate/offset a frame too late.
	# we set them manually to avoid an ugly blink effect
	modulate = Color.WHITE
	offset = Vector2(0, 0)
	$AnimationPlayer.play("bite")
	
	$CartoonBiteSfx.pitch_scale = randf_range(0.95, 1.01)
	$CartoonBiteSfx.play()


## Parameters:
## 	'finger_index': 0 = right frog, 2 = left frog, 1 = middle frog
func hug(finger_index: int) -> void:
	wiggle_frames.assign(WIGGLE_FRAMES_BY_HUGGED_FINGER[finger_index])
	_wiggle_timer.assign_wiggle_frame()
	
	# the animationplayer assigns the modulate/offset a frame too late.
	# we set them manually to avoid an ugly blink effect
	modulate = Color.WHITE
	offset = Vector2(0, 0)
	
	$AnimationPlayer.play("hug%s" % [finger_index])
	$HugSfx.pitch_scale = randf_range(0.8, 1.2)
	$HugSfx.stream = Utils.rand_value(_hug_sounds)
	
	$HugSfx.play()

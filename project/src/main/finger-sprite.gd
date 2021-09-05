extends Sprite

const WIGGLE_FRAMES_BY_FINGER := {
	0: [1, 2],
	1: [3, 4],
	2: [5, 6],
}

export (Array, int) var wiggle_frames := []

onready var _wiggle_timer := $WiggleTimer

"""
Parameters:
	'finger_index': 2 = pinky finger, 1 = naughty finger, 0 = pointer finger
"""
func bite(finger_index: int) -> void:
	wiggle_frames = WIGGLE_FRAMES_BY_FINGER[finger_index]
	_wiggle_timer.assign_wiggle_frame()
	$AnimationPlayer.play("bite")
	$CartoonBiteSfx.pitch_scale = rand_range(0.95, 1.01)
	$CartoonBiteSfx.play()

class_name WiggleSprite
extends Sprite

export (Array, int) var wiggle_frames := []

func reset_wiggle() -> void:
	$WiggleTimer.reset_wiggle()


func assign_wiggle_frame() -> void:
	$WiggleTimer.assign_wiggle_frame()

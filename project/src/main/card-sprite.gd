extends Sprite

export (Array, int) var wiggle_frames := [] setget set_wiggle_frames

func set_wiggle_frames(new_wiggle_frames: Array) -> void:
	wiggle_frames = new_wiggle_frames


func reset_wiggle() -> void:
	$WiggleTimer.reset_wiggle()

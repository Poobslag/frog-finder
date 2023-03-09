@tool
class_name WiggleSprite
extends Sprite2D
## A sprite which alternates between two animation frames to give a squigglevision effect, emulating the effect of
## sketchily hand-drawn animation.

@export (Array, int) var wiggle_frames := []

func reset_wiggle() -> void:
	if Engine.is_editor_hint():
		return
	
	$WiggleTimer.reset_wiggle()


func assign_wiggle_frame() -> void:
	if Engine.is_editor_hint():
		frame = wiggle_frames[0] if wiggle_frames else 0
		return
	
	$WiggleTimer.assign_wiggle_frame()

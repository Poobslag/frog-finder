class_name PetalSprite
extends Sprite2D
## Draws a plucked flower petal.
##
## When the player plucks off a petal, the petal detaches and is drawn as a separate sprite.

func pluck() -> void:
	%AnimationPlayer.play("pluck")
	%PluckSfx.pitch_scale = randf_range(0.8, 1.2)
	%PluckSfx.play()


func reset() -> void:
	%AnimationPlayer.play("RESET")

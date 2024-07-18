class_name Flower
extends Sprite2D
## A flower which appears during bee intermissions.
##
## Attracts bees. The player can click it to pluck its petals.

const PETAL_COUNT_BY_FRAME := [0, 4, 3, 2, 1, 0, 4, 0]

## Rectangle defining where flowers can appear. When the flower is plucked, it will move somewhere within this
## rectangle.
var region: Rect2:
	set(new_region):
		region = new_region
		if not region.has_point(position):
			randomize_position()

var _tween: Tween

## Returns the center of the ball's visuals.
func get_clickable_position() -> Vector2:
	return position + to_local(to_global(Vector2(0, -25)))


## Removes a petal, possibly causing the flower to disappear.
func pluck() -> void:
	match frame:
		1:
			# immediately stop the "show" animation if it is still playing
			%AnimationPlayer.stop(true)
			
			frame += 1
			%PetalSprite1.pluck()
		2:
			frame += 1
			%PetalSprite2.pluck()
		3:
			frame += 1
			%PetalSprite3.pluck()
		4:
			frame += 1
			%PetalSprite4.pluck()
			_disappear_and_reappear()


## Returns the number of unplucked petals.
func get_petal_count() -> int:
	return PETAL_COUNT_BY_FRAME[frame]


## Moves the flower to a random position within its defined region.
func randomize_position() -> void:
	position = Vector2(
		randf_range(region.position.x, region.end.x),
		randf_range(region.position.y, region.end.y)
	)


## Schedules the flower to disappear and reappear somewhere else.
func _disappear_and_reappear() -> void:
	_tween = Utils.recreate_tween(self, _tween)
	
	# wait for a random duration before disappearing
	_tween.tween_interval(Utils.rand_value([1.5, 2.5, 2.5, 2.5, 2.5, 4.0, 4.0]))
	
	# disappear
	_tween.tween_callback(%AnimationPlayer.play.bind("hide"))
	
	# wait for a random duration before reappearing
	_tween.tween_interval(Utils.rand_value([0.3, 2.0, 2.0, 2.0, 2.0, 4.0, 4.0]))
	
	# reappear
	_tween.tween_callback(randomize_position)
	for petal_sprite in [%PetalSprite1, %PetalSprite2, %PetalSprite3, %PetalSprite4]:
		_tween.tween_callback(petal_sprite.reset)
	_tween.tween_callback(%AnimationPlayer.play.bind("show"))

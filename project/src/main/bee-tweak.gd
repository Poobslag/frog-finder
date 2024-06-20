extends IntermissionTweak
## Tweaks the intermission to include bees and flowers.

## The maximum radius from the flower's center in world coordinates where it is considered 'clicked'
const FLOWER_CLICK_RADIUS := 25.0

const BEE_SPAWN_BORDER := 10.0

@export var FlowerScene: PackedScene
@export var BeeScene: PackedScene

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & MOUSE_BUTTON_LEFT:
		var flower := _find_clicked_flower()
		if flower:
			flower.pluck()


## Returns the clicked flower for the current mouse position.
##
## If one or more flowers are close enough to the mouse, this method returns the closest one. If no flowers are close
## enough, this method returns null.
##
## Returns: The closest flower to the mouse, or 'null' if no flowers are close enough to be clicked.
func _find_clicked_flower() -> Flower:
	var clicked_flower: Flower
	var clicked_flower_distance := 999999.0
	
	# find the flower closest to the mouse
	var local_mouse_position := panel.obstacles.get_local_mouse_position()
	for next_flower_obj in get_tree().get_nodes_in_group("flowers"):
		var next_flower: Flower = next_flower_obj
		var next_flower_distance := next_flower.get_clickable_position().distance_to(local_mouse_position)
		if next_flower_distance < clicked_flower_distance:
			clicked_flower = next_flower
			clicked_flower_distance = next_flower_distance
	
	# if the closest flower is outside the click radius, disregard it
	if clicked_flower_distance > FLOWER_CLICK_RADIUS:
		clicked_flower = null
	
	return clicked_flower


## Applies this tweak to the IntermissionPanel.
func apply_tweak() -> void:
	for _i in range(8):
		_add_flower()
	for _i in range(11):
		_add_bee()


## Reverts this tweak from the IntermissionPanel.
func revert_tweak() -> void:
	## remove all flowers
	for flower in get_tree().get_nodes_in_group("flowers"):
		flower.queue_free()


## Adds a flower to a random location.
func _add_flower() -> void:
	var flower: Flower = FlowerScene.instantiate()
	_refresh_flower_region(flower)
	flower.randomize_position()
	panel.obstacles.add_child(flower)


## Adds a flower to a random location.
func _add_bee() -> void:
	var bee: Bee = BeeScene.instantiate()
	bee.position = _random_spawn_point()
	panel.obstacles.add_child(bee)


## Refreshes the boundaries for the specified flower.
func _refresh_flower_region(flower: Flower) -> void:
	flower.region = Rect2(Vector2.ZERO, panel.obstacles.size).grow(-100)


## Calculates a random spawn point, either on the edge of the screen or in the center.
func _random_spawn_point() -> Vector2:
	var viewport_rect_size := panel.get_viewport_rect().size
	
	var spawn_point := Vector2(randf_range(0, viewport_rect_size.x), randf_range(0, viewport_rect_size.y))
	match randi_range(0, 8):
		0:
			# top wall
			spawn_point.y = -BEE_SPAWN_BORDER
		1:
			# right wall
			spawn_point.x = viewport_rect_size.x + BEE_SPAWN_BORDER
		2:
			# bottom wall
			spawn_point.y = viewport_rect_size.y + BEE_SPAWN_BORDER
		3:
			# left wall
			spawn_point.x = -BEE_SPAWN_BORDER
		_:
			# center
			pass
	
	spawn_point += Bee.OFFSET_DEFAULT
	
	return spawn_point - panel.obstacles.global_position

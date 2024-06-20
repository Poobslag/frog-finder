extends CreatureBehavior
## Defines how a bee chases flowers.

## Minimum distance within which bees can pick up pollen
const POLLENATION_DISTANCE := 20.0

## Random factor added to a bee's velocity, so that they don't move in perfectly straight lines
const ZIGZAG_AMOUNT := 10

var _bee: Bee

## Flower the bee is chasing
var _target_flower: Flower

## Time in seconds the bee has flown without picking up or dropping off pollen
var _travel_time := 0.0

## Starts the behavior. The bee randomly either flies towards a flower or offscreen.
func start_behavior(new_bee: Node) -> void:
	_bee = new_bee
	_travel_time = 0.0
	_bee.frustrated = false
	
	# if we're low on pollen, we find a flower. otherwise we fly offscreen
	if _bee.pollen_count < randi_range(0, Bee.POLLEN_CAPACITY):
		_find_target_flower()
	else:
		_bee.velocity = (_bee.position - get_viewport().get_visible_rect().get_center()).normalized() * _bee.fly_speed
	
	_think()
	%ThinkTimer.start()


## Stops any timers and resets any transient data for this behavior.
func stop_behavior(_creature: Node) -> void:
	_bee = null
	_travel_time = 0.0
	_bee.frustrated = false
	_target_flower = null
	
	%ThinkTimer.stop()
	%PollenationTimer.stop()


## Runs the bee's AI, deciding whether to fly offscreen or target a flower.
func _think() -> void:
	_travel_time += %ThinkTimer.wait_time
	
	if _bee.pollen_count >= Bee.POLLEN_CAPACITY and _target_flower != null:
		_target_flower = null
	if _bee.pollen_count <= 0 and _target_flower == null:
		_find_target_flower()
	
	if _target_flower != null:
		_fly_to_flower()
	else:
		_fly_offscreen()
	
	_apply_velocity_variance()
	_apply_frustration()


## Sets the 'target_flower' field to a flower the bee can pollenate.
func _find_target_flower() -> void:
	var flowers := get_tree().get_nodes_in_group("flowers")
	flowers.shuffle()
	for flower in flowers:
		if flower.get_petal_count() == 0:
			continue
		
		_target_flower = flower
		break


## Sets the 'target_flower' field to a flower the bee can pollenate, and updates the bee's velocity.
##
## The bee flies at their maximum velocity until they get closer to the flower, then they slow down.
func _fly_to_flower() -> void:
	if _target_flower == null or _target_flower.get_petal_count() == 0:
		_find_target_flower()
	if _target_flower != null:
		_bee.velocity = (_target_flower.global_position - _bee.global_position).normalized() * _bee.fly_speed
		
		if _bee.global_position.distance_to(_target_flower.global_position) < POLLENATION_DISTANCE:
			# almost stop; we're very close to the flower
			_bee.velocity *= 0.25
			if %PollenationTimer.is_stopped():
				%PollenationTimer.start()
		elif _bee.global_position.distance_to(_target_flower.global_position) < _bee.fly_speed:
			# slow down; we're close to the flower
			_bee.velocity *= 0.5


## Updates the bee's velocity, and possibly drops off pollen.
func _fly_offscreen() -> void:
	if _bee.velocity.length() <= _bee.fly_speed * 0.5:
		# prevent bees from randomly slowing down so much that they can't reach the edge
		_bee.velocity *= 1.2
	
	if _can_drop_off_pollen():
		_drop_off_pollen()


## Zigzags the bee's path slightly, and limits the bee's velocity.
func _apply_velocity_variance() -> void:
	var new_velocity := _bee.velocity
	new_velocity.x += randf_range(-ZIGZAG_AMOUNT, ZIGZAG_AMOUNT)
	new_velocity.y += randf_range(-ZIGZAG_AMOUNT, ZIGZAG_AMOUNT)
	new_velocity = new_velocity.limit_length(_bee.fly_speed)
	_bee.velocity = new_velocity


## Increase the bee's velocity if they've spent too long without doing anything.
##
## This should only happen if the player is messing with a particular bee, preventing them from reaching flowers.
func _apply_frustration() -> void:
	if _travel_time > 20.0:
		var frustration_factor := inverse_lerp(20.0, 40.0, _travel_time)
		frustration_factor = clamp(frustration_factor, 0, 4.0)
		_bee.velocity *= pow(1.5, frustration_factor)
		_bee.frustrated = true


func _pick_up_pollen() -> void:
	_travel_time = 0
	_bee.frustrated = false
	_bee.pollen_count = clamp(_bee.pollen_count + randi_range(0, 2), 0, Bee.POLLEN_CAPACITY)


func _drop_off_pollen() -> void:
	_travel_time = 0
	_bee.frustrated = false
	_bee.pollen_count = clamp(_bee.pollen_count - randi_range(0, 4), 0, Bee.POLLEN_CAPACITY)


func _can_pick_up_pollen() -> bool:
	var result := true
	
	if _target_flower == null:
		result = false
	elif _target_flower.get_petal_count() == 0:
		result = false
	elif _bee.global_position.distance_to(_target_flower.global_position) >= POLLENATION_DISTANCE:
		result = false
	elif _bee.pollen_count >= Bee.POLLEN_CAPACITY:
		result = false
	
	return result


func _can_drop_off_pollen() -> bool:
	var result := true
	
	if _bee.get_viewport_rect().has_point(_bee.global_position):
		result = false
	elif _bee.pollen_count == 0:
		result = false
	
	return result


func _on_think_timer_timeout() -> void:
	_think()


## If the bee is in range of their target flower, this accumulates pollen.
##
## Otherwise, this stops the Pollenation timer.
func _on_pollenation_timer_timeout() -> void:
	# determine whether the bee can pick up pollen
	if _can_pick_up_pollen():
		_pick_up_pollen()
	else:
		%PollenationTimer.stop()
		_bee.velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * _bee.fly_speed

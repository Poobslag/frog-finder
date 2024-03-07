class_name BeachBall
extends Node2D
## A bouncing beach ball which appears during beach intermissions.
##
## This beach balls sits on the floor, but can also bounce in the air.

## How frequently the ball will redraw if it is moving too slowly for the redraw distance to kick in.
const MAX_REDRAW_SECONDS := 0.2

## The distance which will force the ball to redraw.
const MAX_REDRAW_DISTANCE := 40

const GRAVITY := 200

## The magnitude of the velocity vector when the ball is bounced by being clicked on or bumped into.
const BOUNCE_AMOUNT_XY := 400
const BOUNCE_AMOUNT_Z := 600

## The dampening effect as the ball flies through the air. This gives the ball a terminal velocity and also causes it
## to fall with a more vertical arc.
const AIR_DAMP := 0.8

## The dampening effect as the ball rolls along the ground. This prevents the ball from rolling forever.
const GROUND_DAMP := 1.6

## The XY boundaries which the ball will bounce off of.
@export var bounce_rect: Rect2

## The ball's position. This value smoothly updates every frame, and the visuals are periodically snapped to match.
var physics_position := Vector3.ZERO
var physics_velocity := Vector3.ZERO

func _ready() -> void:
	%RedrawTimer.start(MAX_REDRAW_SECONDS)
	physics_position = _node_position()
	_randomize_texture(true)


func _process(delta: float) -> void:
	# Update the ball's position
	_run_physics(delta)
	
	if (physics_position - _node_position()).length() > MAX_REDRAW_DISTANCE:
		# The ball is moving quickly. Refresh the visuals based on the ball's new position.
		_refresh_visuals()
		%RedrawTimer.start()


## Returns the center of the ball's visuals.
func get_clickable_position() -> Vector2:
	return position + to_local(%Sprite.to_global(Vector2.ZERO))


## Bounces the ball into the air.
##
## Parameters:
## 	'bounce_factor': (Optional) A scalar for how fast the ball should bounce; 2.0 = 200% of a normal bounce. If
## 		omitted, defaults to a random value from [0.9, 1.1]
func bounce(bounce_factor := 0.0) -> void:
	var old_physics_velocity := physics_velocity
	
	if bounce_factor == 0.0:
		bounce_factor = randf_range(0.9, 1.1)
	
	# bounce vertically
	physics_velocity.z = BOUNCE_AMOUNT_Z * bounce_factor
	
	# bounce horizontally; we pick a random diagonal-ish direction by first picking the steepness of an angle, and then
	# picking which quadrant to aim towards
	var bounce_angle := randf_range(0.1 * PI, 0.4 * PI)
	bounce_angle += Utils.rand_value([0, 0.5 * PI, 1.0 * PI, 1.5 * PI])
	physics_velocity.x = BOUNCE_AMOUNT_XY * bounce_factor * sin(bounce_angle)
	physics_velocity.y = BOUNCE_AMOUNT_XY * bounce_factor * cos(bounce_angle)
	
	_play_bounce_sfx((old_physics_velocity - physics_velocity).length())


## Calculates the 3D 'physics position' corresponding to the sprite's current position.
func _node_position() -> Vector3:
	return Vector3(position.x, position.y, -%SpriteElevator.position.y)


## Updates the node positions and randomizes the sprite's texture.
func _refresh_visuals() -> void:
	var old_node_position := _node_position()
	
	# Move the sprite.
	position = Vector2(physics_position.x, physics_position.y)
	%SpriteElevator.position.y = -physics_position.z
	
	# Update the sprite's texture.
	var new_node_position := _node_position()
	if new_node_position.distance_to(old_node_position) > 5:
		_randomize_texture()


## Randomizes the sprite's texture, changing its frame, rotation and flip values.
func _randomize_texture(avoid_similar_frames: bool = true) -> void:
	%Sprite.flip_h = randf() < 0.5
	%Sprite.flip_v = randf() < 0.5
	%Sprite.rotation = randi_range(0, 3) * PI / 2
	
	if avoid_similar_frames:
		# Avoid picking similar frames back-to-back.
		#
		# Frames 2 and 6 are just recolors of each other, for example. To avoid picking them back-to-back, we randomly
		# increment by 1, 2 or 3 frames.
		%Sprite.frame = (%Sprite.frame + 1 + randi_range(0, 3)) % 7
	else:
		%Sprite.frame = randi_range(0, 7)


## Returns 'true' if the physics position is on or below the ground.
func _sprite_on_ground() -> bool:
	return physics_position.z <= 0.0


## Applies gravity and collisions.
func _run_physics(delta: float) -> void:
	physics_position += physics_velocity * delta
	
	if _sprite_on_ground() :
		physics_velocity -= physics_velocity * GROUND_DAMP * delta
	else:
		physics_velocity -= physics_velocity * AIR_DAMP * delta
	
	# collide with floor
	if _sprite_on_ground():
		if abs(physics_velocity.z) > 20:
			_play_bounce_sfx(abs(physics_velocity.z))
		physics_velocity.z = 0.0
	else:
		physics_velocity.z -= GRAVITY * delta
	
	# collide with horizontal walls
	physics_position.x = wrapf(physics_position.x, bounce_rect.position.x, bounce_rect.end.x + bounce_rect.size.x)
	if physics_position.x > bounce_rect.end.x:
		physics_position.x = bounce_rect.end.x - (physics_position.x - bounce_rect.end.x)
		physics_velocity.x *= -1
		_play_bounce_sfx(abs(physics_velocity.x * 2))
	
	# collide with vertical walls
	physics_position.y = wrapf(physics_position.y, bounce_rect.position.y, bounce_rect.end.y + bounce_rect.size.y)
	if physics_position.y > bounce_rect.end.y:
		physics_position.y = bounce_rect.end.y - (physics_position.y - bounce_rect.end.y)
		physics_velocity.y *= -1
		_play_bounce_sfx(abs(physics_velocity.y * 2))


## Plays a sound effect when the ball when the ball is bounced by being clicked on, bumped into, or hitting a wall or
## floor.
##
## Parameters:
## 	'velocity_differential': The length of the difference between the old velocity vector and the new velocity vector.
## 		This will be a big number if the ball falls from a great height or bounces directly into a wall, and a small
## 		number if it's rolling along the ground or glances sideways against a wall.
func _play_bounce_sfx(velocity_differential: float = 1000.0) -> void:
	var sfx_volume: float
	if velocity_differential > 500:
		sfx_volume = -9.0
	elif velocity_differential > 250:
		sfx_volume = -12.0
	elif velocity_differential > 150:
		sfx_volume = -15.0
	elif velocity_differential > 50:
		sfx_volume = -18.0
	else:
		sfx_volume = -999.0
	
	if sfx_volume > -50:
		%BounceSfx.volume_db = sfx_volume
		%BounceSfx.pitch_scale = randf_range(0.95, 1.05)
		SfxDeconflicter.play(%BounceSfx)


## When our redraw timer times out, we refresh the visuals based on the ball's position.
##
## This will happen if the ball is moving slowly or not at all.
func _on_redraw_timer_timeout() -> void:
	_refresh_visuals()


## When a frog or shark enters our collision area, we bounce into the air.
func _on_area_2d_area_entered(_area: Area2D) -> void:
	if physics_position.z < 50:
		# Don't do a full bounce, more of a half bounce.
		bounce(randf_range(0.65, 0.75))

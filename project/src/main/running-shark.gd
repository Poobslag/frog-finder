class_name RunningShark
extends Sprite2D
## Shark which chases the player's cursor.

## If the shark gets within this distance of the player's hand, they will bite off a finger.
const BITE_DISTANCE := 70.0

## The duration sharks will pursue the hand for before switching to the 'panic' state.
const CHASE_DURATION := 6

## The duration sharks will run in a random direction before switching to the 'chase' state.
const PANIC_DURATION := 1.2

const MIN_RUN_SPEED := 150.0
const MAX_RUN_SPEED := 1200.0

## How accurately we chase the cursor. Sharks with low agility will run in arbitrary directions more frequently.
const MAX_AGILITY := 4.0

## When we get within this distance of our target, we will run sideways instead to trap it in a corner.
const PINCER_DISTANCE := 150.0

## where the shark has to stand to count as 'catching' the hand
const HAND_CATCH_OFFSET := Vector2(28, 20)

## the hand to chase
var hand: Hand

## Another shark which affects this shark's pathfinding. As long as our friend is chasing the hand, we will chase our
## friend instead. This prevents sharks from clustering too tightly.
var friend: Sprite2D

var velocity := Vector2.ZERO
var run_speed := MIN_RUN_SPEED : set = set_run_speed

## How accurately we chase the cursor. Sharks with low agility will run in arbitrary directions more frequently.
var agility := 1.0

## sharks move in a jerky way. soon_position stores the location where the frog will blink to after a delay
var soon_position: Vector2 : set = set_soon_position

## Sharks alternate between two states: 'panic' and 'chase'. This variable tracks how many times they've entered the
## 'chase' state.
var _chase_count := 0

@onready var _animation_player := $AnimationPlayer
@onready var _chase_timer := $ChaseTimer
@onready var _panic_timer := $PanicTimer
@onready var _think_timer := $ThinkTimer

func _ready() -> void:
	_refresh_run_speed()


func _physics_process(delta: float) -> void:
	soon_position += velocity * delta
	var viewport_rect_size := get_viewport_rect().size
	soon_position.x = clamp(soon_position.x, -200, viewport_rect_size.x + 200)
	soon_position.y = clamp(soon_position.y, -200, viewport_rect_size.y + 200)


## Makes the shark enter the 'chase state' where they run toward the hand.
func chase() -> void:
	_panic_timer.stop()
	var wait_time := CHASE_DURATION * randf_range(0.8, 1.2)
	if _chase_count == 0:
		# the first time we chase, we are more persistent
		wait_time *= 2
	_chase_timer.start(wait_time)
	_chase_count += 1


## Makes the shark enter the 'panic state' where they run in a random direction.
##
## Sharks periodically panic to prevent them from clustering too tightly.
func panic() -> void:
	_chase_timer.stop()
	_panic_timer.start((PANIC_DURATION / agility) * randf_range(0.8, 1.2))
	velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * run_speed


func set_run_speed(new_run_speed: float) -> void:
	run_speed = new_run_speed
	if not is_inside_tree():
		return
	_refresh_run_speed()


## Updates the shark's position to their soon_position.
##
## This is called periodically to result in a jerky movement effect.
func update_position() -> void:
	flip_h = true if soon_position < position else false
	position = soon_position


## 'true' if this shark has eaten the player's finger.
##
## Fed sharks have a chubby belly and run offscreen instead of chasing the hand.
func is_fed() -> bool:
	return _animation_player.current_animation == "run-fed"


func set_soon_position(new_soon_position: Vector2) -> void:
	soon_position = new_soon_position
	position = new_soon_position


func _refresh_run_speed() -> void:
	_animation_player.playback_speed = run_speed / 150.0


func _on_PanicTimer_timeout() -> void:
	chase()
	set_run_speed(lerp(run_speed, MAX_RUN_SPEED, 0.10))
	agility = lerp(agility, MAX_AGILITY, 0.15)


func _on_ChaseTimer_timeout() -> void:
	panic()


func _on_ThinkTimer_timeout() -> void:
	if not hand or hand.biteable_fingers < 1:
		return
	
	if is_fed():
		return
	
	var run_target := hand.global_position + HAND_CATCH_OFFSET
	
	if (run_target - global_position).length() < BITE_DISTANCE:
		# we caught the hand... bite!
		_animation_player.play("run-fed")
		velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * run_speed
		_think_timer.stop()
		hand.bite()
	elif not _chase_timer.is_stopped():
		if friend and not friend.is_fed() and (run_target - global_position).length() > PINCER_DISTANCE:
			# our friend will help us; don't run towards the hand, run behind our friend
			run_target = friend.global_position + (friend.global_position - run_target).normalized() * PINCER_DISTANCE
		else:
			# we have no friend; run towards the hand
			pass
		
		velocity = (run_target - global_position).normalized() * run_speed
	elif not _panic_timer.is_stopped():
		# if we're panicking, we continue running in our randomly chosen direction
		pass

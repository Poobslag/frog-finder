class_name RunningShark
extends Sprite
## Shark which chases the player's cursor.

const BITE_DISTANCE := 70.0
const CHASE_DURATION := 6
const PANIC_DURATION := 1.2
const MIN_RUN_SPEED := 150.0
const MAX_RUN_SPEED := 1200.0
const MAX_AGILITY := 4.0
const PINCER_DISTANCE := 150.0

## where the shark has to stand to count as 'catching' the hand
const HAND_CATCH_OFFSET := Vector2(28, 20)

var hand: Hand
var friend: Sprite
var velocity := Vector2.ZERO
var run_speed := MIN_RUN_SPEED setget set_run_speed
var agility := 1.0

## sharks move in a jerky way. soon_position stores the location where the frog will blink to after a delay
var soon_position: Vector2 setget set_soon_position
var _chase_count := 0

onready var _animation_player := $AnimationPlayer
onready var _chase_timer := $ChaseTimer
onready var _panic_timer := $PanicTimer
onready var _think_timer := $ThinkTimer

func _ready() -> void:
	_refresh_run_speed()


func _physics_process(delta: float) -> void:
	soon_position += velocity * delta
	var viewport_rect_size := get_viewport_rect().size
	soon_position.x = clamp(soon_position.x, -200, viewport_rect_size.x + 200)
	soon_position.y = clamp(soon_position.y, -200, viewport_rect_size.y + 200)


func chase() -> void:
	_panic_timer.stop()
	var wait_time := CHASE_DURATION * rand_range(0.8, 1.2)
	if _chase_count == 0:
		# the first time we chase, we are more persistent
		wait_time *= 2
	_chase_timer.start(wait_time)
	_chase_count += 1


func panic() -> void:
	_chase_timer.stop()
	_panic_timer.start((PANIC_DURATION / agility) * rand_range(0.8, 1.2))
	velocity = Vector2.RIGHT.rotated(rand_range(0, PI * 2)) * run_speed


func set_run_speed(new_run_speed: float) -> void:
	run_speed = new_run_speed
	if not is_inside_tree():
		return
	_refresh_run_speed()


func move() -> void:
	flip_h = true if soon_position > position else false
	position = soon_position


func set_soon_position(new_soon_position: Vector2) -> void:
	soon_position = new_soon_position
	position = new_soon_position


func _refresh_run_speed() -> void:
	_animation_player.playback_speed = run_speed / 150.0


func is_fed() -> bool:
	return _animation_player.current_animation == "run-fed"


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
	
	var run_target := hand.rect_global_position + HAND_CATCH_OFFSET
	
	if ((run_target - global_position).length() < BITE_DISTANCE):
		# we caught the hand... bite!
		_animation_player.play("run-fed")
		velocity = Vector2.RIGHT.rotated(rand_range(0, PI * 2)) * run_speed
		_think_timer.stop()
		hand.bite()
	elif not _chase_timer.is_stopped():
		if friend and not friend.is_fed() and (run_target - global_position).length() > PINCER_DISTANCE:
			# our friend will help us; don't run towards the hand, run behind our friend
			run_target = friend.global_position + (friend.global_position - run_target).normalized() * PINCER_DISTANCE
		else:
			# we have no friend; run towards the hand
			pass
		
		# we have no friend; run towards the hand
		velocity = (run_target - global_position).normalized() * run_speed
	elif not _panic_timer.is_stopped():
		# if we're panicking, we continue running in our randomly chosen direction
		pass

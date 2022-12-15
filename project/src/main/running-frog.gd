class_name RunningFrog
extends Sprite

const HUG_DISTANCE := 40.0
const CHASE_DURATION := 6
const PANIC_DURATION := 1.2
const SUPER_PANIC_DURATION := 4.8
const RUN_SPEED := 150.0
const PINCER_DISTANCE := 150.0

# where the shark has to stand to count as 'catching' the hand
const HAND_CATCH_OFFSET := Vector2(28, 20)

var hand: Hand
var friend: Sprite
var velocity := Vector2.ZERO
var run_speed := RUN_SPEED

var soon_position: Vector2 setget set_soon_position
var old_frame: int
var chase_count := 0

onready var _animation_player := $AnimationPlayer
onready var _chase_timer := $ChaseTimer
onready var _panic_timer := $PanicTimer
onready var _think_timer := $ThinkTimer

func _ready() -> void:
	if hand:
		hand.connect("hug_finished", self, "_on_Hand_hug_finished")
	run_speed = RUN_SPEED * rand_range(0.8, 1.2)
	_refresh_run_speed()


func _physics_process(delta: float) -> void:
	soon_position += velocity * delta
	var viewport_rect_size := get_viewport_rect().size
	soon_position.x = clamp(soon_position.x, -200, viewport_rect_size.x + 200)
	soon_position.y = clamp(soon_position.y, -200, viewport_rect_size.y + 200)


func chase() -> void:
	_panic_timer.stop()
	var wait_time := CHASE_DURATION * rand_range(0.8, 1.2)
	if chase_count == 0:
		# the first time we chase, we are more persistent
		wait_time *= 2
	_chase_timer.start(wait_time)
	chase_count += 1


func panic() -> void:
	_chase_timer.stop()
	_panic_timer.start(PANIC_DURATION * rand_range(0.8, 1.2))
	velocity = Vector2.RIGHT.rotated(rand_range(0, PI * 2)) * run_speed


func move() -> void:
	flip_h = true if soon_position > position else false
	position = soon_position


func set_soon_position(new_soon_position: Vector2) -> void:
	soon_position = new_soon_position
	position = new_soon_position


func is_hugging() -> bool:
	return _animation_player.current_animation == "hug"


func _refresh_run_speed() -> void:
	_animation_player.playback_speed = run_speed / 150.0


func _on_PanicTimer_timeout() -> void:
	if hand.hugged_fingers >= hand.huggable_fingers and randf() < 0.5:
		# oh no, we can't hug the hand! continue panicking!
		_panic_timer.start(rand_range(SUPER_PANIC_DURATION, 5.0))
		velocity = Vector2.RIGHT.rotated(rand_range(0, PI * 2)) * run_speed
	else:
		chase()


func _on_ChaseTimer_timeout() -> void:
	panic()


func _on_Hand_hug_finished() -> void:
	if not is_hugging():
		return
	
	_animation_player.play("run")
	_think_timer.start()
	panic()
	soon_position += velocity.normalized() * 40


func _on_ThinkTimer_timeout() -> void:
	if not hand or hand.huggable_fingers < 1:
		return
	
	var run_target := hand.rect_global_position + HAND_CATCH_OFFSET

	if not _chase_timer.is_stopped():
		if ((run_target - global_position).length() < HUG_DISTANCE) and hand.resting:
			# we're close enough for a hug
			if hand.hugged_fingers < hand.huggable_fingers:
				# we caught the hand... hug!
				_animation_player.play("hug")
				_think_timer.stop()
				_chase_timer.stop()
				_panic_timer.stop()
				hand.hug()
				velocity = Vector2.ZERO
			else:
				# we're too shy. run away!
				panic()
		else:
			if friend and not friend.is_hugging() and (run_target - global_position).length() > PINCER_DISTANCE:
				# our friend will help us; don't run towards the hand, run behind our friend
				run_target = friend.global_position + (friend.global_position - run_target).normalized() * PINCER_DISTANCE
				velocity = (run_target - global_position).normalized() * run_speed
			
			# we have no friend; run towards the hand
			velocity = (run_target - global_position).normalized() * run_speed
	elif not _panic_timer.is_stopped():
		# if we're panicking, we continue running in our randomly chosen direction
		pass

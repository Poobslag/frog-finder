extends CreatureBehavior
## Defines how a frog chases the player's cursor.

## If the frog gets within this distance of the player's hand, they will bite off a finger.
const HUG_DISTANCE := 40.0

## The duration frogs will pursue the hand for before switching to the 'panic' state.
const CHASE_DURATION := 6

## The duration frogs will run in a random direction before switching to the 'chase' state.
const PANIC_DURATION := 1.2

## The duration frogs will run in a random direction if the hand is fully hugged before switching to the 'chase' state.
const SUPER_PANIC_DURATION := 4.8

## When we get within this distance of our target, we will run sideways instead to trap it in a corner.
const PINCER_DISTANCE := 150.0

## where the frog has to stand to count as 'catching' the hand
const HAND_CATCH_OFFSET := Vector2(28, 57)

## Another frog which affects this frog's pathfinding. As long as our friend is chasing the hand, we will chase our
## friend instead. This prevents frogs from clustering too tightly.
var friend: Sprite2D

## the hand to chase
var hand: Hand : set = set_hand

var _frog: RunningFrog
var _chase_count := 0

@onready var _chase_timer := $ChaseTimer
@onready var _panic_timer := $PanicTimer
@onready var _think_timer := $ThinkTimer


func set_hand(new_hand: Hand) -> void:
	if hand:
		hand.disconnect("hug_finished",Callable(self,"_on_Hand_hug_finished"))
	
	hand = new_hand
	
	if hand:
		hand.connect("hug_finished",Callable(self,"_on_Hand_hug_finished"))


func start_behavior(new_frog: Node) -> void:
	_frog = new_frog
	_think_timer.start(randf_range(0, 0.1))
	_frog.run("chase")
	_chase()


## Stops any timers and resets any transient data for this behavior.
func stop_behavior(_new_frog: Node) -> void:
	# disconnect signals
	friend = null
	set_hand(null)
	_frog = null
	_chase_count = 0
	
	_think_timer.stop()
	_chase_timer.stop()
	_panic_timer.stop()


func _chase() -> void:
	_panic_timer.stop()
	var wait_time := CHASE_DURATION * randf_range(0.8, 1.2)
	if _chase_count == 0:
		# the first time we chase, we are more persistent
		wait_time *= 2
	_chase_timer.start(wait_time)
	_chase_count += 1


func _panic() -> void:
	_chase_timer.stop()
	_panic_timer.start(PANIC_DURATION * randf_range(0.8, 1.2))
	_frog.velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * _frog.run_speed


func _on_PanicTimer_timeout() -> void:
	if hand.hugged_fingers >= hand.huggable_fingers and randf() < 0.5:
		# oh no, we can't hug the hand! continue panicking!
		_panic_timer.start(randf_range(SUPER_PANIC_DURATION, 5.0))
		_frog.velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * _frog.run_speed
	else:
		_chase()


func _on_ChaseTimer_timeout() -> void:
	_panic()


func _on_Hand_hug_finished() -> void:
	if not _frog.is_hugging():
		return
	
	_frog.run("chase")
	_think_timer.start()
	_panic()
	_frog.soon_position += _frog.velocity.normalized() * 40


func _on_ThinkTimer_timeout() -> void:
	if not hand or hand.huggable_fingers < 1:
		return
	
	var run_target := hand.global_position + HAND_CATCH_OFFSET

	if not _chase_timer.is_stopped():
		if ((run_target - _frog.global_position).length() < HUG_DISTANCE) and hand.resting:
			# we're close enough for a hug
			if hand.hugged_fingers < hand.huggable_fingers:
				# we caught the hand... hug!
				_frog.play_animation("hug")
				_think_timer.stop()
				_chase_timer.stop()
				_panic_timer.stop()
				hand.hug()
				_frog.velocity = Vector2.ZERO
			else:
				# we're too shy. run away!
				_panic()
		else:
			if friend and not friend.is_hugging() and (run_target - _frog.global_position).length() > PINCER_DISTANCE:
				# our friend will help us; don't run towards the hand, run behind our friend
				run_target = friend.global_position + (friend.global_position - run_target).normalized() * PINCER_DISTANCE
			else:
				# we have no friend; run towards the hand
				pass
			
			_frog.velocity = (run_target - _frog.global_position).normalized() * _frog.run_speed
	elif not _panic_timer.is_stopped():
		# if we're panicking, we continue running in our randomly chosen direction
		pass

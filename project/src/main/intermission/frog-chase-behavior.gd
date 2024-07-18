extends CreatureBehavior
## Defines how a frog chases the player's cursor.

## If the frog gets within this distance of the player's hand, they will hug it.
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
var hand: Hand:
	set(new_hand):
		if hand:
			hand.hug_finished.disconnect(_on_hand_hug_finished)
		hand = new_hand
		if hand:
			hand.hug_finished.connect(_on_hand_hug_finished)

var _frog: RunningFrog
var _chase_count := 0

func start_behavior(new_frog: Node) -> void:
	_frog = new_frog
	%ThinkTimer.start(randf_range(0, 0.1))
	_frog.run("chase")
	_chase()


## Stops any timers and resets any transient data for this behavior.
func stop_behavior(_new_frog: Node) -> void:
	# disconnect signals
	friend = null
	hand = null
	_frog = null
	_chase_count = 0
	
	%ThinkTimer.stop()
	%ChaseTimer.stop()
	%PanicTimer.stop()


func _chase() -> void:
	%PanicTimer.stop()
	var wait_time := CHASE_DURATION * randf_range(0.8, 1.2)
	if _chase_count == 0:
		# the first time we chase, we are more persistent
		wait_time *= 2
	%ChaseTimer.start(wait_time)
	_chase_count += 1


func _panic() -> void:
	%ChaseTimer.stop()
	%PanicTimer.start(PANIC_DURATION * randf_range(0.8, 1.2))
	_frog.velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * _frog.run_speed


func _on_panic_timer_timeout() -> void:
	if hand.hugged_fingers >= hand.huggable_fingers and randf() < 0.5:
		# oh no, we can't hug the hand! continue panicking!
		%PanicTimer.start(SUPER_PANIC_DURATION * randf_range(0.8, 1.2))
		_frog.velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * _frog.run_speed
	else:
		_chase()


func _on_chase_timer_timeout() -> void:
	_panic()


func _on_hand_hug_finished() -> void:
	if not _frog.is_hugging():
		return
	
	_frog.run("chase")
	%ThinkTimer.start()
	_panic()
	_frog.soon_position += _frog.velocity.normalized() * 40
	_frog.update_position()


func _on_think_timer_timeout() -> void:
	if not hand or hand.huggable_fingers < 1:
		return
	
	var run_target := hand.global_position + HAND_CATCH_OFFSET

	if not %ChaseTimer.is_stopped():
		if ((run_target - _frog.global_position).length() < HUG_DISTANCE) and hand.resting:
			# we're close enough for a hug
			if hand.hugged_fingers < hand.huggable_fingers:
				# we caught the hand... hug!
				_frog.play_animation("hug")
				%ThinkTimer.stop()
				%ChaseTimer.stop()
				%PanicTimer.stop()
				hand.hug()
				_frog.velocity = Vector2.ZERO
			else:
				# we're too shy. run away!
				_panic()
		else:
			if friend and not friend.is_hugging() and (run_target - _frog.global_position).length() > PINCER_DISTANCE:
				# our friend will help us; don't run towards the hand, run behind our friend
				run_target = friend.global_position + (friend.global_position - run_target).normalized() \
						* PINCER_DISTANCE
			else:
				# we have no friend; run towards the hand
				pass
			
			_frog.velocity = (run_target - _frog.global_position).normalized() * _frog.run_speed
	elif not %PanicTimer.is_stopped():
		# if we're panicking, we continue running in our randomly chosen direction
		pass

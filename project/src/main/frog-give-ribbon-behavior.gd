extends CreatureBehavior
## Defines how a frog chases the player's cursor.

## If the frog gets within this distance of the player's hand, they will give them a ribbon.
const GIVE_RIBBON_DISTANCE := 40.0

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

## the hand to chase
var hand: Hand:
	set(new_hand):
		if hand:
			hand.disconnect("hug_finished", Callable(self, "_on_hand_hug_finished"))
		hand = new_hand
		if hand:
			hand.hug_finished.connect(_on_hand_hug_finished)

var _frog: RunningFrog
var _chase_count := 0

@onready var _chase_timer := $ChaseTimer
@onready var _panic_timer := $PanicTimer
@onready var _think_timer := $ThinkTimer
@onready var _ribbon_sfx := $RibbonSfx


func start_behavior(new_frog: Node) -> void:
	_frog = new_frog
	_think_timer.start(randf_range(0, 0.1))
	_frog.run("chase_with_ribbon")
	_chase()


## Stops any timers and resets any transient data for this behavior.
func stop_behavior(_new_frog: Node) -> void:
	# disconnect signals
	hand = null
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


func _on_panic_timer_timeout() -> void:
	if hand.ribbon and randf() < 0.5:
		# oh no, we can't give away our ribbon! continue panicking!
		_panic_timer.start(SUPER_PANIC_DURATION * randf_range(0.8, 1.2))
		_frog.velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * _frog.run_speed
	else:
		_chase()


func _on_chase_timer_timeout() -> void:
	_panic()


func _on_hand_hug_finished() -> void:
	if not _frog.is_hugging():
		return
	
	_frog.run("chase")
	_think_timer.start()
	_panic()
	_frog.soon_position += _frog.velocity.normalized() * 40
	_frog.update_position()


func _on_think_timer_timeout() -> void:
	if not hand:
		return
	
	var run_target := hand.global_position + HAND_CATCH_OFFSET

	if not _chase_timer.is_stopped():
		if ((run_target - _frog.global_position).length() < GIVE_RIBBON_DISTANCE) and hand.resting:
			# we're close enough for a hug
			if not hand.ribbon:
				# we caught the hand... give it a ribbon and run away
				_think_timer.stop()
				_chase_timer.stop()
				_panic_timer.stop()
				
				hand.ribbon = true
				_frog.velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * _frog.run_speed
				_frog.run(_frog.random_run_animation_name())
				_frog.finished_give_ribbon.emit()
				
				_ribbon_sfx.pitch_scale = randf_range(0.8, 1.2)
				_ribbon_sfx.play()
			else:
				# we're too shy. run away!
				_panic()
		else:
			_frog.velocity = (run_target - _frog.global_position).normalized() * _frog.run_speed
	elif not _panic_timer.is_stopped():
		# if we're panicking, we continue running in our randomly chosen direction
		pass

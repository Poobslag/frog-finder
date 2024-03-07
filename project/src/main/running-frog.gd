class_name RunningFrog
extends Sprite2D
## Frog which performs different activities such as chasing the player's cursor.

@warning_ignore("unused_signal")
signal reached_dance_target

@warning_ignore("unused_signal")
signal finished_dance

@warning_ignore("unused_signal")
signal finished_give_ribbon

const RUN_SPEED := 150.0

## frogs move in a jerky way. soon_position stores the location where the frog will blink to after a delay
var soon_position: Vector2

var run_speed := RUN_SPEED
var run_animation_name := "run1"
var velocity := Vector2.ZERO

@onready var behavior: CreatureBehavior

func _ready() -> void:
	_randomize_run_style()
	_refresh_run_speed()


func _physics_process(delta: float) -> void:
	soon_position += velocity * delta
	var viewport_rect_size := get_viewport_rect().size
	soon_position.x = clamp(soon_position.x, -200, viewport_rect_size.x + 200)
	soon_position.y = clamp(soon_position.y, -200, viewport_rect_size.y + 200)


func is_hugging() -> bool:
	return %AnimationPlayer.current_animation == "hug"


## Puts the frog into 'chase mode'.
##
## In chase mode, the frog runs after the hand and tries to hug it.
##
## Parameters:
## 	'hand': The hand to chase.
##
## 	'friend': Another frog which affects this frog's pathfinding. As long as our friend is chasing the hand, we will
## 		chase our friend instead. This prevents frogs from clustering too tightly.
func chase(hand: Hand, friend: RunningFrog) -> void:
	%ChaseBehavior.hand = hand
	%ChaseBehavior.friend = friend
	_start_behavior(%ChaseBehavior)


## Puts the frog into 'dance mode'.
##
## In dance mode, the frog runs to the middle of the screen, does a little dance and then runs away.
func dance(frogs: Array, dance_target: Vector2) -> void:
	%DanceBehavior.frogs = frogs
	%DanceBehavior.dance_target = dance_target
	_start_behavior(%DanceBehavior)


func give_ribbon(hand: Hand) -> void:
	%GiveRibbonBehavior.hand = hand
	_start_behavior(%GiveRibbonBehavior)


## Instantly move the frog in the specified direction.
##
## This blinks them to a new location, and is used during dance animations.
func shimmy(dir: Vector2) -> void:
	position += dir * scale
	soon_position = position


## Updates the frog's position to their soon_position.
##
## This is called periodically to result in a jerky movement effect.
func update_position() -> void:
	flip_h = true if soon_position < position else false
	position = soon_position


## Play a running animation.
##
## The animation parameter is optional. If omitted, each frog is randomly assigned a unique running animation which
## will play.
##
## Parameters:
## 	'animation_name': (Optional) The animation name of the run animation to play. If omitted, the frog's default
## 		run animation will play.
func run(animation_name := "") -> void:
	if animation_name:
		run_animation_name = animation_name
	%AnimationPlayer.play(run_animation_name)


func play_animation(animation_name: String) -> void:
	%AnimationPlayer.play(animation_name)


func stop_animation() -> void:
	if %AnimationPlayer.is_playing():
		%AnimationPlayer.stop()
	else:
		# Stopping the AnimationPlayer when no animation is playing resets the frog to a specific animation frame. This
		# results in visual tic which interrupts things like dancing, so we don't do it.
		pass


## Returns a random run animation name. Some run animations are more rare than others.
func random_run_animation_name() -> String:
	var result: String
	
	# some running animations are much more common than others
	if randf() < 0.8:
		# arms straight down, like holding suitcases
		result = "run2"
	elif randf() < 0.8:
		# arms moving up and down, like an exaggerated jog
		result = "run3"
	else:
		# arms forward, like trying to catch something
		result = "run1"
	
	return result


## Randomize the frog's running speed and run animation.
func _randomize_run_style() -> void:
	run_speed = RUN_SPEED * randf_range(0.8, 1.2)
	run_animation_name = random_run_animation_name()


## Assigns a new behavior to the frog, such as 'chasing the hand' or 'dancing'.
##
## Parameters:
## 	'new_behavior': The frog's new behavior, such as 'chasing the hand' or 'dancing'.
func _start_behavior(new_behavior: CreatureBehavior) -> void:
	behavior = new_behavior
	new_behavior.start_behavior(self)


func _refresh_run_speed() -> void:
	%AnimationPlayer.speed_scale = run_speed / 150.0

class_name RunningFrog
extends Sprite
## Frog which performs different activities such as chasing the player's cursor.

# warning-ignore:unused_signal
signal reached_dance_target

# warning-ignore:unused_signal
signal finished_dance

const RUN_SPEED := 150.0

## frogs move in a jerky way. soon_position stores the location where the frog will blink to after a delay
var soon_position: Vector2 setget set_soon_position

var run_speed := RUN_SPEED
var run_animation_name := "run1"
var velocity := Vector2.ZERO

onready var _animation_player := $AnimationPlayer
onready var _chase_behavior := $ChaseBehavior
onready var _dance_behavior := $DanceBehavior

onready var behavior: CreatureBehavior

func _ready() -> void:
	_randomize_run_style()
	_refresh_run_speed()


func _physics_process(delta: float) -> void:
	soon_position += velocity * delta
	var viewport_rect_size := get_viewport_rect().size
	soon_position.x = clamp(soon_position.x, -200, viewport_rect_size.x + 200)
	soon_position.y = clamp(soon_position.y, -200, viewport_rect_size.y + 200)


func is_hugging() -> bool:
	return _animation_player.current_animation == "hug"


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
	_chase_behavior.hand = hand
	_chase_behavior.friend = friend
	_start_behavior(_chase_behavior)


## Puts the frog into 'dance mode'.
##
## In dance mode, the frog runs to the middle of the screen, does a little dance and then runs away.
func dance(frogs: Array, dance_target: Vector2) -> void:
	_dance_behavior.frogs = frogs
	_dance_behavior.dance_target = dance_target
	_start_behavior(_dance_behavior)


## Instantly move the frog in the specified direction.
##
## This blinks them to a new location, and is used during dance animations.
func shimmy(dir: Vector2) -> void:
	position += dir * scale
	soon_position = position


## Updates the frog's position to their soon_position.
##
## This is called periodically to result in a jerky movement effect.
func move() -> void:
	flip_h = true if soon_position > position else false
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
	_animation_player.play(run_animation_name)


func play_animation(name: String) -> void:
	_animation_player.play(name)


func stop_animation() -> void:
	_animation_player.stop()


func set_soon_position(new_soon_position: Vector2) -> void:
	soon_position = new_soon_position
	position = new_soon_position


## Randomize the frog's running speed and run animation.
func _randomize_run_style() -> void:
	run_speed = RUN_SPEED * rand_range(0.8, 1.2)
	
	# some running animations are much more common than others
	if randf() > 0.2:
		# arms straight down, like holding suitcases
		run_animation_name = "run2"
	elif randf() > 0.2:
		# arms moving up and down, like an exaggerated jog
		run_animation_name = "run3"
	else:
		# arms forward, like trying to catch something
		run_animation_name = "run1"


## Assigns a new behavior to the frog, such as 'chasing the hand' or 'dancing'.
##
## Parameters:
## 	'new_behavior': The frog's new behavior, such as 'chasing the hand' or 'dancing'.
func _start_behavior(new_behavior: CreatureBehavior) -> void:
	behavior = new_behavior
	new_behavior.start_behavior(self)


func _refresh_run_speed() -> void:
	_animation_player.playback_speed = run_speed / 150.0

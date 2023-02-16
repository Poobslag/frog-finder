class_name RunningFrog
extends Sprite
## Frog which can perform different activities such as chasing the player's cursor.

const RUN_SPEED := 150.0

## frogs move in a jerky way. soon_position stores the location where the frog will blink to after a delay
var soon_position: Vector2 setget set_soon_position

var run_speed := RUN_SPEED
var velocity := Vector2.ZERO

onready var _animation_player := $AnimationPlayer
onready var _chase_behavior := $ChaseBehavior

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


func chase(hand: Hand, friend: RunningFrog) -> void:
	_chase_behavior.hand = hand
	_chase_behavior.friend = friend
	_start_behavior(_chase_behavior)


func move() -> void:
	flip_h = true if soon_position > position else false
	position = soon_position


func run() -> void:
	_animation_player.play("chase")


func play_animation(name: String) -> void:
	_animation_player.play(name)


func stop_animation() -> void:
	_animation_player.stop()


func set_soon_position(new_soon_position: Vector2) -> void:
	soon_position = new_soon_position
	position = new_soon_position


## Randomize the frog's running speed.
func _randomize_run_style() -> void:
	run_speed = RUN_SPEED * rand_range(0.8, 1.2)


func _start_behavior(new_behavior: CreatureBehavior) -> void:
	behavior = new_behavior
	new_behavior.start_behavior(self)


func _refresh_run_speed() -> void:
	_animation_player.playback_speed = run_speed / 150.0

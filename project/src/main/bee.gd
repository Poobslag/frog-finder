class_name Bee
extends Sprite2D
## A bee which appears during bee intermissions.
##
## Flies around and visits flowers.

## Maximum pollen the bee can hold. A higher value makes bees spend more time at flowers.
const POLLEN_CAPACITY := 16

## The sprite's default offset, giving it a vertical offset like it is hovering in midair.
const OFFSET_DEFAULT := Vector2(0, -80)

## Bees move in a jerky way. soon_position stores the location where the bee will blink to after a delay
var soon_position: Vector2

## Bees move in a jerky way. soon_offset stores the location where the bee will blink to after a delay
var soon_offset: Vector2 = OFFSET_DEFAULT

## pollen currently being carried by this bee
var pollen_count := randi_range(0, POLLEN_CAPACITY - 1)

var velocity := Vector2.ZERO
var fly_speed := 100.0 * randf_range(0.8, 1.2)

## 'true' if the bee has been flying for a long time without picking up or dropping off pollen. This makes the bee
## turn red and travel faster.
var frustrated := false

func _ready() -> void:
	soon_position = position
	soon_offset = offset
	
	chase()


func _physics_process(delta: float) -> void:
	soon_position += velocity * delta
	var viewport_rect_size := get_viewport_rect().size
	soon_position.x = clamp(soon_position.x, -200, viewport_rect_size.x + 200)
	soon_position.y = clamp(soon_position.y, -200, viewport_rect_size.y + 200)


## Puts the bee into 'chase mode'.
func chase() -> void:
	%ChaseBehavior.start_behavior(self)


## Updates the bee's position to their soon_position.
##
## This is called periodically to result in a jerky movement effect.
func update_position() -> void:
	flip_h = true if soon_position < position else false
	position = soon_position
	offset = soon_offset + Vector2(0, randf_range(-10, 10))
	frame = (frame + randi_range(1, 5)) % 6
	if frustrated:
		frame += 6


func _on_wiggle_timer_timeout() -> void:
	update_position()

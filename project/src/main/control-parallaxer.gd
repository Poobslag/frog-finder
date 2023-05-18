extends Node
## Moves the parent control in the opposite direction of the mouse to create a parallax effect

## The parent control's position before being modified by the parallax effect
var unmodified_position: Vector2

## The number of pixels the parent control should move in response to the mouse
@export var parallax_pixels: float = 16.0

@onready var parent := get_parent()

func _ready() -> void:
	unmodified_position = parent.position


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var viewport_rect_size := get_viewport().get_visible_rect().size
		
		# convert the mouse event's X/Y coordinates into the range [-1.0, 1.0]
		var mouse_coords: Vector2
		mouse_coords.x = inverse_lerp(0, viewport_rect_size.x, event.position.x)
		mouse_coords.y = inverse_lerp(0, viewport_rect_size.y, event.position.y)
		mouse_coords = mouse_coords * 2 - Vector2.ONE
		
		# combine the calculated parallax position with the parent control's cached position
		parent.position = unmodified_position - mouse_coords * parallax_pixels * 0.5

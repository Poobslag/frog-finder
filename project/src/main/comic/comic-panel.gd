@tool
extends Control
## Shows a panel within a comic page.

## The node which renders the border of the comic panel.
@onready var _frame := $Frame

## The node which renders the inner contents of the comic panel.
@onready var _contents := $Contents

## The modulate property to apply to both the border and inner contents of the comic panel.
@export var panel_modulate: Color = Color.WHITE:
	set(new_panel_modulate):
		panel_modulate = new_panel_modulate
		_refresh_panel_modulate()

func _ready() -> void:
	_refresh_panel_modulate()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_frame = $Frame
	_contents = $Contents


## Applies our 'panel_modulate' property to the border and inner contents of the comic panel.
func _refresh_panel_modulate() -> void:
	if not is_inside_tree():
		return
	
	_frame.self_modulate = panel_modulate
	_contents.self_modulate = panel_modulate

@tool
extends Control
## Shows a panel within a comic page.

## The modulate property to apply to both the border and inner contents of the comic panel.
@export var panel_modulate: Color = Color.WHITE:
	set(new_panel_modulate):
		panel_modulate = new_panel_modulate
		_refresh_panel_modulate()

func _ready() -> void:
	_refresh_panel_modulate()


## Applies our 'panel_modulate' property to the border and inner contents of the comic panel.
func _refresh_panel_modulate() -> void:
	if not is_inside_tree():
		return
	
	%Frame.self_modulate = panel_modulate
	%Contents.self_modulate = panel_modulate

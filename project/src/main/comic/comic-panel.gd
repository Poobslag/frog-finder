@tool
extends Control
## Shows a panel within a comic page.

const DEFAULT_ANIMATION_LIBRARY_PATH := "res://src/main/comic/default-frame-player-animation-library.tres"

## The modulate property to apply to both the border and inner contents of the comic panel.
@export var panel_modulate: Color = Color.WHITE:
	set(new_panel_modulate):
		panel_modulate = new_panel_modulate
		_refresh_panel_modulate()

func _ready() -> void:
	if Engine.is_editor_hint():
		_ensure_unique_animation_library()
	_refresh_panel_modulate()


## Creates an editable copy of the default parent animation library, if necessary.
##
## The parent animation library is read-only, but also includes some useful defaults. This method lets us reuse them
## while still allowing changes.
func _ensure_unique_animation_library() -> void:
	var animation_library: AnimationLibrary = %FramePlayer.get_animation_library("")
	if animation_library.resource_path != DEFAULT_ANIMATION_LIBRARY_PATH:
		# animation library is already unique; do not make another copy
		return
	
	if get_tree().edited_scene_root == self:
		# don't modify the ComicPanel scene itself; only modify descendents
		return
	
	var new_animation_library := AnimationLibrary.new()
	for animation_name in animation_library.get_animation_list():
		var new_animation := animation_library.get_animation(animation_name).duplicate(true)
		new_animation_library.add_animation(animation_name, new_animation)
	
	%FramePlayer.remove_animation_library("")
	%FramePlayer.add_animation_library("", new_animation_library)
	notify_property_list_changed()
	
	var relative_path := get_tree().edited_scene_root.get_parent().get_path_to(self)
	print("Duplicated animation library for editing: %s." % [relative_path])


## Applies our 'panel_modulate' property to the border and inner contents of the comic panel.
func _refresh_panel_modulate() -> void:
	if not is_inside_tree():
		return
	
	%Frame.self_modulate = panel_modulate
	%Contents.self_modulate = panel_modulate

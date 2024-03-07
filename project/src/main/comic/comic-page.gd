@tool
class_name ComicPage
extends Control
## Shows and animates several comic panels which tell a story.
##
## These comic panels are shown with a 'conductor' which is an AnimationPlayer which kicks off other animations.

## This 'stop' property can be toggled in the Godot editor to reset the comic to its default state.
##
## This is useful when editing the comic. We need the panels visible to make changes, but want them invisible when we
## save.
@warning_ignore("unused_private_class_variable")
@export var _stop: bool:
	set(value):
		if not value:
			# only reset the animation in the editor when the '_reset_animation' property is toggled
			return
		stop()

## This 'show_all' property can be toggled in the Godot editor to make all panels visible.
##
## This is useful when editing the comic. We need the panels visible to make changes.
@warning_ignore("unused_private_class_variable")
@export var _show_all: bool:
	set(value):
		if not value:
			# only reset the animation in the editor when the '_reset_animation' property is toggled
			return
		show_all()

## Gradually fades the comic visible or invisible.
var _fade_tween: Tween

func _ready() -> void:
	# hide; avoid blocking input
	visible = false

## Launches the comic animation.
##
## If the comic animation is already playing, this method resets it first.
func play() -> void:
	# reset the animation first, to avoid scenarios where some panels are visible when the animation starts
	stop()
	
	%Conductor.play("play")


func is_playing() -> bool:
	return %Conductor.is_playing()


## Immediately stops the comic and makes the comic page invisible.
##
## Player-visible game logic should use fade_out() instead, since it's jarring for the comic to suddenly blink out of
## view.
func stop() -> void:
	# hide; avoid blocking input
	visible = false
	
	%Conductor.play("RESET")
	for frame_animation_player in get_tree().get_nodes_in_group("frame_animation_players"):
		frame_animation_player.play("RESET")
	%SfxPlayer.stop()


## Immediately makes the comic page and all panels visible.
func show_all() -> void:
	visible = true
	for child in get_children():
		if child.name.begins_with("ComicPanel"):
			child.visible = true
			child.modulate = Color.WHITE


## Skips the comic forward or backward.
##
## Parameters:
## 	'delta': The number of seconds to skip. If this number is positive, the comic will skip forward. If negative, the
## 		comic will skip backward.
func advance(delta: float) -> void:
	%Conductor.advance(delta)
	var new_playback_position: float = %SfxPlayer.get_playback_position() + delta
	if new_playback_position > %SfxPlayer.stream.get_length():
		%SfxPlayer.stop()
	else:
		%SfxPlayer.seek(new_playback_position)


## Gradually fades the comic into view.
##
## This is called by the conductor's animations in lieu of explicitly tweening/setting the modulate and visible
## properties directly. If the conductor directly tweened/set the modulate and visible properties, there would be
## weirder edge cases when interrupting the animations.
func fade_in() -> void:
	if not visible:
		modulate = Color.TRANSPARENT
	
	visible = true
	
	_fade_tween = Utils.recreate_tween(self, _fade_tween)
	_fade_tween.tween_property(self, "modulate", Color.WHITE, 0.25)


## Gradually fades the comic out of view.
##
## This is called by the conductor's animations in lieu of explicitly tweening/setting the modulate and visible
## properties directly. If the conductor directly tweened/set the modulate and visible properties, there would be
## weirder edge cases when interrupting the animations.
func fade_out() -> void:
	_fade_tween = Utils.recreate_tween(self, _fade_tween)
	_fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.25)
	_fade_tween.tween_callback(stop)


func _on_skip_button_pressed() -> void:
	fade_out()

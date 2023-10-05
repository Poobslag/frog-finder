@tool
class_name DanceAnimations
extends AnimationPlayer
## Plays simple looped 4-frame dance animations.
##
## Each animation has a simple name like 'coy1', 'shuffle2_flip'. Each animation is a short 1-2 second loop. These
## simple animations are strung together by a choreographer to create more complex dances.
##
## To create a new dance, add a new dance animation like 'hips1' to the AnimationPlayer, and toggle the 'Update Dances'
## editor setting. This will automatically update metadata such as the 'Dance Names' and 'Frames By Dance Name', and
## will also generate a flipped version of the dance.

# Animations which do not correspond to dances.
const NON_DANCE_ANIMS := [
	"RESET"
]

## Dance names like 'coy' or 'shuffle'.
##
## Variants like 'coy2' or 'coy1_flip' are all considered the same dance.
@export var dance_names: Array[String]

## key: (String) Dance name like 'coy'
## value: (Array, String) List of animation names like ['coy1', 'coy1_flip'...]
@export var animation_names_by_dance_name: Dictionary

## key: (String) Dance name like 'coy'
## value: (Array, int) List of animation frames like [52, 53, 54...]
@export var frames_by_dance_name: Dictionary

## An editor toggle which creates flipped copies of all animations, and stores dance data
@warning_ignore("unused_private_class_variable")
@export var _update_dances: bool : set = update_dances

## Creates flipped copies of all animations, and stores dance data.
##
## This takes all animations like 'coy1' and creates new animations like 'coy1_flip' with all of the values flipped.
## These flipped dances orient the frog in the other direction, facing left instead of right or vice-versa.
##
## Also updates our dance metadata from the AnimationPlayer's dance animations. This includes the dance names, and
## frames used for each dance.
func update_dances(value: bool) -> void:
	if not value:
		# only update dances in the editor when the '_update_dances' property is toggled
		return
	
	_flip_animations()
	_save_dances()


## Updates our dance metadata from the AnimationPlayer's dance animations.
##
## This includes the dance names, and frames used for each dance.
func _save_dances() -> void:
	_save_dance_names()
	_save_animation_names_by_dance_name()
	_save_frames_by_dance_name()


## Populates dance_names with animations from our animation list.
func _save_dance_names() -> void:
	var dance_set := {}
	
	for animation_name in get_animation_list():
		if animation_name in NON_DANCE_ANIMS:
			continue
		
		dance_set[_dance_name_from_animation_name(animation_name)] = true
	
	dance_names.assign(dance_set.keys())


## Populates animation_names_by_dance_name with animations from our animation list.
func _save_animation_names_by_dance_name() -> void:
	animation_names_by_dance_name.clear()
	
	for animation_name in get_animation_list():
		if animation_name in NON_DANCE_ANIMS:
			continue
		
		var dance_name := _dance_name_from_animation_name(animation_name)
		if not animation_names_by_dance_name.has(dance_name):
			animation_names_by_dance_name[dance_name] = []
		animation_names_by_dance_name[dance_name].append(animation_name)


## Populates frames_by_dance_name with animations from our animation list.
func _save_frames_by_dance_name() -> void:
	var frame_sets_by_dance_name := {}
	
	for animation_name in get_animation_list():
		if animation_name in NON_DANCE_ANIMS:
			continue
		
		var dance_name := _dance_name_from_animation_name(animation_name)
		var animation := get_animation(animation_name)
		for track_idx in range(animation.get_track_count()):
			if animation.track_get_path(track_idx).get_concatenated_subnames() == "frame":
				for key_idx in animation.track_get_key_count(track_idx):
					var frame: int = animation.track_get_key_value(track_idx, key_idx)
					
					if not frame_sets_by_dance_name.has(dance_name):
						frame_sets_by_dance_name[dance_name] = {}
					frame_sets_by_dance_name[dance_name][frame] = true
	
	frames_by_dance_name.clear()
	for dance_name in frame_sets_by_dance_name.keys():
		var frames: Array = frame_sets_by_dance_name[dance_name].keys().duplicate()
		frames.sort()
		frames_by_dance_name[dance_name] = frames


## Converts an animation name from our animation list into a dance name.
##
## 	'hips1' -> 'hips'
## 	'hips1_flip' -> 'hips'
func _dance_name_from_animation_name(animation_name: String) -> String:
	var dance_name := animation_name
	dance_name = dance_name.trim_suffix("_flip")
	dance_name = dance_name.rstrip("0123456789")
	return dance_name


## Generates flipped versions of every animation in our animation list.
func _flip_animations() -> void:
	for animation_name in get_animation_list():
		if animation_name in NON_DANCE_ANIMS:
			continue

		if animation_name.ends_with("_flip"):
			get_animation_library("").remove_animation(animation_name)

	for old_animation_name in get_animation_list():
		_flip_animation(old_animation_name)


## Creates a flipped copy of an animation.
##
## This takes an animation name like 'coy1' and creates a new animation like 'coy1_flip' with all of the values
## flipped. These flipped dances orient the frog in the other direction, facing left instead of right or vice-versa.
func _flip_animation(old_animation_name: String) -> void:
	if old_animation_name in NON_DANCE_ANIMS:
		return
	
	var old_animation: Animation = get_animation_library("").get_animation(old_animation_name)
	var new_animation_name := "%s_flip" % [old_animation_name]
	var new_animation: Animation = old_animation.duplicate()
	
	for track_idx in range(new_animation.get_track_count()):
		match new_animation.track_get_type(track_idx):
			Animation.TYPE_VALUE: _flip_value_track(new_animation, track_idx)
			Animation.TYPE_METHOD: _flip_method_track(new_animation, track_idx)
	
	get_animation_library("").add_animation(new_animation_name, new_animation)


## Inverts the values of a value track, so that left is right and vice-versa.
func _flip_value_track(animation: Animation, track_idx: int) -> void:
	match animation.track_get_path(track_idx).get_concatenated_subnames():
		"flip_h": _flip_flip_h_track(animation, track_idx)


## Inverts the values of a method track, so that left is right and vice-versa.
func _flip_method_track(animation: Animation, track_idx: int) -> void:
	for key_idx in range(animation.track_get_key_count(track_idx)):
		match animation.method_track_get_name(track_idx, key_idx):
			"shimmy": _flip_shimmy_key(animation, track_idx, key_idx)


## Inverts the values of a 'flip_h' animation track.
func _flip_flip_h_track(animation: Animation, track_idx: int) -> void:
	for key_idx in range(animation.track_get_key_count(track_idx)):
		var old_value: bool = animation.track_get_key_value(track_idx, key_idx)
		animation.track_set_key_value(track_idx, key_idx, !old_value)


## Inverts the values of a 'shimmy' method call, flipping the values over the x axis.
func _flip_shimmy_key(animation: Animation, track_idx: int, key_idx: int) -> void:
	var old_name := animation.method_track_get_name(track_idx, key_idx)
	var old_params := animation.method_track_get_params(track_idx, key_idx)
	var new_params := []
	for old_param in old_params:
		new_params.append(old_param * Vector2(-1, 1))
	
	animation.track_set_key_value(track_idx, key_idx, {"method": old_name, "args": new_params})

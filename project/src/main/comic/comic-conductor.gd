extends AnimationPlayer
## Launches comic panel animations and plays a sound effect track.

## Threshold where the comic adjusts its visuals to sync back up with the sfx.
const DESYNC_THRESHOLD_MSEC := 100

@export var sfx_player_path: NodePath

## Plays a sound effect track.
##
## Comic sound effects are merged into a single track. This avoids copyright concerns from distributing licensed .wav
## files, requires less coding, less audio editing, and less disk space.
@onready var _sfx_player: AudioStreamPlayer = get_node(sfx_player_path)

## The offset in seconds for the position of the AudioStreamPlayer's sound effect relative to the AnimationPlayer's
## animation.
##
## If this is a positive number, the AudioStreamPlayer will be ahead of the AnimationPlayer. The value is calculated by
## examining the SfxPlayer key in the comic conductor's 'play' animation.
var _sfx_offset: float = 0.0

func _ready() -> void:
	_calculate_sfx_offset()


## Calculates the offset in seconds for the position of the AudioStreamPlayer's sound effect relative to the
## AnimationPlayer's animation, storing the result in our _sfx_offset field.
##
## This value is calculated by examining the SfxPlayer key in our 'play' animation.
func _calculate_sfx_offset() -> void:
	var animation: Animation = get_animation_library("").get_animation("play")
	if animation == null:
		push_error("Comic conductor's 'play' animation was not found; cannot sync sfx")
		return
	
	var track_index := _find_sfx_track(animation)
	if track_index != -1:
		# We've found an appropriate sfx track in our animation library. Calculate the sfx_offset.
		_sfx_offset = 0.0
		
		# incorporate the animation track's from_position parameter value
		_sfx_offset += animation.method_track_get_params(track_index, 0)[0]
		
		# incorporate the animation track's key time
		_sfx_offset += animation.track_get_key_time(track_index, 0)
	else:
		# We couldn't find an appropriate sfx track in our animation library. Assign the sfx_offset value a default
		# value of 0.0.
		_sfx_offset = 0.0


## Returns the index of the animation track with an SfxPlayer.play() animation key.
##
## If the SfxPlayer.play() animation key cannot be found, this pushes a warning and returns -1.
##
## Parameters:
## 	'animation': The animation which launches comic panel animations and plays a sound effect track
##
## Returns:
## 	The index of the animation track with an SfxPlayer.play() animation key. Returns -1 if no animation track can be
## 	found.
func _find_sfx_track(animation: Animation) -> int:
	# Convert a path like '../SfxPlayer' to be relative to the AnimationPlayer root node like 'SfxPlayer'
	var sfx_player_animation_path := get_node(root_node).get_path_to(_sfx_player)
	
	# Locate the SfxPlayer animation track
	var track_index: int = animation.find_track(sfx_player_animation_path, Animation.TYPE_METHOD)
	if track_index == -1:
		push_warning("Could not find sfx method track")
	
	# Ensure there is only one key for the SfxPlayer animation track.
	#
	# The SfxPlayer animation track should only include a single 'play' call.
	var track_key_count := animation.track_get_key_count(track_index)
	if track_index != -1 and track_key_count != 1:
		push_warning("Bad animation key count for comic conductor's sfx track: %s != 1" % [track_key_count])
		track_index = -1
	
	# Ensure the SfxPlayer animation track calls the AudioStreamPlayer.play() method.
	#
	# The SfxPlayer animation track should only call 'play'.
	var track_method_name := animation.method_track_get_name(track_index, 0)
	if track_index != -1 and track_method_name != "play":
		push_warning("Bad method name for comic conductor's sfx track: %s != %s" % [track_method_name, "play"])
		track_index = -1
	
	return track_index


## Every once in awhile, we check to make sure the sfx are in sync with our animations.
##
## These can fall out of sync if the game runs too slow for some reason. I can force it to happen by dragging the
## window around.
func _on_timer_timeout() -> void:
	if not current_animation == "play":
		return
	
	if not _sfx_player.playing:
		return
	
	var desync_amount: float = _sfx_player.get_playback_position() - current_animation_position - _sfx_offset
	
	if abs(desync_amount * 1000) > DESYNC_THRESHOLD_MSEC:
		advance(desync_amount)

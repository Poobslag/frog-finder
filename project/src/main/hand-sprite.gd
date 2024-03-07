class_name HandSprite
extends Sprite2D
## Sprite2D which shows the main part of the player's cursor.
##
## The player's cursor is made up of a main hand sprite, as well as sometimes detached fingers, hearts or even frogs.
## This script only handles animating the main hand sprite.

enum State {
	NONE, ## The hand is not visible
	THREE_FINGERS, ## The hand has three fingers left
	TWO_FINGERS, ## The hand has two fingers left
	ONE_FINGER, ## The hand has one finger left
	NO_FINGERS, ## The hand has no fingers left
}

var state: int = State.ONE_FINGER : set = set_state

## List of int animation frames which the sprite should alternate between
var wiggle_frames := []

func _ready() -> void:
	_refresh_state()


func set_state(new_state: int) -> void:
	state = new_state
	_refresh_state()


func _refresh_state() -> void:
	if not is_inside_tree():
		return
	
	match state:
		State.NONE:
			wiggle_frames = [0]
		State.THREE_FINGERS:
			wiggle_frames = [1, 2]
		State.TWO_FINGERS:
			wiggle_frames = [3, 4]
		State.ONE_FINGER:
			wiggle_frames = [5, 6, 7, 8]
		State.NO_FINGERS:
			wiggle_frames = [9, 10]
	$WiggleTimer.assign_wiggle_frame()

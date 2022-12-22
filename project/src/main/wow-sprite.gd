extends WiggleSprite
## A 'wow sprite' which surrounds a single clickable icon.
##
## Clickable menu icons look like cards used in puzzles, but can be clicked while they are face-up. For this reason we
## surround them with a 'wow sprite' so that the player understands they are interactive.

const WOW_COUNT := 4

func _ready() -> void:
	var wow_sprite_index := Utils.randi_range(0, WOW_COUNT - 1)
	wiggle_frames = [wow_sprite_index * 2 + 0, wow_sprite_index * 2 + 1]
	assign_wiggle_frame()

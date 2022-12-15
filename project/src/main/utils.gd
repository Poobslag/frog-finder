tool
class_name Utils
## Contains global utilities.

## Returns the scancode for a keypress event, or -1 if the event is not a keypress event.
static func key_scancode(event: InputEvent) -> int:
	var scancode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	return scancode


## Returns a random value from the specified array.
static func rand_value(values: Array):
	return values[randi() % values.size()]


## Generates a pseudo-random 32-bit signed integer between from and to (inclusive).
static func randi_range(from: int, to: int) -> int:
	return randi() % (to + 1 - from) + from


## Updates a card sprite's texture, hframes and vframes.
##
## This method assumes each frame is 240x240, which is used for the small square frog finder cards.
static func assign_card_texture(sprite: Sprite, texture: Texture) -> void:
	sprite.texture = texture
	# warning-ignore:integer_division
	sprite.hframes = int(ceil(texture.get_width() / 240))
	# warning-ignore:integer_division
	sprite.vframes = int(ceil(texture.get_height() / 240))


## Gets the substring after the first occurrence of a separator.
static func substring_after(s: String, sep: String) -> String:
	if not sep:
		return s
	var pos := s.find(sep)
	return "" if pos == -1 else s.substr(pos + sep.length())


## Converts level indexes like [3, 0] into a player-friendly mission string like "4-1".
static func mission_string(world_index: int, level_index: int) -> String:
	return "%s-%s" % [world_index + 1, level_index + 1]

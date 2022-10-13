tool
extends Node

## Returns the scancode for a keypress event, or -1 if the event is not a keypress event.
static func key_scancode(event: InputEvent) -> int:
	var scancode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	return scancode


## Returns a random value from the specified array.
static func rand_value(values: Array):
	return values[randi() % values.size()]


## Updates a card sprite's texture, hframes and vframes.
##
## This method assumes each frame is 160x160, which is used for the small square frog finder cards.
static func assign_card_texture(sprite: Sprite, texture: Texture) -> void:
	sprite.texture = texture
	# warning-ignore:integer_division
	sprite.hframes = int(ceil(texture.get_width() / 160))
	# warning-ignore:integer_division
	sprite.vframes = int(ceil(texture.get_height() / 160))


## Gets the substring after the first occurrence of a separator.
static func substring_after(s: String, sep: String) -> String:
	if not sep:
		return s
	var pos := s.find(sep)
	return "" if pos == -1 else s.substr(pos + sep.length())

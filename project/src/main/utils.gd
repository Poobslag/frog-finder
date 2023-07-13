@tool
class_name Utils
## Contains global utilities.

const NUM_SCANCODES := {
	KEY_0: 0, KEY_1: 1, KEY_2: 2, KEY_3: 3, KEY_4: 4,
	KEY_5: 5, KEY_6: 6, KEY_7: 7, KEY_8: 8, KEY_9: 9,
}

## Returns [0-9] for a number key event, or -1 if the event is not a number key event.
static func key_num(event: InputEvent) -> int:
	return NUM_SCANCODES.get(key_scancode(event), -1)


## Returns the keycode for a keypress event, or -1 if the event is not a keypress event.
static func key_scancode(event: InputEvent) -> int:
	var keycode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		keycode = event.keycode
	return keycode


## Returns a random value from the specified array.
static func rand_value(values: Array):
	return values[randi() % values.size()]


## Updates a card sprite's texture, hframes and vframes.
##
## This method assumes each frame is 240x240, which is used for the small square frog finder cards.
static func assign_card_texture(sprite: Sprite2D, texture: Texture2D) -> void:
	sprite.texture = texture
	@warning_ignore("integer_division")
	sprite.hframes = int(ceil(texture.get_width() / 240)) if texture != null else 1
	@warning_ignore("integer_division")
	sprite.vframes = int(ceil(texture.get_height() / 240)) if texture != null else 1


## Gets the substring after the first occurrence of a separator.
static func substring_after(s: String, sep: String) -> String:
	if sep.is_empty():
		return s
	var pos := s.find(sep)
	return "" if pos == -1 else s.substr(pos + sep.length())


## Converts level indexes like [3, 0] into a player-friendly mission string like "4-1".
static func mission_string(world_index: int, level_index: int) -> String:
	return "%s-%s" % [world_index + 1, level_index + 1]


## Returns a new array containing a - b.
##
## The input arrays are not modified. This code is adapted from Apache Common Collections.
static func subtract(a: Array, b: Array) -> Array:
	var result := []
	var bag := {}
	for item in b:
		if not bag.has(item):
			bag[item] = 0
		bag[item] += 1
	for item in a:
		if bag.has(item):
			bag[item] -= 1
			if bag[item] == 0:
				bag.erase(item)
		else:
			result.append(item)
	return result


## Erases 'chars' characters from the string 's' starting from 'position'.
static func erase(s: String, position: int, chars: int) -> String:
	return s.left(int(max(position, 0))) + s.substr(position + chars, + s.length() - (position + chars))

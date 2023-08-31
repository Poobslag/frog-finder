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


## Creates/recreates a tween, invalidating it if it is already active.
##
## This is useful for SceneTreeTweens. These are designed to be created and thrown away, but tweening the same
## property with multiple tweens creates unpredictable behavior. This recreate_tween method lets us ensure each
## property is only being modified by a single tween.
##
## Parameters:
## 	'node': The scene tree node which the tween should be bound to. This affects details like whether the tween
## 		stops if the player pauses the game.
##
## 	'tween': The tween to invalidate. Can be null.
##
## Returns:
## 	A new SceneTreeTween bound to the specified node.
static func recreate_tween(node: Node, tween: Tween) -> Tween:
	kill_tween(tween)
	return node.create_tween()


## Invalidates a tween if it is already active.
##
## Killing a SceneTreeTween requires a null check, but this makes it a one-liner.
##
## Parameters:
## 	'tween': The tween to invalidate. Can be null.
##
## Returns:
## 	null
static func kill_tween(tween: Tween) -> Tween:
	if tween:
		tween.kill()
	return null


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


## Converts the float keys and values in a Dictionary to int values.
##
## Godot's JSON parser converts all ints into floats, so we need to change them back. See Godot #9499
## (https://github.com/godotengine/godot/issues/9499)
static func convert_dict_floats_to_ints(dict: Dictionary) -> void:
	for key in dict.keys():
		var new_key = key
		var new_value = dict[key]
		
		if new_key is float:
			dict.erase(new_key)
			new_key = int(new_key)
		
		if new_value is float:
			new_value = int(new_value)
		
		dict[new_key] = new_value

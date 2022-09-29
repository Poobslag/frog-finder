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
	sprite.hframes = int(ceil(texture.get_width() / 160))
	sprite.vframes = int(ceil(texture.get_height() / 160))

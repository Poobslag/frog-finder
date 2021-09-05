extends Node

"""
Returns the scancode for a keypress event, or -1 if the event is not a keypress event.
"""
static func key_scancode(event: InputEvent) -> int:
	var scancode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	return scancode

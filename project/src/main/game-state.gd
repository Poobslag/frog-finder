class_name GameState
extends Node

export (bool) var can_interact: bool = true
onready var flip_timer := $FlipTimer

func reset() -> void:
	can_interact = true
	flip_timer.stop()

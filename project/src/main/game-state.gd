extends Node

onready var flip_timer := $FlipTimer
var can_interact: bool = true

func reset() -> void:
	can_interact = true
	flip_timer.stop()

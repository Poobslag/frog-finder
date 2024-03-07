class_name GameState
extends Node
## Tracks the game state, like whether the player is playing a puzzle and whether they're allowed to flip cards.

@export var can_interact: bool = true
@onready var flip_timer := %FlipTimer

func reset() -> void:
	can_interact = true
	%FlipTimer.stop()

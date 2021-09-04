extends Node

onready var _intermission_panel := $IntermissionPanel

func _ready() -> void:
	_intermission_panel.show_intermission_panel()


func _input(event: InputEvent) -> void:
	match key_scancode(event):
		KEY_F:
			var card: CardControl = $IntermissionPanel/IntermissionCards.create_card()
			card.card_front_type = CardControl.CardType.FROG
			
			# must add as a child so its sprites/frames will be initialized
			add_child(card)
			card.queue_free()
			
			card.show_front()
			_intermission_panel.add_level_result(card)


"""
Returns the scancode for a keypress event, or -1 if the event is not a keypress event.
"""
static func key_scancode(event: InputEvent) -> int:
	var scancode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	return scancode

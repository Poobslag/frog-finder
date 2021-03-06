extends Node

onready var _intermission_panel := $IntermissionPanel

func _ready() -> void:
	_intermission_panel.show_intermission_panel()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_F:
			var card: CardControl = $IntermissionPanel/IntermissionCards.create_card()
			card.card_front_type = CardControl.CardType.FROG
			
			# must add as a child so its sprites/frames will be initialized
			add_child(card)
			card.queue_free()
			
			card.show_front()
			_intermission_panel.add_level_result(card)
		KEY_S:
			_intermission_panel.start_shark_spawn_timer(3)
		KEY_1:
			$Hand.fingers
			_intermission_panel.start_frog_hug_timer(1, 5)
		KEY_2:
			_intermission_panel.start_frog_hug_timer(2, 12)
		KEY_3:
			_intermission_panel.start_frog_hug_timer(3, 30)

class_name IntermissionPanel
extends Panel

onready var _intermission_cards: LevelCards = $IntermissionCards

var card_positions := [
	Vector2(0, 3), Vector2(1, 3), Vector2(2, 3), Vector2(3, 3),
	Vector2(2.5, 2), Vector2(1.5, 2), Vector2(0.5, 2),
	Vector2(1, 1), Vector2(2, 1),
	Vector2(1.5, 0),
]

var cards: Array = []
var next_card_index := 0

func _ready() -> void:
	for i in range(0, card_positions.size()):
		var card := _intermission_cards.create_card()
		_intermission_cards.add_card(card, card_positions[i])
		cards.append(card)


func is_full() -> bool:
	return next_card_index >= cards.size()


func restart() -> void:
	next_card_index = 0
	for card_obj in cards:
		var card: CardControl = card_obj
		card.reset()


func add_level_result(found_card: CardControl) -> void:
	if is_full():
		return
	
	var next_card: CardControl = cards[next_card_index]
	next_card.copy_from(found_card)
	next_card.cheer()
	next_card_index += 1


func show_intermission_panel() -> void:
	visible = true

extends LevelRules
## Rules for 'pattern memory', a level where the player must memorize a binary 2D pattern and reveal cards without
## fish or sharks.
##
## Rules:
## 	1. Click any card which was not previously revealed.
## 	2. DO not click any other cards.

const ROW_COUNT := 5
const COL_COUNT := 6

## The number of cards in each row
const HEX_ROW_COUNTS := [5, 6, 7, 6, 5]

## The horizontal offset for each row of cards, measured in card widths
const HEX_X_OFFSETS := [1, 0.5, 0, 0.5, 1]

var _cards_to_hide := 99
var _remaining_cards_without_hiding := 0
var _allowed_hidden_lizard_count := 0
var _shark_chance := 0.5
var _unhidden_cards := []

func refresh_level_cards() -> void:
	if not level_cards:
		return
	level_cards.before_card_flipped.connect(_on_level_cards_before_card_flipped)
	level_cards.before_shark_found.connect(_on_level_cards_before_shark_found)


func add_cards() -> void:
	_unhidden_cards.clear()
	
	var hex_chance := 0.50
	var fill_in_sides := false
	var shark_percent := 0.50
	_cards_to_hide = 99
	_remaining_cards_without_hiding = 0
	_allowed_hidden_lizard_count = 0
	_shark_chance = 0.5
	
	match puzzle_difficulty:
		0:
			fill_in_sides = true
			_cards_to_hide = 1
			_remaining_cards_without_hiding = 3
			_allowed_hidden_lizard_count = randi_range(1, 2)
			_shark_chance = 0.3
		1:
			fill_in_sides = true
			_cards_to_hide = 3
			_remaining_cards_without_hiding = 2
			_allowed_hidden_lizard_count = randi_range(0, 2)
			_shark_chance = 0.4
		2:
			fill_in_sides = true
		3:
			_cards_to_hide = 1
			_remaining_cards_without_hiding = 3
			_allowed_hidden_lizard_count = randi_range(1, 2)
			shark_percent = 0.7
			_shark_chance = 0.3
		4:
			_remaining_cards_without_hiding = 2
			_cards_to_hide = 1
			_allowed_hidden_lizard_count = randi_range(2, 4)
			shark_percent = 0.60
			_shark_chance = 0.4
		5:
			_cards_to_hide = 1
			_remaining_cards_without_hiding = 5
			_allowed_hidden_lizard_count = randi_range(1, 2)
			shark_percent = 0.2
			_shark_chance = 0.5
		6:
			_cards_to_hide = 1
			_allowed_hidden_lizard_count = randi_range(0, 1)
			shark_percent = 0.60
			_shark_chance = 0.6
		7:
			_cards_to_hide = 2
			_shark_chance = 0.7
		8:
			_cards_to_hide = Utils.rand_value([3, 99])
			_shark_chance = 0.8
	
	if randf() < hex_chance:
		# arrange the tiles in a hex grid
		for y in range(ROW_COUNT):
			for x in range(HEX_ROW_COUNTS[y]):
				var card := level_cards.create_card()
				card.card_front_type = CardControl.CardType.LIZARD
				level_cards.add_card(card, Vector2(x + HEX_X_OFFSETS[y], y))
		
		if fill_in_sides:
			for y in range(ROW_COUNT):
				for x in [HEX_X_OFFSETS[y], HEX_X_OFFSETS[y] + HEX_ROW_COUNTS[y] - 1]:
					var card := level_cards.get_card(Vector2(x, y))
					card.card_front_type = CardControl.CardType.ARROW
					card.card_front_details = ""
					card.show_front()
	else:
		# arrange the tiles normally
		for y in range(ROW_COUNT):
			for x in range(COL_COUNT):
				var card := level_cards.create_card()
				card.card_front_type = CardControl.CardType.LIZARD
				level_cards.add_card(card, Vector2(x, y))
		
		if fill_in_sides:
			for y in range(ROW_COUNT):
				for x in [0, COL_COUNT - 1]:
					var card := level_cards.get_card(Vector2(x, y))
					card.card_front_type = CardControl.CardType.ARROW
					card.card_front_details = ""
					card.show_front()
	
	# calculate the shark count
	var hideable_card_count := level_cards.get_cards().size()
	if fill_in_sides:
		hideable_card_count -= 2 * ROW_COUNT
	var remaining_shark_count := int(shark_percent * hideable_card_count) + randi_range(-1, 1)
	
	# make some fish/shark cards and reveal them
	var cards := level_cards.get_cards()
	cards.shuffle()
	while remaining_shark_count > 0:
		var card: CardControl = cards.pop_front()
		if card.card_front_type != CardControl.CardType.LIZARD:
			# we only change lizards; leave blank spots alone
			continue
		
		if not _shark_card():
			card.card_front_type = CardControl.CardType.SHARK
		else:
			card.card_front_type = CardControl.CardType.FISH
		card.show_front()
		_unhidden_cards.append(card)
		remaining_shark_count -= 1


func _shark_card() -> CardControl:
	var result: CardControl
	for card in level_cards.get_cards():
		if card.card_front_type == CardControl.CardType.SHARK:
			result = card
			break
	return result


func _before_lizard_flipped(lizard_card: CardControl) -> void:
	# hide some of the other cards
	var remaining_cards_to_hide := _cards_to_hide
	if _remaining_cards_without_hiding > 0:
		_remaining_cards_without_hiding -= 1
		remaining_cards_to_hide = 0
	while not _unhidden_cards.is_empty() and remaining_cards_to_hide:
		var card: CardControl = _unhidden_cards.pop_front()
		card.hide_front()
		remaining_cards_to_hide -= 1
		if remaining_cards_to_hide <= 0:
			break
	
	# if they've turned over enough lizards, change it to a frog
	if _hidden_lizard_count() - 1 <= _allowed_hidden_lizard_count:
		lizard_card.card_front_type = CardControl.CardType.FROG


func _hidden_lizard_count() -> int:
	var result := 0
	for card in level_cards.get_cards():
		if not card.is_front_shown() and card.card_front_type == CardControl.CardType.LIZARD:
			result += 1
	return result


func _before_fish_flipped(fish_card: CardControl) -> void:
	if randf() < _shark_chance:
		var shark_card := _shark_card()
		fish_card.copy_from(shark_card)
		shark_card.card_front_type = CardControl.CardType.FISH


func _on_level_cards_before_card_flipped(card: CardControl) -> void:
	match card.card_front_type:
		CardControl.CardType.LIZARD:
			_before_lizard_flipped(card)
		CardControl.CardType.FISH:
			_before_fish_flipped(card)


func _on_level_cards_before_shark_found(_card: CardControl) -> void:
	for card in level_cards.get_cards():
		if not card.is_front_shown() and card.card_front_type == CardControl.CardType.FISH:
			card.show_front()

extends LevelRules
## Rules for 'frodoku', a level with rules similar to Sudoku.
##
## Rules:
##
## 	1. Do not click a card in the same row as a lizard
## 	2. Do not click a card in the same column as a lizard
## 	3. Do not click a card in the same 3x2 region as a lizard. These groups are color-coded, which is why some of
## 		the cards are red and others are blue.

const ROW_COUNT := 6
const COL_COUNT := 6

## Methods used to check whether two cells conflict. Cells conflict if they are in the same row, the same column, or
## the same 3x2 region.
var _compare_methods: Array[Callable] = [
		## Returns 'true' if the two specified cells are in the same row.
		func(pos_1: Vector2, pos_2: Vector2) -> bool:
			return pos_1.y == pos_2.y,
		## Returns 'true' if the two specified cells are in the same column.
		func(pos_1: Vector2, pos_2: Vector2) -> bool:
			return pos_1.x == pos_2.x,
		## Returns 'true' if the two specified cells are in the same 3x2 region.
		func(pos_1: Vector2, pos_2: Vector2) -> bool:
			return _region(pos_1) == _region(pos_2),
	]

## The number of valid cards the player must click before finding a frog. (The player will always find a frog if five
## frogs are revealed.)
var _remaining_good_moves := 99

## The number of invalid cards the player must click before finding a shark. (The player will always find a shark if
## they click the last invalid cell.)
var _remaining_bad_moves := 99

func refresh_level_cards() -> void:
	if not level_cards:
		return
	level_cards.before_card_flipped.connect(_on_level_cards_before_card_flipped)
	level_cards.before_shark_found.connect(_on_level_cards_before_shark_found)


func add_cards() -> void:
	_remaining_good_moves = 99
	_remaining_bad_moves = 99
	var revealed_lizard_count := 0
	var revealed_bad_move_count := 0
	var hidden_bad_move_count := 0
	
	# if 'true', one full row, column or 3x2 region of "bad moves" will be revealed
	var easy_reveal := false
	
	match puzzle_difficulty:
		0:
			_remaining_good_moves = 0
			revealed_lizard_count = 1
			easy_reveal = true
		1:
			_remaining_good_moves = randi_range(0, 1)
			_remaining_bad_moves = 3
			revealed_lizard_count = randi_range(1, 2)
			easy_reveal = true
		2:
			_remaining_good_moves = randi_range(1, 2)
			_remaining_bad_moves = 3
			revealed_lizard_count = 2
			easy_reveal = true
		3:
			_remaining_good_moves = randi_range(2, 3)
			_remaining_bad_moves = 3
			revealed_lizard_count = 3
			revealed_bad_move_count = 12
		4:
			_remaining_good_moves = randi_range(3, 5)
			_remaining_bad_moves = 3
			revealed_lizard_count = randi_range(1, 2)
			revealed_bad_move_count = 9
		5:
			_remaining_good_moves = randi_range(3, 7)
			_remaining_bad_moves = 2
			revealed_lizard_count = 1
			revealed_bad_move_count = 6
		6:
			_remaining_good_moves = randi_range(3, 10)
			_remaining_bad_moves = 1
		7:
			_remaining_good_moves = randi_range(5, 7)
			_remaining_bad_moves = randi_range(0, 1)
			revealed_lizard_count = 1
			revealed_bad_move_count = 3
		8:
			_remaining_bad_moves = 0
			revealed_lizard_count = 2
			revealed_bad_move_count = 5
		
	
	for y in range(ROW_COUNT):
		for x in range(COL_COUNT):
			@warning_ignore("integer_division")
			var red: bool = int((x % 6) / 3) + int((y % 4) / 2) == 1
			var card := level_cards.create_card()
			card.card_back_details = "r" if red else ""
			card.card_front_type = CardControl.CardType.FISH
			level_cards.add_card(card, Vector2(x, y))
	
	var used_rows := {}
	var used_cols := {}
	var used_regions := {}
	
	var cell_positions := level_cards.get_cell_positions()
	cell_positions.shuffle()
	for cell_pos in cell_positions:
		var row: int = int(cell_pos.y)
		var col: int = int(cell_pos.x)
		var region := _region(cell_pos)
		var card := level_cards.get_card(cell_pos)
		
		if region in used_regions or row in used_rows or col in used_cols:
			continue
		
		used_rows[row] = true
		used_cols[col] = true
		used_regions[region] = true
		card.card_front_type = CardControl.CardType.LIZARD
	
	_reveal_lizards(revealed_lizard_count)
	if easy_reveal:
		var method: Callable = Utils.rand_value(_compare_methods)
		for card in level_cards.get_cards():
			if _conflicting_lizard(card, method):
				card.show_front()
	_reveal_bad_moves(revealed_bad_move_count)
	_hide_bad_moves(hidden_bad_move_count)


## Randomly reveals lizards at the start of a puzzle.
##
## Parameters:
## 	'count': The number of lizards to reveal.
func _reveal_lizards(count: int) -> void:
	if count == 0:
		return
	
	var remaining := count
	var cards := level_cards.get_cards()
	cards.shuffle()
	for card in cards:
		if not card.is_front_shown() and card.card_front_type == CardControl.CardType.LIZARD:
			card.show_front()
			remaining -= 1
			if remaining <= 0:
				break


## Randomly reveals fish at the start of a puzzle.
##
## Parameters:
## 	'count': The number of fish to reveal.
func _reveal_bad_moves(count: int) -> void:
	if count == 0:
		return
	
	var remaining := count
	var cards := level_cards.get_cards()
	cards.shuffle()
	for card in cards:
		if not card.is_front_shown() and _conflicting_lizard(card):
			card.show_front()
			remaining -= 1
			if remaining <= 0:
				break


## Randomly hides shown fish at the start of a puzzle.
##
## Parameters:
## 	'count': The number of fish to hide.
func _hide_bad_moves(count: int) -> void:
	if count == 0:
		return
	
	var remaining := count
	var cards := level_cards.get_cards()
	cards.shuffle()
	for card in cards:
		if card.is_front_shown() and card.card_front_type == CardControl.CardType.FISH \
				and _conflicting_lizard(card):
			card.hide_front()
			remaining -= 1
			if remaining <= 0:
				break


func _shown_lizard_cards() -> Array[CardControl]:
	var result: Array[CardControl] = []
	for card in level_cards.get_cards():
		if card.is_front_shown() and card.card_front_type == CardControl.CardType.LIZARD:
			result.append(card)
	return result


## Returns a shown lizard card in the same row, column, or 3x2 region as the specified card, if one exists.
##
## Parameters:
## 	'card': The card to check for conflicts.
##
## 	'method': (Optional) The method used to compare whether two cells conflict. If omitted, the cell will be compared
## 		by row, column, and 3x2 region
func _conflicting_lizard(card: CardControl, method: Callable = Callable()) -> CardControl:
	var result: CardControl
	var methods: Array[Callable]
	if method:
		# a comparator method was provided; find a lizard which conflicts in one specific way
		methods = [method]
	else:
		# no comparator method was provided; find a lizard which conflicts in any of three ways
		methods = _compare_methods
	
	var pos := level_cards.get_cell_pos(card)
	for lizard_card in _shown_lizard_cards():
		var lizard_pos := level_cards.get_cell_pos(lizard_card)
		for current_method in methods:
			if current_method.call(lizard_pos, pos):
				result = lizard_card
				break
		if result:
			break
	return result


## Returns the number of invalid cards which the player could click to reveal a fish/shark.
func _possible_mistake_count() -> int:
	var result := 0
	for card in level_cards.get_cards():
		if card.is_front_shown():
			continue
		if _conflicting_lizard(card):
			result += 1
	return result


## Returns an int corresponding to the cell's 3x2 region.
func _region(cell_pos: Vector2) -> int:
	var region: int = 0
	region += int(cell_pos.x / 3)
	region += 2 * int(cell_pos.y / 2)
	return region


func _on_level_cards_before_card_flipped(card: CardControl) -> void:
	if card.card_front_type == CardControl.CardType.LIZARD:
		# the player found a lizard, they're on the right track
		
		if _shown_lizard_cards().size() == 5:
			# last lizard; make it a frog
			card.card_front_type = CardControl.CardType.FROG
		
		if _remaining_good_moves <= 0:
			# we've done a lot of good moves; make it a frog
			card.card_front_type = CardControl.CardType.FROG
		else:
			_remaining_good_moves -= 1
	elif card.card_front_type == CardControl.CardType.FISH:
		if _conflicting_lizard(card):
			# the player found a fish which conflicts with the shown lizards
			if _remaining_bad_moves <= 0 or _possible_mistake_count() == 1:
				card.card_front_type = CardControl.CardType.SHARK
			else:
				_remaining_bad_moves -= 1
		else:
			if _remaining_good_moves <= 0:
				# we've done a lot of good moves; make it a frog
				card.card_front_type = CardControl.CardType.FROG
			else:
				_remaining_good_moves -= 1
				card.card_front_type = CardControl.CardType.ARROW
				card.card_front_details = ""


func _on_level_cards_before_shark_found(shark_card: CardControl) -> void:
	var other_cards := level_cards.get_cards()
	other_cards.shuffle()
	var new_frog_card: CardControl
	for other_card in other_cards:
		if not other_card.is_front_shown() and other_card.card_front_type == CardControl.CardType.LIZARD:
			new_frog_card = other_card
	new_frog_card.card_front_type = CardControl.CardType.FROG
	
	# reveal all cards in the row/column/region
	var shark_card_pos := level_cards.get_cell_pos(shark_card)
	for compare_method in _compare_methods:
		if _conflicting_lizard(shark_card, compare_method):
			for card in level_cards.get_cards():
				var card_pos := level_cards.get_cell_pos(card)
				if card == shark_card:
					# don't mess with the card they're flipping
					continue
				elif compare_method.call(card_pos, shark_card_pos):
					# show the hidden cards in the same row/column/region
					if not card.is_front_shown():
						card.card_front_type = CardControl.CardType.SHARK
						card.show_front()
				else:
					# hide the cards not in the row/column/region
					card.hide_front()
			break

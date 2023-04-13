extends LevelRules
## Rules for 'frodoku', a level with rules similar to Sudoku.
##
## Rules:
##
## 	1. Do not click a card in the same row as a lizard
## 	2. Do not click a card in the same column as a lizard
## 	3. Do not click a card in the same 3x2 rectangle as a lizard. These groups are color-coded, which is why some of
## 		the cards are red and others are blue.

const ROW_COUNT := 6
const COL_COUNT := 6

var _remaining_good_moves := 99
var _remaining_bad_moves := 99

func refresh_level_cards_path() -> void:
	super.refresh_level_cards_path()
	if not level_cards:
		return
	level_cards.connect("before_card_flipped",Callable(self,"_on_LevelCards_before_card_flipped"))
	level_cards.connect("before_shark_found",Callable(self,"_on_LevelCards_before_shark_found"))


func add_cards() -> void:
	_remaining_good_moves = 99
	_remaining_bad_moves = 99
	var revealed_lizard_count := 0
	var revealed_bad_move_count := 0
	var hidden_bad_move_count := 0
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
		var row: int = cell_pos.y
		var col: int = cell_pos.x
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
		var method: String = Utils.rand_value(["compare_by_row", "compare_by_column", "compare_by_region"])
		for card in level_cards.get_cards():
			if _conflicting_lizard(card, method):
				card.show_front()
	_reveal_bad_moves(revealed_bad_move_count)
	_hide_bad_moves(hidden_bad_move_count)


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


func _hide_bad_moves(count: int) -> void:
	if count == 0:
		return
	
	var remaining := count
	var cards := level_cards.get_cards()
	cards.shuffle()
	for card in cards:
		if card.is_front_shown() and card.card_front_type == CardControl.CardType.FISH\
				and _conflicting_lizard(card):
			card.hide_front()
			remaining -= 1
			if remaining <= 0:
				break


func _revealed_lizard_count() -> int:
	var count := 0
	for card in level_cards.get_cards():
		if card.is_front_shown() and card.card_front_type == CardControl.CardType.LIZARD:
			count += 1
	return count


func _shown_lizard_cards() -> Array:
	var result := []
	for card in level_cards.get_cards():
		if card.is_front_shown() and card.card_front_type == CardControl.CardType.LIZARD:
			result.append(card)
	return result


func _conflicting_lizard(card: CardControl, method: String = "") -> CardControl:
	var result: CardControl
	var methods: Array
	if method:
		# a comparator method was provided; find a lizard which conflicts in one specific way
		methods = [method]
	else:
		# no comparator method was provided; find a lizard which conflicts in any of three ways
		methods = ["compare_by_row", "compare_by_column", "compare_by_region"]
	
	var pos := level_cards.get_cell_pos(card)
	for lizard_card in _shown_lizard_cards():
		var lizard_pos := level_cards.get_cell_pos(lizard_card)
		for current_method in methods:
			if call(current_method, lizard_pos, pos):
				result = lizard_card
				break
		if result:
			break
	return result


func _on_LevelCards_before_card_flipped(card: CardControl) -> void:
	if card.card_front_type == CardControl.CardType.LIZARD:
		# the player found a lizard, they're on the right track
		
		if _revealed_lizard_count() == 5:
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
			if _remaining_bad_moves <= 0:
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


func _on_LevelCards_before_shark_found(shark_card: CardControl) -> void:
	var other_cards := level_cards.get_cards()
	other_cards.shuffle()
	var new_frog_card: CardControl
	for other_card in other_cards:
		if not other_card.is_front_shown() and other_card.card_front_type == CardControl.CardType.LIZARD:
			new_frog_card = other_card
	new_frog_card.card_front_type = CardControl.CardType.FROG
	
	# reveal all cards in the row/column/region
	var shark_card_pos := level_cards.get_cell_pos(shark_card)
	for compare_method in ["compare_by_row", "compare_by_column", "compare_by_region"]:
		if _conflicting_lizard(shark_card, compare_method):
			for card in level_cards.get_cards():
				var card_pos := level_cards.get_cell_pos(card)
				if card == shark_card:
					# don't mess with the card they're flipping
					continue
				elif call(compare_method, card_pos, shark_card_pos):
					# show the hidden cards in the same row/column/region
					if not card.is_front_shown():
						card.card_front_type = CardControl.CardType.SHARK
						card.show_front()
				else:
					# hide the cards not in the row/column/region
					card.hide_front()
			break


func compare_by_column(pos_1: Vector2, pos_2: Vector2) -> bool:
	return pos_1.x == pos_2.x


func compare_by_row(pos_1: Vector2, pos_2: Vector2) -> bool:
	return pos_1.y == pos_2.y


func compare_by_region(pos_1: Vector2, pos_2: Vector2) -> bool:
	return _region(pos_1) == _region(pos_2)


func _region(cell_pos: Vector2) -> int:
	var region: int = 0
	region += int(cell_pos.x / 3)
	region += 2 * int(cell_pos.y / 2)
	return region

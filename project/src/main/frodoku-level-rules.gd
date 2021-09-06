extends LevelRules

const ROW_COUNT := 6
const COL_COUNT := 6

var random := RandomNumberGenerator.new()

var _remaining_good_moves := 99
var _remaining_bad_moves := 99

func _ready() -> void:
	random.randomize()


func refresh_level_cards_path() -> void:
	.refresh_level_cards_path()
	if not level_cards:
		return
	level_cards.connect("before_card_flipped", self, "_on_LevelCards_before_card_flipped")
	level_cards.connect("before_shark_found", self, "_on_LevelCards_before_shark_found")


func add_cards() -> void:
	_remaining_good_moves = 99
	_remaining_bad_moves = 99
	var _revealed_lizard_count := 0
	var _revealed_bad_move_count := 0
	var _hidden_bad_move_count := 0
	
	match puzzle_difficulty:
		0:
			_remaining_good_moves = 0
			_revealed_lizard_count = 1
			_revealed_bad_move_count = 99
			_hidden_bad_move_count = 1
		1:
			_remaining_good_moves = random.randi_range(0, 1)
			_remaining_bad_moves = 3
			_revealed_lizard_count = 1
			_revealed_bad_move_count = 99
			_hidden_bad_move_count = 3
		2:
			_remaining_good_moves = random.randi_range(1, 2)
			_remaining_bad_moves = 5
			_revealed_lizard_count = 2
			_revealed_bad_move_count = 16
		3:
			_remaining_good_moves = random.randi_range(2, 3)
			_remaining_bad_moves = 3
			_revealed_lizard_count = 3
			_revealed_bad_move_count = 14
		4:
			_remaining_good_moves = random.randi_range(3, 5)
			_remaining_bad_moves = 3
			_revealed_lizard_count = 2
			_revealed_bad_move_count = 10
		5:
			_remaining_good_moves = random.randi_range(3, 7)
			_remaining_bad_moves = 2
			_revealed_lizard_count = 1
			_revealed_bad_move_count = 6
		6:
			_remaining_good_moves = random.randi_range(3, 10)
			_remaining_bad_moves = 1
		7:
			_remaining_good_moves = random.randi_range(5, 7)
			_remaining_bad_moves = random.randi_range(0, 1)
			_revealed_lizard_count = 1
			_revealed_bad_move_count = 3
		8:
			_remaining_bad_moves = 0
			_revealed_lizard_count = 2
			_revealed_bad_move_count = 5
		
	
	for y in range(0, ROW_COUNT):
		for x in range(0, COL_COUNT):
			var red: bool = int((x % 6)/ 3) + int((y % 4) / 2) == 1
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
	
	_reveal_lizards(_revealed_lizard_count)
	_reveal_bad_moves(_revealed_bad_move_count)
	_hide_bad_moves(_hidden_bad_move_count)


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
		if not card.is_front_shown() and _card_conflicts_with_lizards(card):
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
				and _card_conflicts_with_lizards(card):
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


func _card_conflicts_with_lizards(card: CardControl) -> bool:
	var result := false
	for other_card in level_cards.get_cards():
		if other_card.is_front_shown() and other_card.card_front_type == CardControl.CardType.LIZARD:
			var pos := level_cards.get_cell_pos(card)
			var other_pos := level_cards.get_cell_pos(other_card)
			if pos.x == other_pos.x or pos.y == other_pos.y or _region(pos) == _region(other_pos):
				result = true
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
		if _card_conflicts_with_lizards(card):
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


func _on_LevelCards_before_shark_found() -> void:
	var other_cards := level_cards.get_cards()
	other_cards.shuffle()
	var new_frog_card: CardControl
	for other_card in other_cards:
		if not other_card.is_front_shown() and other_card.card_front_type == CardControl.CardType.LIZARD:
			new_frog_card = other_card
	
	_reveal_lizards(99)
	new_frog_card.card_front_type = CardControl.CardType.FROG


func _region(cell_pos: Vector2) -> int:
	var region: int = 0
	region += int(cell_pos.x / 3)
	region += 2 * int(cell_pos.y / 2)
	return region

extends LevelRules
## Rules for 'secret collect', a level where the player must find a red card with an arrow pointing to it.
##
## Rules:
## 	1. If possible, click a red card with an arrow pointing to it.
## 	2. Do not click any blue cards adjacent to cards you have already clicked.
## 	3. Click any blue card adjacent to a red card.
## 	4. Do not click any other cards.
##
## While these rules are simple, many other rules are implicit. If any arrows are revealed but you do not click a red
## card, you have violated rule 1. If you click any blue cards which are not adjacent to red cards, you have violated
## rule 3. If you select the wrong blue cards, you can be forced to break rule 2 or rule 3. It is important to plan
## ahead.

const ROW_COUNT := 5
const COL_COUNT := 7

## key: (Vector2) position of an unrevealed red card
## value: (bool) true
var _unexamined_secret_cell_positions := {}

var _remaining_mistakes := 0
var _lucky_chance := 0.0 # chance of flipping an arrow when placing adjacent to a secret

func refresh_level_cards_path() -> void:
	.refresh_level_cards_path()
	if not level_cards:
		return
	level_cards.connect("before_card_flipped", self, "_on_LevelCards_before_card_flipped")
	level_cards.connect("before_shark_found", self, "_on_LevelCards_before_shark_found")


func add_cards() -> void:
	_unexamined_secret_cell_positions.clear()
	
	for y in range(ROW_COUNT):
		for x in range(COL_COUNT):
			var card := level_cards.create_card()
			card.card_front_type = CardControl.CardType.FISH
			level_cards.add_card(card, Vector2(x, y))
	
	var remaining_card_positions := level_cards.get_cell_positions()
	remaining_card_positions.shuffle()
	
	var secret_count := 15
	var fish_count := 10
	_remaining_mistakes = 0
	var spoiler_arrow: bool = false
	_lucky_chance = 0.0
	
	match puzzle_difficulty:
		0:
			secret_count = 1
			fish_count = 1
			_remaining_mistakes = 5
			spoiler_arrow = true
		1:
			secret_count = 1
			fish_count = 1
			_remaining_mistakes = 3
		2:
			secret_count = 3
			fish_count = 3
			_remaining_mistakes = 3
			spoiler_arrow = true
		3:
			secret_count = 3
			fish_count = 2
			_lucky_chance = 0.60
			_remaining_mistakes = 2
		4:
			secret_count = 5
			fish_count = 3
			_lucky_chance = 0.30
			_remaining_mistakes = 2
		5:
			secret_count = 7
			fish_count = 5
			_lucky_chance = 0.20
			_remaining_mistakes = 1
		6:
			secret_count = 9
			fish_count = 6
			_lucky_chance = 0.12
			_remaining_mistakes = 1
		7:
			secret_count = 10
			fish_count = 8
			_lucky_chance = 0.08
			_remaining_mistakes = randi() % 2
		8:
			secret_count = 11
			fish_count = 9
			_lucky_chance = 0.01
			_remaining_mistakes = 0
	
	# determine the positions for safely clickable fish, and positions for secrets.
	# safely clickable fish are never adjacent
	var potential_secret_positions := []
	var potential_fish_positions := remaining_card_positions.duplicate()
	for _i in range(fish_count):
		if not potential_fish_positions:
			# no more fish positions
			break
		
		var card_position: Vector2 = potential_fish_positions.pop_front()
		for adjacent_direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			var adjacent_position: Vector2 = card_position + adjacent_direction
			var adjacent_position_index := potential_fish_positions.find(adjacent_position)
			if adjacent_position_index != -1:
				potential_fish_positions.remove(adjacent_position_index)
				potential_secret_positions.append(adjacent_position)
	
	# add secrets
	potential_secret_positions.shuffle()
	for i in range(secret_count):
		if not potential_secret_positions:
			# no more secret positions
			break
		
		var card_position: Vector2 = potential_secret_positions.pop_front()
		var card: CardControl = level_cards.get_card(card_position)
		if card.is_front_shown():
			# card is already flipped, possibly from a spoiler arrow
			continue
		
		card.card_back_details = "r"
		card.card_front_type = CardControl.CardType.SHARK
		_unexamined_secret_cell_positions[card_position] = true
		
		if secret_count == 1 and i == 0:
			# there is only one secret; we know it is a frog
			card.card_front_type = CardControl.CardType.FROG
		
		if spoiler_arrow and i == 0:
			_add_spoiler_arrow(card_position)


func _add_spoiler_arrow(frog_card_position: Vector2) -> void:
	var frog_card: CardControl = level_cards.get_card(frog_card_position)
	frog_card.card_front_type = CardControl.CardType.FROG
	
	# determine the position of the spoiler arrow
	var adjacent_cards := _adjacent_cards(frog_card)
	var spoiler_card: CardControl = adjacent_cards[0]
	var adjacent_cell_pos: Vector2 = level_cards.get_cell_pos(spoiler_card)
	
	# turn over the spoiler arrow, and point it towards the frog
	spoiler_card.show_front()
	spoiler_card.card_front_type = CardControl.CardType.ARROW
	match frog_card_position - adjacent_cell_pos:
		Vector2.DOWN:
			spoiler_card.card_front_details = "s"
		Vector2.UP:
			spoiler_card.card_front_details = "n"
		Vector2.RIGHT:
			spoiler_card.card_front_details = "e"
		Vector2.LEFT:
			spoiler_card.card_front_details = "w"


func _adjacent_cards(card: CardControl) -> Array:
	var result := []
	var card_position: Vector2 = level_cards.get_cell_pos(card)
	for adjacent_direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var adjacent_cell_pos: Vector2 = card_position + adjacent_direction
		if level_cards.has_card(adjacent_cell_pos):
			result.append(level_cards.get_card(adjacent_cell_pos))
	result.shuffle()
	return result


func _adjacent_to_face_up_card(card: CardControl) -> bool:
	var result := false
	for adjacent_card in _adjacent_cards(card):
		if adjacent_card.is_front_shown():
			result = true
			break
	return result


func _adjacent_to_unexamined_secret(card: CardControl) -> bool:
	var result := false
	for adjacent_card in _adjacent_cards(card):
		if _unexamined_secret_cell_positions.has(level_cards.get_cell_pos(adjacent_card)):
			result = true
			break
	return result


func _adjacent_to_frog(card: CardControl) -> bool:
	var result := false
	for adjacent_card in _adjacent_cards(card):
		if adjacent_card.card_front_type == CardControl.CardType.FROG:
			result = true
			break
	return result


func _frog_position() -> Vector2:
	var result: Vector2
	for card in level_cards.get_cards():
		if card.card_front_type == CardControl.CardType.FROG:
			result = level_cards.get_cell_pos(card)
			break
	return result


func _frog_position_known() -> bool:
	var result := false
	for card in level_cards.get_cards():
		if card.card_front_type == CardControl.CardType.FROG:
			result = true
			break
	return result


func _arrow_placed() -> bool:
	var result := false
	for card in level_cards.get_cards():
		if card.card_front_type == CardControl.CardType.ARROW:
			result = true
			break
	return result


func _on_or_adjacent_to_red_card(card: CardControl) -> bool:
	var result := false
	if card.card_back_details == "r":
		result = true
	else:
		for adjacent_card in _adjacent_cards(card):
			if adjacent_card.card_back_details == "r":
				result = true
				break
	return result


func _adjacent_face_up_cards(card: CardControl) -> Array:
	var result := []
	for adjacent_card in _adjacent_cards(card):
		if adjacent_card.is_front_shown():
			result.append(adjacent_card)
	return result


func _reveal_adjacent_sharks(card: CardControl) -> void:
	for adjacent_card in _adjacent_cards(card):
		if adjacent_card.is_front_shown():
			# already shown; don't reveal it
			continue
		adjacent_card.show_front()


func _before_fish_flipped(card: CardControl) -> void:
	var mistake := false
	if _adjacent_to_frog(card):
		# arrows are fun. let's not punish the player for revealing more arrows
		mistake = false
	elif _adjacent_to_face_up_card(card):
		mistake = true
	elif not _adjacent_to_unexamined_secret(card):
		mistake = true
	elif _arrow_placed():
		mistake = true
	
	if randf() < _lucky_chance and _adjacent_to_unexamined_secret(card) and not _frog_position_known():
		var adjacent_secret_card
		for adjacent_card in _adjacent_cards(card):
			var adjacent_cell_pos := level_cards.get_cell_pos(adjacent_card)
			if _unexamined_secret_cell_positions.has(adjacent_cell_pos):
				adjacent_secret_card = adjacent_card
				break
		adjacent_secret_card.card_front_type = CardControl.CardType.FROG
	
	for adjacent_card in _adjacent_cards(card):
		var adjacent_cell_pos := level_cards.get_cell_pos(adjacent_card)
		if _unexamined_secret_cell_positions.size() > 1:
			_unexamined_secret_cell_positions.erase(adjacent_cell_pos)
	
	if _unexamined_secret_cell_positions.size() == 1 and not _frog_position_known():
		var unexamined_secret_card := level_cards.get_card(_unexamined_secret_cell_positions.keys()[0])
		unexamined_secret_card.card_front_type = CardControl.CardType.FROG
		_unexamined_secret_cell_positions.clear()
	
	if _frog_position_known():
		var frog_position := _frog_position()
		var card_position := level_cards.get_cell_pos(card)
		
		var arrow_details := ""
		match frog_position - card_position:
			Vector2.UP: arrow_details = "n"
			Vector2.DOWN: arrow_details = "s"
			Vector2.LEFT: arrow_details = "w"
			Vector2.RIGHT: arrow_details = "e"
		if arrow_details:
			card.card_front_type = CardControl.CardType.ARROW
			card.card_front_details = arrow_details
	
	if mistake:
		if _remaining_mistakes > 0:
			_remaining_mistakes -= 1
		elif card.card_front_type == CardControl.CardType.FISH:
			# double check it's still a fish (it could have changed to an arrow)
			card.card_front_type = CardControl.CardType.SHARK
	
	if not mistake and card.card_front_type == CardControl.CardType.FISH:
		card.card_front_type = CardControl.CardType.LIZARD


func _on_LevelCards_before_card_flipped(card: CardControl) -> void:
	match card.card_front_type:
		CardControl.CardType.FISH:
			_before_fish_flipped(card)
		CardControl.CardType.FROG:
			pass
		CardControl.CardType.SHARK:
			# remove the card they clicked. otherwise it could be turned over as a frog immediately after
			_unexamined_secret_cell_positions.erase(level_cards.get_cell_pos(card))


func _on_LevelCards_before_shark_found(shark_card: CardControl) -> void:
	var adjacent_face_up_cards := _adjacent_face_up_cards(shark_card)
	if not _on_or_adjacent_to_red_card(shark_card):
		# if the player doesn't a card that's red, or next to a red card -- we reveal a sea of sharks and fish under the blue
		# cards.
		for card in level_cards.get_cards():
			if card == shark_card:
				continue
			if _on_or_adjacent_to_red_card(card):
				continue
			if card.is_front_shown():
				continue
			card.card_front_type = CardControl.CardType.SHARK if randf() < 0.5 else CardControl.CardType.FISH
			card.show_front()
	elif adjacent_face_up_cards:
		# if the player clicks adjacent to a face up card -- we hide everything except for those adjacent sharks.
		# hopefully the nice 'plus' shape makes them see that they shouldn't click adjacent
		for card in level_cards.get_cards():
			if card == shark_card:
				continue
			if card in adjacent_face_up_cards:
				continue
			if card.card_front_type == CardControl.CardType.ARROW:
				continue
			card.hide_front()
		for adjacent_card in adjacent_face_up_cards:
			_reveal_adjacent_sharks(adjacent_card)
	else:
		# if the player made a different mistake, we reveal arrows pointing to where the frog was
		if not _frog_position_known():
			var _unexamined_secret_cell_position: Vector2 = _unexamined_secret_cell_positions.keys()[0]
			var _unexamined_card := level_cards.get_card(_unexamined_secret_cell_position)
			_unexamined_card.card_front_type = CardControl.CardType.FROG
		
		var frog_position := _frog_position()
		var frog_card := level_cards.get_card(frog_position)
		frog_card.show_front()
		
		for adjacent_card in _adjacent_cards(frog_card):
			if not adjacent_card.is_front_shown() and adjacent_card.card_front_type == CardControl.CardType.FISH:
				var arrow_details := ""
				match frog_position - level_cards.get_cell_pos(adjacent_card):
					Vector2.UP: arrow_details = "n"
					Vector2.DOWN: arrow_details = "s"
					Vector2.LEFT: arrow_details = "w"
					Vector2.RIGHT: arrow_details = "e"
				if arrow_details:
					adjacent_card.card_front_type = CardControl.CardType.ARROW
					adjacent_card.card_front_details = arrow_details
					adjacent_card.show_front()

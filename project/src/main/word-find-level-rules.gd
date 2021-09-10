extends LevelRules

const ROW_COUNT := 6
const COL_COUNT := 8

var _cell_pos_to_revealed_letter := {}

var random := RandomNumberGenerator.new()
var _shark_chance: float = 0.5
var _frog_word_cards := {}

func _ready() -> void:
	random.randomize()


func refresh_level_cards_path() -> void:
	.refresh_level_cards_path()
	if not level_cards:
		return
	level_cards.connect("before_card_flipped", self, "_on_LevelCards_before_card_flipped")
	level_cards.connect("before_shark_found", self, "_on_LevelCards_before_shark_found")


func add_cards() -> void:
	_cell_pos_to_revealed_letter.clear()
	
	for y in range(0, ROW_COUNT):
		for x in range(0, COL_COUNT):
			var card := level_cards.create_card()
			card.card_front_type = CardControl.CardType.LETTER
			card.card_front_details = Utils.rand_value(["a", "d", "e", "h", "i", "k", "n", "s"])
			card.show_front()
			level_cards.add_card(card, Vector2(x, y))
	
	var _backwards_chance: float = 0.5
	var _frog_letter_chance: float = 0.5
	var _fish_letter_chance: float = 0.25
	_shark_chance = 0.5
	_frog_word_cards.clear()
	
	match puzzle_difficulty:
		0:
			_backwards_chance = 0.0
			_frog_letter_chance = 0.0
			_fish_letter_chance = 0.15
			_shark_chance = 0.3
		1:
			_backwards_chance = 0.0
			_frog_letter_chance = 0.2
			_fish_letter_chance = 0.20
			_shark_chance = 0.3
		2:
			_backwards_chance = 0.2
			_frog_letter_chance = 0.3
			_fish_letter_chance = 0.25
			_shark_chance = 0.3
		3:
			_backwards_chance = 0.3
			_frog_letter_chance = 0.5
			_fish_letter_chance = 0.30
			_shark_chance = 0.4
		4:
			_backwards_chance = 0.4
			_frog_letter_chance = 0.7
			_fish_letter_chance = 0.30
			_shark_chance = 0.5
		5:
			_backwards_chance = 0.4
			_frog_letter_chance = 0.9
			_fish_letter_chance = 0.40
			_shark_chance = 0.6
		6:
			_backwards_chance = 0.5
			_frog_letter_chance = 1.0
			_fish_letter_chance = 0.5
			_shark_chance = 0.7
		7:
			_backwards_chance = 0.5
			_frog_letter_chance = 1.0
			_fish_letter_chance = 0.7
			_shark_chance = 0.7
		8:
			_backwards_chance = 0.6
			_frog_letter_chance = 1.0
			_fish_letter_chance = 1.0
			_shark_chance = 1.0
	
	# add the word 'frog', turn over a letter in the word 'frog'
	if randf() < 0.5:
		# horizontal
		var word_start := Vector2()
		word_start.x = random.randi_range(0, COL_COUNT - 4)
		word_start.y = random.randi_range(0, ROW_COUNT - 1)
		var word := "frog" if randf() > _backwards_chance else "gorf"
		for i in range(0, 4):
			var frog_word_card := level_cards.get_card(Vector2(word_start.x + i, word_start.y))
			frog_word_card.card_front_details = word[i]
			_frog_word_cards[frog_word_card] = true
		var frog_card := level_cards.get_card(Vector2(word_start.x + random.randi_range(0, 3), word_start.y))
		frog_card.hide_front()
		frog_card.card_front_type = CardControl.CardType.FROG
	else:
		# vertical
		var word_start := Vector2()
		word_start.x = random.randi_range(0, COL_COUNT - 1)
		word_start.y = random.randi_range(0, ROW_COUNT - 4)
		var word := "frog" if randf() > _backwards_chance else "gorf"
		for i in range(0, 4):
			var frog_word_card := level_cards.get_card(Vector2(word_start.x, word_start.y + i))
			frog_word_card.card_front_details = word[i]
			_frog_word_cards[frog_word_card] = true
		var frog_card := level_cards.get_card(Vector2(word_start.x, word_start.y + random.randi_range(0, 3)))
		frog_card.hide_front()
		frog_card.card_front_type = CardControl.CardType.FROG
	
	# fill in the rest of the grid randomly, but make sure to never add the last letter in the word 'frog'
	var cards := level_cards.get_cards()
	cards.shuffle()
	for card_obj in cards:
		if card_obj in _frog_word_cards:
			continue
		
		if randf() > _frog_letter_chance:
			continue
		
		var card: CardControl = card_obj
		var frog_letters := ["f", "r", "o", "g"]
		frog_letters.shuffle()
		var good_letter := false
		for new_letter in frog_letters:
			card.card_front_details = new_letter
			if not _card_can_make_frog_word(card):
				good_letter = true
				break
		if not good_letter:
			card.card_front_details = Utils.rand_value(["a", "d", "e", "h", "i", "k", "n", "s"])
	
	# turn over other letters randomly, but make sure to never turn over a letter which can make a word 'frog'
	cards.shuffle()
	for card_obj in cards:
		if card_obj in _frog_word_cards:
			continue
		
		if randf() > _fish_letter_chance:
			continue
		
		var card: CardControl = card_obj
		card.hide_front()
		if _card_can_make_frog_word(card):
			card.show_front()
		else:
			card.card_front_type = CardControl.CardType.FISH
			card.card_front_details = ""


func _card_can_make_frog_word(card: CardControl) -> bool:
	var result := false
	var card_position := level_cards.get_cell_pos(card)
	
	# check horizontally...
	for x in range(0, card_position.x + 3):
		if x > COL_COUNT - 4:
			continue
		
		var card_word := ""
		for i in range(0, 4):
			var other_card := level_cards.get_card(Vector2(x + i, card_position.y))
			if not other_card.is_front_shown() or not other_card.card_front_type == CardControl.CardType.LETTER:
				card_word += "_"
			else:
				card_word += other_card.card_front_details
		
		if _matches("frog", card_word) or _matches("gorf", card_word):
			result = true
			break
	
	# check vertically...
	for y in range(0, card_position.y + 3):
		if y > ROW_COUNT - 4:
			continue
		
		var card_word := ""
		for i in range(0, 4):
			var other_card := level_cards.get_card(Vector2(card_position.x, y + i))
			if not other_card.is_front_shown() or not other_card.card_front_type == CardControl.CardType.LETTER:
				card_word += "_"
			else:
				card_word += other_card.card_front_details
		
		if _matches("frog", card_word) or _matches("gorf", card_word):
			result = true
			break
	
	return result


func _matches(word: String, pattern: String) -> bool:
	var result := true
	for i in range(0, word.length()):
		if pattern[i] == "_":
			continue
		if word[i] == pattern[i]:
			continue
		result = false
		break
	return result


func _frog_position() -> Vector2:
	var result: Vector2
	for card in level_cards.get_cards():
		if card.card_front_type == CardControl.CardType.FROG:
			result = level_cards.get_cell_pos(card)
			break
	return result


func _on_LevelCards_before_card_flipped(card: CardControl) -> void:
	if card.card_front_type == CardControl.CardType.FISH and randf() < _shark_chance:
		card.card_front_type = CardControl.CardType.SHARK


func _on_LevelCards_before_shark_found(_shark_card: CardControl) -> void:
	# hide non-frog letters
	for card in level_cards.get_cards():
		if not card.card_front_type == CardControl.CardType.LETTER:
			# only conceal letter cards
			continue
		if card in _frog_word_cards:
			# don't conceal the correct cards
			continue
		
		# conceal all other cards
		card.hide_front()
	
	level_cards.get_card(_frog_position()).show_front()

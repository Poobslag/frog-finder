extends LevelRules

var _cell_pos_to_revealed_letter := {}

var random := RandomNumberGenerator.new()

# words which have frogs but aren't 'frog'. these should not have any letters in common with any troll_shark_words,
# except for the 'R' in the third position
var troll_frog_words := [
	"freg/freg",
	"frig/frig",
	"forg/forg",
	"greg/greg",
	"froge/froge",
	"firgg/firgg",
	"forge/forge",
	"froog/froog",
	"froggo/froggo",
]

# words which have sharks but aren't 'shark'. these should not have any letters in common with any troll_frog_words,
# except for the 'R' in the third position
var troll_shark_words := [
	"shak/shak",
	"shrk/shrk",
	"sark/sark",
	"hark/hark",
	"sarkh/sarkh",
	"shrak/shrak",
	"sahrk/sahrk",
	"sherk/sherk",
]

# words which don't have frogs or sharks. these words are generally themed around the frog hiding, or the player
# making a mistake
var troll_silly_words := [
	"ha/ha",
	"hi/hi",
	"no/no",
	"fake/fake",
	"find/find",
	"fond/fond",
	"fish/fish",
	"hide/hide",
	"haha/haha",
	"gone/gone",
	"goof/goof",
	"ohno/ohno",
	"faker/faker",
	"snore/snore",
	"hidden/hidden",
	"friend/friend",
	"ignore/ignore",
	"heehee/heehee",
	"hahaha/hahaha",
]

func _ready() -> void:
	random.randomize()


func refresh_level_cards_path() -> void:
	.refresh_level_cards_path()
	if not level_cards:
		return
	level_cards.connect("before_frog_found", self, "_on_LevelCards_before_frog_found")
	level_cards.connect("before_shark_found", self, "_on_LevelCards_before_shark_found")


func add_cards() -> void:
	_cell_pos_to_revealed_letter.clear()
	var words: Array
	
	match puzzle_difficulty:
		0:
			words = ["frog/frog", "shark/shark"]
			words[0] = _reveal_letters(words[0], 3)
			words[0] = _frogify_letters(words[0], 1.0)
			words[1] = _reveal_letters(words[1], 4)
			words[1] = _sharkify_letters(words[1], 0.0)
		1:
			words = ["frog/frog", "shark/shark"]
			words[0] = _reveal_letters(words[0], 2)
			words[0] = _frogify_letters(words[0], 0.8)
			words[1] = _reveal_letters(words[1], random.randi_range(2, 3))
			words[1] = _sharkify_letters(words[1], 0.5)
		2:
			words = ["frog/frog", "shark/shark"]
			words[0] = _reveal_letters(words[0], 1)
			words[0] = _frogify_letters(words[0], 0.6)
			words[1] = _reveal_letters(words[1], 1)
			words[1] = _sharkify_letters(words[1], 1.0)
		3:
			# one troll word
			words = ["frog/frog", "shark/shark", "shark/shark"]
			words = _trollify_words(words, 1)
			words[0] = _reveal_letters(words[0], random.randi_range(1, 2))
			words[0] = _frogify_letters(words[0], 0.4)
			words[1] = _reveal_letters(words[1], 1)
			words[1] = _sharkify_letters(words[1], 0.4)
			words[2] = _reveal_letters(words[2], 2)
			words[2] = _sharkify_letters(words[2], 0.4)
			
			if randf() < 0.5:
				words[1] = _troll_silly_word()
				words[1] = _reveal_letters(words[1], 1)
		4:
			# two troll words
			words = ["frog/frog", "shark/shark", "shark/shark"]
			words = _trollify_words(words, 2)
			words[0] = _reveal_letters(words[0], random.randi_range(1, 2))
			words[0] = _frogify_letters(words[0], 0.2)
			words[1] = _reveal_letters(words[1], 1)
			words[1] = _sharkify_letters(words[1], 0.5)
			words[2] = _reveal_letters(words[2], 2)
			words[2] = _sharkify_letters(words[2], 0.5)
		5:
			# three troll words
			words = ["frog/frog", "shark/shark", "shark/shark", "shark/shark"]
			words = _trollify_words(words, 3)
			words[0] = _reveal_letters(words[0], random.randi_range(1, 2))
			words[0] = _frogify_letters(words[0], 0.0)
			words[1] = _reveal_letters(words[1], 1)
			words[1] = _sharkify_letters(words[1], 0.6)
			words[2] = _reveal_letters(words[2], random.randi_range(1, 2))
			words[2] = _sharkify_letters(words[2], 0.6)
			words[3] = _reveal_letters(words[3], 2)
			words[3] = _sharkify_letters(words[3], 0.6)
			
			if randf() < 0.5:
				words[3] = _troll_silly_word()
				words[3] = _reveal_letters(words[3], 1)
		6:
			# four troll words
			words = ["frog/frog", "shark/shark", "shark/shark", "shark/shark"]
			words = _trollify_words(words, 4)
			words[0] = _reveal_letters(words[0], 1)
			words[0] = _frogify_letters(words[0], 0.0)
			words[1] = _reveal_letters(words[1], 1)
			words[1] = _sharkify_letters(words[1], 0.7)
			words[2] = _reveal_letters(words[2], 1)
			words[2] = _sharkify_letters(words[2], 0.7)
			words[3] = _reveal_letters(words[3], 1)
			words[3] = _sharkify_letters(words[3], 0.7)
		7:
			# four troll words
			words = ["frog/frog", "shark/shark", "shark/shark", "shark/shark", "shark/shark"]
			words = _trollify_words(words, 4)
			words[0] = _reveal_letters(words[0], 1)
			words[0] = _frogify_letters(words[0], 0.0)
			words[1] = _reveal_letters(words[1], 1)
			words[1] = _sharkify_letters(words[1], 0.8)
			words[2] = _reveal_letters(words[2], 1)
			words[2] = _sharkify_letters(words[2], 0.8)
			words[3] = _reveal_letters(words[3], 1)
			words[3] = _sharkify_letters(words[3], 0.8)
			words[4] = _reveal_letters(words[4], 1)
			words[4] = _sharkify_letters(words[4], 0.8)
			
			if randf() < 0.5:
				words[4] = _troll_silly_word()
				words[4] = _reveal_letters(words[4], 1)
		8:
			# four troll words; one with no letters revealed
			words = ["frog/frog", "shark/shark", "shark/shark", "shark/shark", "shark/shark"]
			words = _trollify_words(words, 4)
			var hidden_word_index := randi() % 5
			for i in range(0, 5):
				# one word remains completely hidden
				words[i] = _reveal_letters(words[i], 0 if hidden_word_index == i else 1)
			words[0] = _frogify_letters(words[0], 0.0)
			words[1] = _sharkify_letters(words[1], 0.9)
			words[2] = _sharkify_letters(words[2], 0.9)
			words[3] = _sharkify_letters(words[3], 0.9)
			words[4] = _sharkify_letters(words[4], 0.9)
			
			if randf() < 0.5:
				words[4] = _troll_silly_word()
	
	words.shuffle()
	for i in range(0, words.size()):
		var word_cell_pos := Vector2(int(rand_range(0, 3)), i)
		
		# shift short words to the right to keep them centered
		word_cell_pos.x += int(3 - words[i].length() / 2)
		
		_add_word(words[i], word_cell_pos)


"""
Replaces lower-case (hidden) letters with upper-case (revealed) letters.
"""
func _reveal_letters(word: String, count: int) -> String:
	var card_word := word.split("/")[0]
	var english_word := word.split("/")[1]
	var letter_indexes := range(0, card_word.length())
	letter_indexes.shuffle()
	
	# adjust the revealed letter count to account for edge cases
	var actual_count := count
	if count == 1 and word[letter_indexes[0]] == "r":
		# if count is 1 and the third letter is an "R", it's ambiguous -- so reveal a different letter
		letter_indexes.push_back(letter_indexes.pop_front())
	if count == 0 and word[letter_indexes[0]] == "r":
		# if count is 0 and the third letter is an "R", it's ambiguous -- so we can reveal it
		actual_count = 1
	
	# One might think 'letter_indexes.slice(actual_count)' would work here,
	# with the mistaken expectation that the slice function acts like its
	# counterparts in Python and Javascript. ...However in defiance of any
	# reasonable expectations, Godot's 'slice' function does something
	# completely unrelated to array slicing.
	#
	# ...Perhaps it is meant for pizza slices?
	while letter_indexes.size() > actual_count:
		letter_indexes.pop_back()
	
	for i in letter_indexes:
		var letter: String = card_word[i]
		card_word.erase(i, 1)
		card_word = card_word.insert(i, letter.to_upper())
	
	return "%s/%s" % [card_word, english_word]


"""
Replaces lower-case letters with frogs. At least one frog per word.
"""
func _frogify_letters(word: String, chance: float) -> String:
	return _replace_letters(word, "+", chance)


"""
Replaces lower-case letters with sharks. At least one shark per word.
"""
func _sharkify_letters(word: String, chance: float) -> String:
	return _replace_letters(word, "-", chance)


func _replace_letters(word: String, replacement: String, chance: float) -> String:
	var card_word := word.split("/")[0]
	var english_word := word.split("/")[1]
	
	var shark_count := 0
	var letter_indexes := range(0, card_word.length())
	letter_indexes.shuffle()
	for i in letter_indexes:
		if card_word[i] == card_word[i].to_lower():
			if shark_count == 0 or randf() < chance:
				shark_count += 1
				card_word.erase(i, 1)
				card_word = card_word.insert(i, replacement)
	
	return "%s/%s" % [card_word, english_word]


"""
Replaces words with 'troll words'.
"""
func _trollify_words(words: Array, count: int) -> Array:
	var troll_word_indexes := range(0, words.size())
	troll_word_indexes.shuffle()
	troll_word_indexes = troll_word_indexes.slice(0, count - 1)
	for i in troll_word_indexes:
		if i == 0:
			# replace first element with troll frog word
			words[i] = troll_frog_words[randi() % troll_frog_words.size()]
		else:
			# replace non-first element with troll shark word
			words[i] = troll_shark_words[randi() % troll_shark_words.size()]
	
	return words


"""
Replaces a word with a silly word that isn't a frog or a shark.
"""
func _troll_silly_word() -> Array:
	return troll_silly_words[randi() % troll_silly_words.size()]


func _add_word(word: String, word_cell_pos: Vector2) -> void:
	var card_word := word.split("/")[0]
	var english_word := word.split("/")[1]
	
	for i in range(0, card_word.length()):
		var letter: String = card_word[i]
		var letter_cell_pos: Vector2 = word_cell_pos + Vector2(i, 0)
		var card := level_cards.create_card()
		match(letter):
			"+":
				card.card_front_type = CardControl.CardType.FROG
			"-":
				card.card_front_type = CardControl.CardType.SHARK
			_:
				card.card_front_type = CardControl.CardType.LETTER
				card.card_front_details = letter.to_lower()
				if letter == letter.to_upper():
					card.show_front()
		if word_cell_pos.y == 1:
			card.card_back_details = "r"
		level_cards.add_card(card, letter_cell_pos)
		_cell_pos_to_revealed_letter[letter_cell_pos] = english_word[i]


func _show_word(clicked_card: CardControl) -> void:
	var clicked_cell_pos := level_cards.get_cell_pos(clicked_card)
	for cell_pos in _cell_pos_to_revealed_letter:
		if cell_pos.y != clicked_cell_pos.y:
			# only show letters in the same row
			continue
		if cell_pos == clicked_cell_pos:
			# don't show the card they clicked on
			continue
		var card := level_cards.get_card(cell_pos)
		if card.is_front_shown():
			# don't alter cards which are already shown
			continue
		
		card.card_front_type = CardControl.CardType.LETTER
		card.card_front_details = _cell_pos_to_revealed_letter[cell_pos]
		card.show_front()


func _on_LevelCards_before_frog_found(card: CardControl) -> void:
	_show_word(card)


func _on_LevelCards_before_shark_found(card: CardControl) -> void:
	_show_word(card)

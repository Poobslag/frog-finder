extends LevelRules
## Rules for 'froggo', a level with a series of words like 'FR_G' and 'S_ARK'. The player must guess which words spell
## 'frog'.
##
## Rules:
##
## 	1. If possible, click any row with 'F', I', 'G' or 'O' in any position.
## 	2. If possible, click any row with 'R' in the first or second position.
## 	3. If possible, click any row with 'E' in the third position.
## 	4. Do not click any row with an 'A', 'H', 'K' or 'S' in any position.
## 	5. Do not click any row with an 'R' in the fourth position.
##  6. You may click any other cards.

## Words which have frogs but aren't 'frog'. These should not have any letters in common with any troll_shark_words,
## except for the 'R' in the third position
var troll_frog_words := [
	"freg",
	"frig",
	"forg",
	"greg",
	"froge",
	"firgg",
	"forge",
	"froog",
	"froggo",
]

## Words which have sharks but aren't 'shark'. These should not have any letters in common with any troll_frog_words,
## except for the 'R' in the third position
var troll_shark_words := [
	"shak",
	"shrk",
	"sark",
	"hark",
	"sarkh",
	"shrak",
	"sahrk",
	"sherk",
]

## Words which don't have frogs or sharks. These words are generally themed around the frog hiding, or the player
## making a mistake
var troll_silly_words := [
	"ha",
	"hi",
	"no",
	"fake",
	"find",
	"fond",
	"fish",
	"hide",
	"haha",
	"gone",
	"goof",
	"ohno",
	"faker",
	"snore",
	"hidden",
	"friend",
	"ignore",
	"heehee",
	"hahaha",
]

## key: (Vector2) cell position of a card
## value: (String) letter to reveal when revealing the word the player clicked
var _cell_pos_to_revealed_letter := {}

func refresh_level_cards() -> void:
	if not level_cards:
		return
	level_cards.before_frog_found.connect(_on_level_cards_before_frog_found)
	level_cards.before_shark_found.connect(_on_level_cards_before_shark_found)


func add_cards() -> void:
	_cell_pos_to_revealed_letter.clear()
	var aliaxes: Array[String]
	
	match puzzle_difficulty:
		0:
			aliaxes = _aliaxes(["frog", "shark"])
			aliaxes[0] = _reveal_letters(aliaxes[0], 3)
			aliaxes[0] = _frogify_letters(aliaxes[0], 1.0)
			aliaxes[1] = _reveal_letters(aliaxes[1], 4)
			aliaxes[1] = _sharkify_letters(aliaxes[1], 0.0)
		1:
			aliaxes = _aliaxes(["frog", "shark"])
			aliaxes[0] = _reveal_letters(aliaxes[0], 2)
			aliaxes[0] = _frogify_letters(aliaxes[0], 0.8)
			aliaxes[1] = _reveal_letters(aliaxes[1], randi_range(2, 3))
			aliaxes[1] = _sharkify_letters(aliaxes[1], 0.5)
		2:
			aliaxes = _aliaxes(["frog", "shark"])
			aliaxes[0] = _reveal_letters(aliaxes[0], 1)
			aliaxes[0] = _frogify_letters(aliaxes[0], 0.6)
			aliaxes[1] = _reveal_letters(aliaxes[1], 1)
			aliaxes[1] = _sharkify_letters(aliaxes[1], 1.0)
		3:
			# one troll aliax
			aliaxes = _aliaxes(["frog", "shark", "shark"])
			aliaxes = _trollify_aliaxes(aliaxes, 1)
			aliaxes[0] = _reveal_letters(aliaxes[0], randi_range(1, 2))
			aliaxes[0] = _frogify_letters(aliaxes[0], 0.4)
			aliaxes[1] = _reveal_letters(aliaxes[1], 1)
			aliaxes[1] = _sharkify_letters(aliaxes[1], 0.4)
			aliaxes[2] = _reveal_letters(aliaxes[2], 2)
			aliaxes[2] = _sharkify_letters(aliaxes[2], 0.4)
			
			if randf() < 0.5:
				aliaxes[1] = _troll_silly_aliax()
				aliaxes[1] = _reveal_letters(aliaxes[1], 1)
		4:
			# two troll aliaxes
			aliaxes = _aliaxes(["frog", "shark", "shark"])
			aliaxes = _trollify_aliaxes(aliaxes, 2)
			aliaxes[0] = _reveal_letters(aliaxes[0], randi_range(1, 2))
			aliaxes[0] = _frogify_letters(aliaxes[0], 0.2)
			aliaxes[1] = _reveal_letters(aliaxes[1], 1)
			aliaxes[1] = _sharkify_letters(aliaxes[1], 0.5)
			aliaxes[2] = _reveal_letters(aliaxes[2], 2)
			aliaxes[2] = _sharkify_letters(aliaxes[2], 0.5)
		5:
			# three troll aliaxes
			aliaxes = _aliaxes(["frog", "shark", "shark", "shark"])
			aliaxes = _trollify_aliaxes(aliaxes, 3)
			aliaxes[0] = _reveal_letters(aliaxes[0], randi_range(1, 2))
			aliaxes[0] = _frogify_letters(aliaxes[0], 0.0)
			aliaxes[1] = _reveal_letters(aliaxes[1], 1)
			aliaxes[1] = _sharkify_letters(aliaxes[1], 0.6)
			aliaxes[2] = _reveal_letters(aliaxes[2], randi_range(1, 2))
			aliaxes[2] = _sharkify_letters(aliaxes[2], 0.6)
			aliaxes[3] = _reveal_letters(aliaxes[3], 2)
			aliaxes[3] = _sharkify_letters(aliaxes[3], 0.6)
			
			if randf() < 0.5:
				aliaxes[3] = _troll_silly_aliax()
				aliaxes[3] = _reveal_letters(aliaxes[3], 1)
		6:
			# four troll aliaxes
			aliaxes = _aliaxes(["frog", "shark", "shark", "shark"])
			aliaxes = _trollify_aliaxes(aliaxes, 4)
			aliaxes[0] = _reveal_letters(aliaxes[0], 1)
			aliaxes[0] = _frogify_letters(aliaxes[0], 0.0)
			aliaxes[1] = _reveal_letters(aliaxes[1], 1)
			aliaxes[1] = _sharkify_letters(aliaxes[1], 0.7)
			aliaxes[2] = _reveal_letters(aliaxes[2], 1)
			aliaxes[2] = _sharkify_letters(aliaxes[2], 0.7)
			aliaxes[3] = _reveal_letters(aliaxes[3], 1)
			aliaxes[3] = _sharkify_letters(aliaxes[3], 0.7)
		7:
			# four troll aliaxes
			aliaxes = _aliaxes(["frog", "shark", "shark", "shark", "shark"])
			aliaxes = _trollify_aliaxes(aliaxes, 4)
			aliaxes[0] = _reveal_letters(aliaxes[0], 1)
			aliaxes[0] = _frogify_letters(aliaxes[0], 0.0)
			aliaxes[1] = _reveal_letters(aliaxes[1], 1)
			aliaxes[1] = _sharkify_letters(aliaxes[1], 0.8)
			aliaxes[2] = _reveal_letters(aliaxes[2], 1)
			aliaxes[2] = _sharkify_letters(aliaxes[2], 0.8)
			aliaxes[3] = _reveal_letters(aliaxes[3], 1)
			aliaxes[3] = _sharkify_letters(aliaxes[3], 0.8)
			aliaxes[4] = _reveal_letters(aliaxes[4], 1)
			aliaxes[4] = _sharkify_letters(aliaxes[4], 0.8)
			
			if randf() < 0.5:
				aliaxes[4] = _troll_silly_aliax()
				aliaxes[4] = _reveal_letters(aliaxes[4], 1)
		8:
			# four troll aliaxes; one with no letters revealed
			aliaxes = _aliaxes(["frog", "shark", "shark", "shark", "shark"])
			aliaxes = _trollify_aliaxes(aliaxes, 4)
			var hidden_aliax_index := randi() % 5
			for i in range(5):
				# one aliax remains completely hidden
				aliaxes[i] = _reveal_letters(aliaxes[i], 0 if hidden_aliax_index == i else 1)
			aliaxes[0] = _frogify_letters(aliaxes[0], 0.0)
			aliaxes[1] = _sharkify_letters(aliaxes[1], 0.9)
			aliaxes[2] = _sharkify_letters(aliaxes[2], 0.9)
			aliaxes[3] = _sharkify_letters(aliaxes[3], 0.9)
			aliaxes[4] = _sharkify_letters(aliaxes[4], 0.9)
			
			if randf() < 0.5:
				aliaxes[4] = _troll_silly_aliax()
	
	aliaxes.shuffle()
	for i in range(aliaxes.size()):
		var aliax_cell_pos := Vector2(randi_range(0, 2), i)
		
		# shift short aliaxes to the right to keep them centered
		@warning_ignore("integer_division")
		aliax_cell_pos.x += int(3 - aliaxes[i].length() / 2)
		
		_add_aliax(aliaxes[i], aliax_cell_pos)


## Converts a word into an 'aliax', a string like 'fRO+e/froge'.
##
## An aliax is a a string with two parts separated by a forward slash like 'fRO+e/froge'. The letters right of the
## slash are an unmodified lower-case word like 'froge' or 'sarkh'. The letters left of the slash correspond to the
## cards the player can reveal, and can be any of the following:
##
## 	[A-Z]: A face-up card which shows a letter
## 	[a-z]: A face-down card which hides a letter
## 	[+]: A face-down card which hides a frog
## 	[-]: A face-down card which hides a shark
##
## Parameters:
## 	'card_word': A mangled word which represents the frogs, sharks and letters to show the player
##
## 	'english_word': (Optional) A word which the cards spell if you ignore the frogs and sharks. If omitted, the card
## 		word will be used for both parts of the aliax.
##
## Returns:
## 	A new aliax like 'fRO+e/froge' which combines the specified words.
func _aliax(card_word: String, english_word: String = "") -> String:
	return "%s/%s" % [card_word, english_word if english_word else card_word]


## Converts a list of words into 'aliaxes', strings like 'frog/frog'.
##
## See the documentation for the _aliax() function for more details.
##
## Parameters:
## 	'words': A list of words to convert like ['frog', 'shark']
##
## Returns:
## 	A list of aliaxes like ['frog/frog', 'shark/shark']
func _aliaxes(words: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for word in words:
		result.append(_aliax(word))
	return result


## Replaces lower-case (hidden) letters with upper-case (revealed) letters.
func _reveal_letters(aliax: String, count: int) -> String:
	var card_word := aliax.split("/")[0]
	var english_word := aliax.split("/")[1]
	var letter_indexes := range(card_word.length())
	letter_indexes.shuffle()
	
	# adjust the revealed letter count to account for edge cases
	var actual_count := count
	if count == 1 and aliax[letter_indexes[0]] == "r":
		# if count is 1 and the third letter is an "R", it's ambiguous -- so reveal a different letter
		letter_indexes.push_back(letter_indexes.pop_front())
	if count == 0 and aliax[letter_indexes[0]] == "r":
		# if count is 0 and the third letter is an "R", it's ambiguous -- so we can reveal it
		actual_count = 1
	
	letter_indexes = letter_indexes.slice(0, actual_count)
	
	for i in letter_indexes:
		var letter: String = card_word[i]
		card_word = Utils.erase(card_word, i, 1)
		card_word = card_word.insert(i, letter.to_upper())
	
	return _aliax(card_word, english_word)


## Replaces lower-case letters with frogs. At least one frog per aliax.
func _frogify_letters(aliax: String, chance: float) -> String:
	return _replace_letters(aliax, "+", chance)


## Replaces lower-case letters with sharks. At least one shark per aliax.
func _sharkify_letters(aliax: String, chance: float) -> String:
	return _replace_letters(aliax, "-", chance)


func _replace_letters(aliax: String, replacement: String, chance: float) -> String:
	var card_word := aliax.split("/")[0]
	var english_word := aliax.split("/")[1]
	
	var shark_count := 0
	var letter_indexes := range(card_word.length())
	letter_indexes.shuffle()
	for i in letter_indexes:
		if card_word[i] == card_word[i].to_lower():
			if shark_count == 0 or randf() < chance:
				shark_count += 1
				card_word = Utils.erase(card_word, i, 1)
				card_word = card_word.insert(i, replacement)
	
	return _aliax(card_word, english_word)


## Replaces aliaxes with 'troll aliaxes'.
func _trollify_aliaxes(aliaxes: Array[String], count: int) -> Array[String]:
	var troll_aliax_indexes := range(aliaxes.size())
	troll_aliax_indexes.shuffle()
	troll_aliax_indexes = troll_aliax_indexes.slice(0, count)
	for i in troll_aliax_indexes:
		if i == 0:
			aliaxes[i] = _troll_frog_aliax()
		else:
			aliaxes[i] = _troll_shark_aliax()
	
	return aliaxes


## Returns a random troll frog aliax.
func _troll_frog_aliax() -> String:
	return _aliax(Utils.rand_value(troll_frog_words))


## Returns a random troll shark aliax.
func _troll_shark_aliax() -> String:
	return _aliax(Utils.rand_value(troll_shark_words))


## Returns a random silly aliax that isn't a frog or a shark.
func _troll_silly_aliax() -> String:
	return _aliax(Utils.rand_value(troll_silly_words))


func _add_aliax(aliax: String, aliax_cell_pos: Vector2) -> void:
	var card_word := aliax.split("/")[0]
	var english_word := aliax.split("/")[1]
	
	for i in range(card_word.length()):
		var letter: String = card_word[i]
		var letter_cell_pos: Vector2 = aliax_cell_pos + Vector2(i, 0)
		var card := level_cards.create_card()
		match(letter):
			"+":
				card.card_front_type = CardControl.CardType.FROG
			"-":
				card.card_front_type = CardControl.CardType.SHARK
			_:
				card.card_front_type = CardControl.CardType.LETTER
				card.card_front_details = letter.to_lower()
		if aliax_cell_pos.y == 1:
			card.card_back_details = "r"
		level_cards.add_card(card, letter_cell_pos)
		if card.card_front_type == CardControl.CardType.LETTER and letter == letter.to_upper():
			card.show_front()
		_cell_pos_to_revealed_letter[letter_cell_pos] = english_word[i]


func _show_aliax(clicked_card: CardControl) -> void:
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


func _on_level_cards_before_frog_found(card: CardControl) -> void:
	_show_aliax(card)


func _on_level_cards_before_shark_found(card: CardControl) -> void:
	_show_aliax(card)

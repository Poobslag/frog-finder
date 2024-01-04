@tool
extends Control
## Shows the world title on the main menu.
##
## The main menu shows a title like "Sunshine Shoals" with some of the letters replaced with frogs/sharks.

@export var text: String:
	set(new_text):
		if text == new_text:
			return
		text = new_text
		_refresh_text()

@export var CardControlScene: PackedScene
@export var game_state: GameState

## Emitted when new cards are generated.
signal cards_changed

const DEFAULT_TITLE := "fr?g f?nder"

## List of CardControl instances for frogs/sharks. These are cached so that when navigating the main menu, we don't
## give the player infinite opportunities to find new sharks. This would let the player find infinite frogs without
## ever playing the game!
var _mystery_cards: Array = []

func _ready() -> void:
	PlayerData.world_index_changed.connect(_on_player_data_world_index_changed)
	
	if not Engine.is_editor_hint():
		text = _world_title()


func _exit_tree() -> void:
	# We have to free our cached mystery cards manually, as they are not necessarily in the scene tree.
	for card in _mystery_cards:
		card.free()


## Randomizes our random frog/shark cards, flipping them to their back side.
func randomize_mystery_cards() -> void:
	for card in get_children():
		if card.card_front_type in [CardControl.CardType.FROG, CardControl.CardType.SHARK]:
			_randomize_mystery_card(card)


## Creates and stores a new letter node.
##
## Parameters:
## 	'words': List of strings, where each string is a word in the level title.
##
## 	'word_index': Index in 'words' for the word with the current letter.
##
## 	'letter_index': Index in the word for the current letter.
func _append_letter(words: Array, word_index: int, letter_index: int) -> void:
	var word_string: String = words[word_index]
	var letter_string: String = word_string[letter_index]
	
	# calculate contents (letter, frog, shark)
	var card: CardControl
	match letter_string:
		"a", "d", "e", "f", "g", "h", "i", "k", "n", "o", "r", "s":
			# letter card
			card = instantiate_card()
			card.card_front_type = CardControl.CardType.LETTER
			card.card_front_details = letter_string
			card.show_front()
		"?":
			# mystery card (frog or shark)
			for mystery_card in _mystery_cards:
				if not mystery_card.is_inside_tree():
					card = mystery_card
					break
			
			if not card:
				card = instantiate_card()
				_randomize_mystery_card(card)
				_mystery_cards.append(card)
		_:
			# blank card (fail-safe for an invalid title)
			card = instantiate_card()
			card.card_front_type = CardControl.CardType.ARROW
			card.card_front_details = ""
			card.show_front()
			push_warning("Unrecognized letter string '%s' in %s" % [letter_string, words])
	
	# calculate letter position
	card.position.x = 420 + LevelCards.CELL_SIZE.x * (letter_index - word_string.length() / 2.0 + 0.5)
	card.position.y = 50 + LevelCards.CELL_SIZE.y * (word_index)
	
	add_child(card)
	card.set_owner(get_tree().edited_scene_root)


func instantiate_card() -> CardControl:
	var card: CardControl = CardControlScene.instantiate()
	card.card_back_type = CardControl.CardType.MYSTERY
	card.game_state = game_state
	card.name = "Card%s" % [get_child_count() + 1]
	card.practice = true
	return card


## Updates our letter nodes to match our text string.
func _refresh_text() -> void:
	if not is_inside_tree():
		return
	
	for child in get_children():
		if child in _mystery_cards:
			# don't free mystery cards; keep them around so the player doesn't keep getting new frogs/sharks by
			# clicking around the main menu
			pass
		else:
			child.queue_free()
		remove_child(child)
	
	var words := text.split(" ")
	for word_index in range(words.size()):
		var word := words[word_index]
		for letter_index in range(word.length()):
			_append_letter(words, word_index, letter_index)
	
	cards_changed.emit()


## Randomizes a random frog/shark card, flipping it to its back side.
func _randomize_mystery_card(card: CardControl) -> void:
	card.card_front_type = CardControl.CardType.SHARK if randf() < 0.15 else CardControl.CardType.FROG
	card.hide_front()


func _world_title() -> String:
	var new_title: String = PlayerData.get_world().title
	if not new_title:
		new_title = DEFAULT_TITLE
	return new_title



## When the player switches to a new world, we update the title text.
func _on_player_data_world_index_changed() -> void:
	text = _world_title()

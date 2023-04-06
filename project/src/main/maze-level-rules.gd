extends LevelRules
## Rules for 'maze', a 2D maze where the player follows arrows pointing in cardinal directions (up, down, left right)
## to find a frog.
##
## Rules:
##
## 	1. If possible, click any unrevealed card with an arrow pointing to it.
## 	2. If possible, click any unrevealed card which an arrow previously pointed to.
## 	3. You may click any previously revealed card.
## 	4. Do not click any other cards.

const ROW_COUNT := 6
const COL_COUNT := 9

## key: (String) card details string corresponding to a cardinal direction
## value: (Vector2) direction of the card pointed to, measured in card widths
const DIRECTIONS_BY_STRING := {
	"n": Vector2.UP,
	"s": Vector2.DOWN,
	"e": Vector2.RIGHT,
	"w": Vector2.LEFT,
}

var _random := RandomNumberGenerator.new()

var _remaining_flip_count := 6
var _average_path_cells := 3
var _remaining_path_cells := 0
var _max_loose_end_count := 2
var _max_shown_card_count := 99
var _max_unblanked_arrow_count := 99
var _include_start_card_in_queue := true
var _mistake_luck := 0.5
var _start_position: Vector2

## key: (Vector2) cell position of an unflipped card which is pointed to by an arrow, or has been pointed to previously
## value: (bool) true
var _loose_end_positions := {}

## key: (vector2) cell position of an unflipped card
## value: (bool) true
var _unflipped_card_positions := {}

## Queue of CardControls for cards the player has seen. The front of the queue corresponds to the oldest card.
var _shown_card_queue := []

## Queue of CardControls for arrow cards the player has seen. The front of the queue corresponds to the oldest card.
## Depending on the level difficulty, these cards may be hidden to force the player to rely on their memory instead of
## backtracking.
var _unblanked_arrow_queue := []

## key: (CardControl) level card
## value: (String) card details string for the card's contents before it was blanked
var _blanked_arrows_to_original := {}

func _ready() -> void:
	_random.randomize()


func refresh_level_cards_path() -> void:
	.refresh_level_cards_path()
	if not level_cards:
		return
	level_cards.connect("before_card_flipped", self, "_on_LevelCards_before_card_flipped")
	level_cards.connect("before_shark_found", self, "_on_LevelCards_before_shark_found")


func add_cards() -> void:
	_loose_end_positions.clear()
	_unflipped_card_positions.clear()
	_shown_card_queue.clear()
	_unblanked_arrow_queue.clear()
	_blanked_arrows_to_original.clear()
	
	for y in range(ROW_COUNT):
		for x in range(COL_COUNT):
			if x == 0 and y == 0:
				continue
			if x == 0 and y == ROW_COUNT - 1:
				continue
			if x == COL_COUNT - 1 and y == 0:
				continue
			if x == COL_COUNT - 1 and y == ROW_COUNT - 1:
				continue
			
			var card := level_cards.create_card()
			card.card_front_type = CardControl.CardType.FISH
			level_cards.add_card(card, Vector2(x, y))
			_unflipped_card_positions[Vector2(x, y)] = true
	
	_average_path_cells = 99
	_max_loose_end_count = 1
	_max_shown_card_count = 99
	_max_unblanked_arrow_count = 99
	_include_start_card_in_queue = false
	
	match puzzle_difficulty:
		0:
			_remaining_flip_count = _random.randi_range(0, 15)
			_mistake_luck = 0.9
		1:
			_max_loose_end_count = 2
			_remaining_flip_count = _random.randi_range(15, 20)
			_mistake_luck = 0.8
		2:
			_remaining_flip_count = _random.randi_range(15, 20)
			_mistake_luck = 0.8
			_max_shown_card_count = 3
		3:
			_max_loose_end_count = 2
			_average_path_cells = 10
			_remaining_flip_count = _random.randi_range(25, 30)
			_mistake_luck = 0.7
			_include_start_card_in_queue = true
		4:
			_max_loose_end_count = 2
			_average_path_cells = 12
			_max_unblanked_arrow_count = 12
			_remaining_flip_count = 99
			_mistake_luck = 0.7
			_include_start_card_in_queue = true
		5:
			_average_path_cells = 4
			_max_loose_end_count = 6
			_remaining_flip_count = _random.randi_range(20, 30)
			_mistake_luck = 0.6
			_max_shown_card_count = 12
		6:
			_average_path_cells = 12
			_max_loose_end_count = 2
			_remaining_flip_count = _random.randi_range(30, 40)
			_mistake_luck = 0.4
			_max_unblanked_arrow_count = 6
			_include_start_card_in_queue = true
		7:
			_average_path_cells = 2
			_max_loose_end_count = 6
			_remaining_flip_count = _random.randi_range(40, 50)
			_mistake_luck = 0.2
			_max_shown_card_count = 8
			_max_unblanked_arrow_count = 12
			_include_start_card_in_queue = true
		8:
			_average_path_cells = 4
			_max_loose_end_count = 3
			_remaining_flip_count = 99
			_mistake_luck = 0.1
			_max_shown_card_count = 99
			_max_shown_card_count = 2
			_max_unblanked_arrow_count = 1
			_include_start_card_in_queue = true
	
	_start_position = Vector2(_random.randi_range(2, 6), _random.randi_range(2, 3))
	var start_card := level_cards.get_card(_start_position)
	var start_directions := ["n", "w", "s", "e"]
	_remaining_path_cells = _random.randi_range(0, _average_path_cells + 1)
	if _max_loose_end_count > 1 and randf() < 1.0 / _average_path_cells:
		start_directions = ["ne", "nw", "se", "sw", "ns", "ew"]
		_remaining_path_cells = _random.randi_range(_average_path_cells - 1, _average_path_cells + 1)
	var start_direction: String = Utils.rand_value(start_directions)
	_arrowify_card(start_card, start_direction)
	start_card.show_front()
	_unflipped_card_positions.erase(_start_position)
	
	if _include_start_card_in_queue:
		_shown_card_queue.push_back(start_card)
		_unblanked_arrow_queue.push_back(start_card)


func _arrowify_card(card: CardControl, card_front_details: String) -> void:
	card.card_front_type = CardControl.CardType.ARROW
	card.card_front_details = card_front_details
	
	var arrow_card_position := level_cards.get_cell_pos(card)
	for dir_string in ["n", "s", "e", "w"]:
		var direction: Vector2 = DIRECTIONS_BY_STRING[dir_string]
		if dir_string in card.card_front_details \
				and _unflipped_card_positions.get(arrow_card_position + direction):
			_loose_end_positions[arrow_card_position + direction] = true


func _adjacent_cards(card: CardControl) -> Array:
	var result := []
	var card_position: Vector2 = level_cards.get_cell_pos(card)
	for adjacent_direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var adjacent_cell_pos: Vector2 = card_position + adjacent_direction
		if level_cards.has_card(adjacent_cell_pos):
			result.append(level_cards.get_card(adjacent_cell_pos))
	result.shuffle()
	return result


func _adjacent_unflipped_dir_strings(card: CardControl) -> Array:
	var card_position := level_cards.get_cell_pos(card)
	var adjacent_unflipped_dir_strings := []
	# otherwise, just keep extending the path
	for dir_string in ["n", "s", "e", "w"]:
		var direction: Vector2 = DIRECTIONS_BY_STRING[dir_string]
		if _unflipped_card_positions.get(card_position + direction):
			adjacent_unflipped_dir_strings.append(dir_string)
	adjacent_unflipped_dir_strings.shuffle()
	return adjacent_unflipped_dir_strings


func _before_loose_end_flipped(card: CardControl) -> void:
	_loose_end_positions.erase(level_cards.get_cell_pos(card))
	
	_remaining_flip_count -= 1
	_remaining_path_cells -= 1
	var adjacent_unflipped_dir_strings := _adjacent_unflipped_dir_strings(card)
	if _remaining_flip_count <= 0:
		# if we've flipped enough cards, it's a frog
		card.card_front_type = CardControl.CardType.FROG
	elif not adjacent_unflipped_dir_strings and not _loose_end_positions:
		# if there are no neighbors, and the 'loose ends' list is now empty, it's a frog
		card.card_front_type = CardControl.CardType.FROG
	elif _remaining_path_cells <= 0:
		# if this path is long enough, it's a dead end or a fork
		var new_arrow_dir_string: String
		if _loose_end_positions and randf() > (1.0 / (_loose_end_positions.size() + 1)):
			# there are enough loose ends; this one can be a dead end
			new_arrow_dir_string = ""
		else:
			var valid_forks := []
			if _loose_end_positions.size() + 2 <= _max_loose_end_count:
				for fork in ["ne", "nw", "se", "sw", "ns", "ew"]:
					if fork[0] in adjacent_unflipped_dir_strings and fork[1] in adjacent_unflipped_dir_strings:
						valid_forks.append(fork)
			if valid_forks:
				_remaining_path_cells = _random.randi_range(_average_path_cells - 1, _average_path_cells + 1)
				valid_forks.shuffle()
				new_arrow_dir_string = valid_forks[0]
			else:
				new_arrow_dir_string = adjacent_unflipped_dir_strings[0] if adjacent_unflipped_dir_strings else ""
		_arrowify_card(card, new_arrow_dir_string)
	else:
		var new_arrow_dir_string: String = adjacent_unflipped_dir_strings[0] if adjacent_unflipped_dir_strings else ""
		# otherwise, just keep extending the path
		_arrowify_card(card, new_arrow_dir_string)


func _before_mistake_flipped(card: CardControl) -> void:
	if randf() < _mistake_luck:
		pass
	else:
		card.card_front_type = CardControl.CardType.SHARK


func _on_LevelCards_before_card_flipped(card: CardControl) -> void:
	if not card.card_front_type == CardControl.CardType.FISH:
		# we leave arrows alone. we only mess with fish
		pass
	else:
		var card_pos := level_cards.get_cell_pos(card)
		if _loose_end_positions.has(card_pos):
			_before_loose_end_flipped(card)
		else:
			_before_mistake_flipped(card)
		_unflipped_card_positions.erase(card_pos)
	
	_shown_card_queue.append(card)
	if _shown_card_queue.size() > _max_shown_card_count:
		var old_card: CardControl = _shown_card_queue.pop_front()
		old_card.hide_front()
	
	if card.card_front_type == CardControl.CardType.ARROW and card.card_front_details:
		_unblanked_arrow_queue.append(card)
	if _unblanked_arrow_queue.size() > _max_unblanked_arrow_count:
		var old_card: CardControl = _unblanked_arrow_queue.pop_front()
		_blanked_arrows_to_original[old_card] = old_card.card_front_details
		old_card.card_front_details = ""


func _on_LevelCards_before_shark_found(_card: CardControl) -> void:
	# unblank blanked arrows
	for card in _blanked_arrows_to_original.keys():
		card.card_front_details = _blanked_arrows_to_original[card]
	
	# show all arrows
	for card in level_cards.get_cards():
		if card.card_front_type == CardControl.CardType.ARROW and not card.is_front_shown():
			card.show_front()
	
	# show a frog
	if _loose_end_positions:
		var shuffled_loose_end_positions := _loose_end_positions.keys()
		shuffled_loose_end_positions.shuffle()
		var frog_card := level_cards.get_card(shuffled_loose_end_positions[0])
		frog_card.card_front_type = CardControl.CardType.FROG
		frog_card.show_front()
	

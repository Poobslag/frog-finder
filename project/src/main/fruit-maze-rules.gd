extends LevelRules
## Rules for 'fruit maze', a level where you search for fruits in a maze and match them to fruits outside the maze.
##
## Rules:
##
## 	1. If you have found a fruit in the maze matching a hidden fruit outside the maze, click the fruit outside the
## 		maze.
## 	2. If possible, click any unrevealed card with an arrow pointing to it.
## 	3. If possible, click any unrevealed card which an arrow previously pointed to.
## 	4. You may click any previously revealed card in the maze.
## 	5. Do not click any other cards.

const CENTER_CELL_POS := Vector2(4, 2)

## key: (String) card details string corresponding to a hex direction
## value: (Vector2) direction of the card pointed to, measured in card widths
const DIRECTIONS_BY_STRING := {
	"n": Vector2.UP,
	"s": Vector2.DOWN,
	"e": Vector2(1.0, -0.5),
	"f": Vector2(1.0, 0.5),
	"w": Vector2(-1.0, -0.5),
	"x": Vector2(-1.0, 0.5),
}

## key: (int) number of hex arrows from 0-6
## value: (Array, String) possible card details strings with the specified number of hex arrows
const HEX_ARROW_DETAILS_BY_ARROW_COUNT := {
	0: [""],
	1: ["n", "e", "f", "s", "x", "w"],
	2: ["nf", "se", "sw", "nx", "ns", "ex", "fw"],
	3: ["nfx", "sew"],
	4: ["efwx"],
	5: ["nefwx", "sefwx"],
	6: ["nsefwx"],
}

const OUTER_CELLS := [
	Vector2(0, 0),
	Vector2(8, 0),
	Vector2(0, 2),
	Vector2(8, 2),
	Vector2(0, 4),
	Vector2(8, 4),
]

const INNER_CELLS := [
	Vector2(4.0, 0.0),
	Vector2(3.0, 0.5), Vector2(5.0, 0.5),
	Vector2(2.0, 1.0), Vector2(4.0, 1.0), Vector2(6.0, 1.0),
	Vector2(3.0, 1.5), Vector2(5.0, 1.5),
	Vector2(2.0, 2.0), Vector2(4.0, 2.0), Vector2(6.0, 2.0),
	Vector2(3.0, 2.5), Vector2(5.0, 2.5),
	Vector2(2.0, 3.0), Vector2(4.0, 3.0), Vector2(6.0, 3.0),
	Vector2(3.0, 3.5), Vector2(5.0, 3.5),
	Vector2(4.0, 4.0),
]

var _random := RandomNumberGenerator.new()

## key: (Vector2) cell coordinates of an outer cell which contains a fruit
## value: (bool) true
var _outer_fruit_cells := {}

## key: (Vector2) cell coordinates of a maze cell which contains a fruit
## value: (bool) true
var _inner_fruit_cells := {}

## key: (Vector2) cell coordinates of an unflipped maze cell
## value: (bool) true
var _unflipped_inner_cell_positions := {}

## key: (Vector2) cell coordinates of an outer cell which contains a wrong fruit (a fruit not in the maze)
var _wrong_outer_fruit_cells_by_details := {}

## key: (String) card details string corresponding to a fruit
## value: (int) number of times the path leading to that fruit has forked
var _fork_counts_per_fruit := {}

## Queue of CardControls for cards the player has seen. The front of the queue corresponds to the oldest card.
var _shown_card_queue := []

var _correct_outer_fruit_detail := ""
var _found_correct_inner_fruit := false
var _outer_fruits_hidden := false

var _mistake_luck := 0.5
var _fruit_fork_chance := 0.5
var _fruit_hop_chance := 0.5
var _mandatory_hops := 3
var _max_shown_card_count := 99
var _max_fork_count := 1

func _ready() -> void:
	_random.randomize()


func refresh_level_cards_path() -> void:
	super.refresh_level_cards_path()
	if not level_cards:
		return
	level_cards.connect("before_card_flipped",Callable(self,"_on_LevelCards_before_card_flipped"))
	level_cards.connect("before_shark_found",Callable(self,"_on_LevelCards_before_shark_found"))


func add_cards() -> void:
	_outer_fruit_cells.clear()
	_inner_fruit_cells.clear()
	_unflipped_inner_cell_positions.clear()
	_wrong_outer_fruit_cells_by_details.clear()
	_fork_counts_per_fruit.clear()
	_shown_card_queue.clear()
	
	_correct_outer_fruit_detail = ""
	_found_correct_inner_fruit = false
	_outer_fruits_hidden = false
	
	var highlight_fruits := false
	var outer_fruit_count := 3
	var inner_fruit_count := 3
	_mistake_luck = 0.5
	_fruit_fork_chance = 0.0
	_fruit_hop_chance = 0.0
	_mandatory_hops = 0
	_max_shown_card_count = 99
	_max_fork_count = 0
	
	match puzzle_difficulty:
		0:
			highlight_fruits = true
			outer_fruit_count = 2
			inner_fruit_count = 1
			_mistake_luck = 0.9
			_fruit_fork_chance = 0.0
			_fruit_hop_chance = 0.0
			_mandatory_hops = 1
			_max_fork_count = 0
		1:
			highlight_fruits = true
			outer_fruit_count = 2
			inner_fruit_count = 1
			_mistake_luck = 0.8
			_fruit_fork_chance = 0.1
			_fruit_hop_chance = 0.2
			_mandatory_hops = 4
			_max_shown_card_count = 2
			_max_fork_count = 1
		2:
			highlight_fruits = true
			outer_fruit_count = 2
			inner_fruit_count = 2
			_mistake_luck = 0.8
			_fruit_fork_chance = 0.1
			_fruit_hop_chance = 0.2
			_mandatory_hops = 3
			_max_fork_count = 1
		3:
			highlight_fruits = true
			outer_fruit_count = 2
			inner_fruit_count = 3
			_mistake_luck = 0.7
			_fruit_fork_chance = 0.2
			_fruit_hop_chance = 0.3
			_mandatory_hops = 4
			_max_shown_card_count = 8
			_max_fork_count = 1
		4:
			outer_fruit_count = 3
			inner_fruit_count = 2
			_mistake_luck = 0.7
			_fruit_fork_chance = 0.2
			_fruit_hop_chance = 0.3
			_mandatory_hops = 5
			_max_shown_card_count = 6
			_max_fork_count = 1
		5:
			outer_fruit_count = 3
			inner_fruit_count = 3
			_mistake_luck = 0.6
			_fruit_fork_chance = 0.3
			_fruit_hop_chance = 0.5
			_mandatory_hops = 6
			_max_shown_card_count = 4
			_max_fork_count = 1
		6:
			outer_fruit_count = 4
			inner_fruit_count = 3
			_mistake_luck = 0.4
			_fruit_fork_chance = 0.5
			_fruit_hop_chance = 0.8
			_mandatory_hops = 8
			_max_shown_card_count = 3
			_max_fork_count = 2
		7:
			outer_fruit_count = 6
			inner_fruit_count = 1
			_mistake_luck = 0.2
			_fruit_fork_chance = 0.0
			_fruit_hop_chance = 1.0
			_mandatory_hops = 99
			_max_fork_count = 0
		8:
			outer_fruit_count = 5
			inner_fruit_count = 3
			_mistake_luck = 0.1
			_fruit_fork_chance = 0.8
			_fruit_hop_chance = 0.8
			_mandatory_hops = 10
			_max_shown_card_count = 1
			_max_fork_count = 3
	

	
	# create outer fruit cards
	for cell_pos in OUTER_CELLS:
		var new_card := level_cards.create_card()
		new_card.card_front_type = CardControl.CardType.FISH
		new_card.card_back_details = "b" if highlight_fruits else "r"
		level_cards.add_card(new_card, cell_pos)
	
	# create a list of semi-sorted fruits. the order is similar to the ordering in CardControl.FRUIT_DETAILS, but not
	# identical
	var semi_sorted_fruits := [
	]
	var remaining_fruit_details := CardControl.FRUIT_DETAILS.duplicate()
	while remaining_fruit_details:
		var i := int(min(randi() % remaining_fruit_details.size(), randi() % remaining_fruit_details.size()))
		semi_sorted_fruits.append(remaining_fruit_details[i])
		remaining_fruit_details.remove(i)
	semi_sorted_fruits = semi_sorted_fruits.slice(0, outer_fruit_count + inner_fruit_count - 2)
	semi_sorted_fruits.shuffle()
	
	# reveal outer fruits
	var remaining_outer_cells := OUTER_CELLS.duplicate()
	remaining_outer_cells.shuffle()
	for _i in range(outer_fruit_count):
		var fruit_detail: String = semi_sorted_fruits.pop_front()
		var outer_cell: Vector2 = remaining_outer_cells.pop_front()
		var outer_card: CardControl = level_cards.get_card(outer_cell)
		outer_card.card_front_type = CardControl.CardType.FRUIT
		outer_card.card_front_details = fruit_detail
		outer_card.card_back_details = "r"
		outer_card.show_front()
		_outer_fruit_cells[outer_cell] = true
		_wrong_outer_fruit_cells_by_details[fruit_detail] = outer_cell
	
	# create inner hexagon of face-down cards
	for cell_pos in INNER_CELLS:
		var new_card := level_cards.create_card()
		new_card.card_front_type = CardControl.CardType.FISH
		level_cards.add_card(new_card, cell_pos)
		_unflipped_inner_cell_positions[cell_pos] = true
	
	# reveal center card
	var center_card := level_cards.get_card(CENTER_CELL_POS)
	center_card.card_front_type = CardControl.CardType.HEX_ARROW
	var hex_arrow_details: Array = HEX_ARROW_DETAILS_BY_ARROW_COUNT[inner_fruit_count]
	var hex_arrow_detail: String = Utils.rand_value(hex_arrow_details)
	center_card.card_front_details = hex_arrow_detail
	center_card.show_front()
	_shown_card_queue.append(center_card)
	_unflipped_inner_cell_positions.erase(CENTER_CELL_POS)
	
	# place inner fruits
	var remaining_directions := [
	]
	for i in range(center_card.card_front_details.length()):
		remaining_directions.append(center_card.card_front_details[i])
	remaining_directions.shuffle()
	while remaining_directions:
		var direction_string: String = remaining_directions.pop_front()
		var adjacent_cell_pos: Vector2 = CENTER_CELL_POS + DIRECTIONS_BY_STRING[direction_string]
		var adjacent_card := level_cards.get_card(adjacent_cell_pos)
		adjacent_card.card_front_type = CardControl.CardType.FRUIT
		if semi_sorted_fruits:
			adjacent_card.card_front_details = semi_sorted_fruits.pop_front()
		else:
			var outer_fruit_cell: Vector2 = Utils.rand_value(_outer_fruit_cells.keys())
			var outer_fruit_card := level_cards.get_card(outer_fruit_cell)
			adjacent_card.card_front_details = outer_fruit_card.card_front_details
			_correct_outer_fruit_detail = adjacent_card.card_front_details
			_wrong_outer_fruit_cells_by_details.erase(_correct_outer_fruit_detail)
		_inner_fruit_cells[adjacent_cell_pos] = true


func _frog_card() -> CardControl:
	var result: CardControl
	for cell in _outer_fruit_cells:
		var card := level_cards.get_card(cell)
		if card.card_front_type == CardControl.CardType.FROG:
			result = card
			break
	return result


func _inner_fruit_card(detail: String) -> CardControl:
	var result: CardControl
	for cell in _inner_fruit_cells:
		var inner_fruit_card := level_cards.get_card(cell)
		if inner_fruit_card.card_front_details == detail:
			result = inner_fruit_card
			break
	return result


func _hide_outer_fruits() -> void:
	for outer_fruit_cell in _outer_fruit_cells:
		level_cards.get_card(outer_fruit_cell).hide_front()
	
	var inner_fruit_details := []
	for inner_fruit_cell in _inner_fruit_cells:
		var inner_fruit_card := level_cards.get_card(inner_fruit_cell)
		inner_fruit_details.append(inner_fruit_card.card_front_details)
	
	for outer_fruit_cell in _outer_fruit_cells:
		var outer_fruit_card := level_cards.get_card(outer_fruit_cell)
		if outer_fruit_card.card_front_details in inner_fruit_details:
			# replace the matching fruit with a frog
			outer_fruit_card.card_front_type = CardControl.CardType.FROG
			outer_fruit_card.card_front_details = ""
		else:
			# replace the other fruits with sharks
			outer_fruit_card.card_front_type = CardControl.CardType.SHARK
			outer_fruit_card.card_front_details = ""


func _before_premature_frog_flipped(card: CardControl) -> void:
	if not _wrong_outer_fruit_cells_by_details:
		# can't swap the frog out; there's nobody to swap with
		return
	
	var wrong_outer_fruit_detail: String = Utils.rand_value(_wrong_outer_fruit_cells_by_details.keys())
	var other_outer_card := level_cards.get_card(_wrong_outer_fruit_cells_by_details[wrong_outer_fruit_detail])
	
	# swap the outer frog card with a shark card
	card.card_front_type = CardControl.CardType.SHARK
	other_outer_card.card_front_type = CardControl.CardType.FROG
	_inner_fruit_card(_correct_outer_fruit_detail).card_front_details = wrong_outer_fruit_detail
	
	# update the _wrong_outer_fruit_cells_by_details and _correct_outer_fruit_detail fields
	_wrong_outer_fruit_cells_by_details.erase(wrong_outer_fruit_detail)
	_wrong_outer_fruit_cells_by_details[_correct_outer_fruit_detail] = card
	_correct_outer_fruit_detail = wrong_outer_fruit_detail


func _available_fish_forks(card: CardControl, dir_count: int) -> Array:
	var card_pos := level_cards.get_cell_pos(card)
	var available_dir_strings := {}
	for dir_string in ["n", "e", "f", "s", "x", "w"]:
		var adjacent_pos: Vector2 = card_pos + DIRECTIONS_BY_STRING[dir_string]
		var adjacent_card := level_cards.get_card(adjacent_pos)
		if not adjacent_card:
			continue
		if not _unflipped_inner_cell_positions.has(adjacent_pos):
			continue
		if adjacent_card.card_front_type != CardControl.CardType.FISH:
			continue
		available_dir_strings[dir_string] = true
	
	# which adjacent non-fruit cards haven't been flipped?
	var valid_fork_strings := []
	for fork_string in HEX_ARROW_DETAILS_BY_ARROW_COUNT[dir_count]:
		# is this a valid fork string?
		var valid_fork_string := true
		for i in range(fork_string.length()):
			if not fork_string[i] in available_dir_strings:
				valid_fork_string = false
				break
		if valid_fork_string:
			valid_fork_strings.append(fork_string)
	return valid_fork_strings


func _can_forkify(card: CardControl) -> bool:
	var result := true
	if _available_fish_forks(card, 2).is_empty():
		# not enough space for a fork
		result = false
	if card.card_front_type != CardControl.CardType.FRUIT:
		# only fruits can fork
		result = false
	if CardControl.CardType.FRUIT and _fork_counts_per_fruit.get(card.card_front_details, 0) >= _max_fork_count:
		# this fruit has already forked too much
		result = false
	return result


func _forkify(card: CardControl) -> void:
	var card_pos := level_cards.get_cell_pos(card)
	var fish_fork: String = Utils.rand_value(_available_fish_forks(card, 2))
	
	# increment _fork_counts_per_fruit
	if card.card_front_type == CardControl.CardType.FRUIT:
		var old_fork_count: int = _fork_counts_per_fruit.get(card.card_front_details, 0)
		_fork_counts_per_fruit[card.card_front_details] = old_fork_count + 1
	
	# change one target card to a fruit, and the other target card to a blank space
	var target_cards := [
		level_cards.get_card(card_pos + DIRECTIONS_BY_STRING[fish_fork[0]]),
		level_cards.get_card(card_pos + DIRECTIONS_BY_STRING[fish_fork[1]]),
	]
	target_cards.shuffle()
	target_cards[0].card_front_type = card.card_front_type
	target_cards[0].card_front_details = card.card_front_details
	_inner_fruit_cells[level_cards.get_cell_pos(target_cards[0])] = true
	target_cards[1].card_front_type = CardControl.CardType.HEX_ARROW
	target_cards[1].card_front_details = ""
	
	# change the flipped card to an arrow
	card.card_front_type = CardControl.CardType.HEX_ARROW
	card.card_front_details = fish_fork
	_inner_fruit_cells.erase(card_pos)


func _can_arrowify(card: CardControl) -> bool:
	return true if _available_fish_forks(card, 1) else false


func _arrowify(card: CardControl) -> void:
	var card_pos := level_cards.get_cell_pos(card)
	var fish_fork: String = Utils.rand_value(_available_fish_forks(card, 1))
	
	# change the card which the arrow will point to. it becomes a fruit
	var target_pos: Vector2 = card_pos + DIRECTIONS_BY_STRING[fish_fork]
	var target_card := level_cards.get_card(target_pos)
	target_card.card_front_type = card.card_front_type
	target_card.card_front_details = card.card_front_details
	_inner_fruit_cells[target_pos] = true
	
	# change the flipped card to an arrow
	card.card_front_type = CardControl.CardType.HEX_ARROW
	card.card_front_details = fish_fork
	_inner_fruit_cells.erase(card_pos)


func _before_fruit_flipped(card: CardControl) -> void:
	if randf() < _fruit_fork_chance and _can_forkify(card):
		# replace it with a double arrow card
		_forkify(card)
		_mandatory_hops = int(max(_mandatory_hops - 1, 0))
	elif (randf() < _fruit_hop_chance or _mandatory_hops > 0) and _can_arrowify(card):
		# replace it with an arrow card
		_arrowify(card)
		_mandatory_hops = int(max(_mandatory_hops - 1, 0))
	elif card.card_front_details == _correct_outer_fruit_detail:
		_found_correct_inner_fruit = true


func _before_fish_flipped(card: CardControl) -> void:
	if randf() < _mistake_luck:
		# lucky; nothing happens
		pass
	else:
		# unlucky; replace it with a shark
		card.card_front_type = CardControl.CardType.SHARK


func _on_LevelCards_before_card_flipped(card: CardControl) -> void:
	var card_pos := level_cards.get_cell_pos(card)
	
	# if the outer fruits are revealed, flip them and turn them into frogs/sharks
	if not _outer_fruits_hidden:
		_hide_outer_fruits()
		_outer_fruits_hidden = true
	
	if card_pos in INNER_CELLS:
		if not _unflipped_inner_cell_positions.has(card_pos):
			# We've already flipped this card. It doesn't change.
			pass
		elif card.card_front_type == CardControl.CardType.FRUIT \
				or card.card_front_type == CardControl.CardType.HEX_ARROW and card.card_front_details == "":
			# The player clicked an inner fruit, or an empty arrow. We might replace it with an arrow.
			_before_fruit_flipped(card)
		elif card.card_front_type == CardControl.CardType.FISH:
			# The player clicked a fish. It might change to a shark.
			_before_fish_flipped(card)
		
		_shown_card_queue.append(card)
		if _shown_card_queue.size() > _max_shown_card_count:
			var old_card: CardControl = _shown_card_queue.pop_front()
			old_card.hide_front()
		
		_unflipped_inner_cell_positions.erase(card_pos)
	else:
		if card.card_front_type == CardControl.CardType.FROG and not _found_correct_inner_fruit:
			# The player clicked a frog without revealing the corresponding
			# inner fruit. The frog swaps to another outer fruit card.
			_before_premature_frog_flipped(card)
		elif card.card_front_type == CardControl.CardType.FISH:
			# The player clicked a fish. It might change to a shark.
			_before_fish_flipped(card)


func _on_LevelCards_before_shark_found(_shark_card: CardControl) -> void:
	# reveal the inner matching fruit
	var inner_fruit_card := _inner_fruit_card(_correct_outer_fruit_detail)
	inner_fruit_card.show_front()
	
	# replace the frog with a matching fruit, and reveal it
	var outer_fruit_card := _frog_card()
	outer_fruit_card.card_front_type = inner_fruit_card.card_front_type
	outer_fruit_card.card_front_details = inner_fruit_card.card_front_details
	outer_fruit_card.show_front()

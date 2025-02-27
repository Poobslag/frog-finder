class_name LevelCards
extends Control
## A visual arrangement of cards shown during a level.

signal before_card_flipped(card)
signal before_frog_found(card)
signal frog_found(card)
signal before_shark_found(card)
signal shark_found(card)

const CELL_SIZE := Vector2(80, 80)

@export var game_state: GameState

var CardControlScene: PackedScene = preload("res://src/main/CardControl.tscn")

## key: (Vector2) cell position
## value: (CardControl) card at the specified cell position
var cards_by_cell_pos := {}

## key: (CardControl) level card
## value: (Vector2) cell position of the specified card
var cell_positions_by_card := {}

var cell_pos_bounds := Rect2()

func create_card() -> CardControl:
	var card := CardControlScene.instantiate() as CardControl
	card.before_card_flipped.connect(_on_card_control_before_card_flipped.bind(card))
	card.frog_found.connect(_on_card_control_frog_found.bind(card))
	card.shark_found.connect(_on_card_control_shark_found.bind(card))
	card.before_frog_found.connect(_on_card_control_before_frog_found.bind(card))
	card.before_shark_found.connect(_on_card_control_before_shark_found.bind(card))
	return card


func add_card(card: CardControl, cell_pos: Vector2) -> void:
	# add the card
	card.position = cell_pos * CELL_SIZE
	add_child(card)
	card.game_state = game_state
	if cards_by_cell_pos.is_empty():
		cell_pos_bounds = Rect2(cell_pos, Vector2.ZERO)
	else:
		cell_pos_bounds = cell_pos_bounds.expand(cell_pos)
	cards_by_cell_pos[cell_pos] = card
	cell_positions_by_card[card] = cell_pos
	
	# resize and center the container
	position = get_parent().size * 0.5
	position -= cell_pos_bounds.position * CELL_SIZE
	position -= (cell_pos_bounds.size + Vector2(1, 1)) * CELL_SIZE * 0.5
	Global.card_shadow_caster_added.emit(card)


func get_card(cell_pos: Vector2) -> CardControl:
	return cards_by_cell_pos.get(cell_pos)


func has_card(cell_pos: Vector2) -> bool:
	return true if cards_by_cell_pos.has(cell_pos) else false


func get_cell_pos(card: CardControl) -> Vector2:
	return cell_positions_by_card.get(card)


func get_cards() -> Array[CardControl]:
	var cards: Array[CardControl] = []
	# Workaround for Godot #72627 (https://github.com/godotengine/godot/issues/72627); Cannot cast typed arrays using
	# type hints
	cards.assign(cell_positions_by_card.keys())
	return cards


func get_cell_positions() -> Array[Vector2]:
	var cell_positions: Array[Vector2] = []
	# Workaround for Godot #72627 (https://github.com/godotengine/godot/issues/72627); Cannot cast typed arrays using
	# type hints
	cell_positions.assign(cards_by_cell_pos.keys())
	return cell_positions


func reset() -> void:
	cards_by_cell_pos.clear()
	cell_positions_by_card.clear()
	for child in get_children():
		child.queue_free()
		remove_child(child)


func _on_card_control_frog_found(card: CardControl) -> void:
	frog_found.emit(card)


func _on_card_control_shark_found(card: CardControl) -> void:
	shark_found.emit(card)


func _on_card_control_before_card_flipped(card: CardControl) -> void:
	before_card_flipped.emit(card)


func _on_card_control_before_frog_found(card: CardControl) -> void:
	before_frog_found.emit(card)


func _on_card_control_before_shark_found(card: CardControl) -> void:
	before_shark_found.emit(card)

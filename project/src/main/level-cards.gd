class_name LevelCards
extends Control
## A visual arrangement of cards shown during a level.

signal before_card_flipped(card)
signal before_frog_found(card)
signal frog_found(card)
signal before_shark_found(card)
signal shark_found(card)

const CELL_SIZE := Vector2(80, 80)

@export var game_state_path: NodePath

var CardControlScene: PackedScene = preload("res://src/main/CardControl.tscn")

## key: (Vector2) cell position
## value: (CardControl) card at the specified cell position
var cards_by_cell_pos := {}

## key: (CardControl) level card
## value: (Vector2) cell position of the specified card
var cell_positions_by_card := {}

var cell_pos_bounds := Rect2()

@onready var _game_state: GameState = get_node(game_state_path)

func create_card() -> CardControl:
	var card := CardControlScene.instantiate() as CardControl
	card.connect("before_card_flipped", Callable(self, "_on_CardControl_before_card_flipped").bind(card))
	card.connect("frog_found", Callable(self, "_on_CardControl_frog_found").bind(card))
	card.connect("shark_found", Callable(self, "_on_CardControl_shark_found").bind(card))
	card.connect("before_frog_found", Callable(self, "_on_CardControl_before_frog_found").bind(card))
	card.connect("before_shark_found", Callable(self, "_on_CardControl_before_shark_found").bind(card))
	return card


func add_card(card: CardControl, cell_pos: Vector2) -> void:
	# add the card
	card.position = cell_pos * CELL_SIZE
	add_child(card)
	card.game_state_path = card.get_path_to(_game_state)
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


func get_cards() -> Array:
	return cell_positions_by_card.keys()


func get_cell_positions() -> Array:
	return cards_by_cell_pos.keys()


func reset() -> void:
	cards_by_cell_pos.clear()
	cell_positions_by_card.clear()
	for child in get_children():
		child.queue_free()
		remove_child(child)


func _on_CardControl_frog_found(card: CardControl) -> void:
	emit_signal("frog_found", card)


func _on_CardControl_shark_found(card: CardControl) -> void:
	emit_signal("shark_found", card)


func _on_CardControl_before_card_flipped(card: CardControl) -> void:
	emit_signal("before_card_flipped", card)


func _on_CardControl_before_frog_found(card: CardControl) -> void:
	emit_signal("before_frog_found", card)


func _on_CardControl_before_shark_found(card: CardControl) -> void:
	emit_signal("before_shark_found", card)

class_name LevelCards
extends Control

signal frog_found
signal shark_found

const CELL_SIZE := Vector2(80, 80)

export (NodePath) var game_state_path: NodePath

var CardControlScene: PackedScene = preload("res://src/main/CardControl.tscn")
var cards_by_cell_pos := {}
var cell_pos_bounds := Rect2()

onready var _game_state: GameState = get_node(game_state_path)

func create_card() -> CardControl:
	var card := CardControlScene.instance() as CardControl
	card.connect("frog_found", self, "_on_frog_found")
	card.connect("shark_found", self, "_on_shark_found")
	return card


func add_card(card: CardControl, cell_pos: Vector2) -> void:
	# add the card
	card.rect_position = cell_pos * CELL_SIZE
	add_child(card)
	card.game_state_path = card.get_path_to(_game_state)
	if not cards_by_cell_pos:
		cell_pos_bounds = Rect2(cell_pos, Vector2.ZERO)
	else:
		cell_pos_bounds = cell_pos_bounds.expand(cell_pos)
	cards_by_cell_pos[cell_pos] = card
	
	# resize and center the container
	rect_position = get_parent().rect_size * 0.5
	rect_position -= cell_pos_bounds.position * CELL_SIZE
	rect_position -= (cell_pos_bounds.size + Vector2(1, 1)) * CELL_SIZE * 0.5


func get_card(cell_pos: Vector2) -> CardControl:
	return cards_by_cell_pos.get(cell_pos)


func reset() -> void:
	cards_by_cell_pos.clear()
	for child in get_children():
		child.queue_free()


func _on_frog_found() -> void:
	emit_signal("frog_found")


func _on_shark_found() -> void:
	emit_signal("shark_found")
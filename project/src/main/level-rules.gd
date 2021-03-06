class_name LevelRules
extends Node

export (NodePath) var level_cards_path: NodePath setget set_level_cards_path

export (int, 8) var puzzle_difficulty: int = 0 # 0 == very easy, 8 == very hard

var level_cards: LevelCards

func _ready() -> void:
	refresh_level_cards_path()


func add_cards() -> void:
	pass


func set_level_cards_path(new_level_cards_path: NodePath) -> void:
	level_cards_path = new_level_cards_path
	refresh_level_cards_path()


func refresh_level_cards_path() -> void:
	if not is_inside_tree() or not level_cards_path:
		return
	
	level_cards = get_node(level_cards_path) if level_cards_path else null

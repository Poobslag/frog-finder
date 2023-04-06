class_name LevelRules
extends Node
## Abstract class which represents a generic set of level rules.
##
## Subclasses should extend this script to define how cards are arranged and where to find the frog.

@export var level_cards_path: NodePath : set = set_level_cards_path

@export_range(0, 8) var puzzle_difficulty: int = 0 # 0 == very easy, 8 == very hard

var level_cards: LevelCards

func _ready() -> void:
	refresh_level_cards_path()


func add_cards() -> void:
	pass


func set_level_cards_path(new_level_cards_path: NodePath) -> void:
	level_cards_path = new_level_cards_path
	refresh_level_cards_path()


func refresh_level_cards_path() -> void:
	if not is_inside_tree() or level_cards_path.is_empty():
		return
	
	level_cards = get_node(level_cards_path) if level_cards_path else null

class_name LevelRules
extends Node
## Abstract class which represents a generic set of level rules.
##
## Subclasses should extend this script to define how cards are arranged and where to find the frog.

@export var level_cards: LevelCards:
	set(new_level_cards):
		level_cards = new_level_cards
		refresh_level_cards()

@export_range(0, 8) var puzzle_difficulty: int = 0 # 0 == very easy, 8 == very hard

func add_cards() -> void:
	pass


func refresh_level_cards() -> void:
	pass

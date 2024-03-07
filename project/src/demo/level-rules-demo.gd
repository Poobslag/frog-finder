extends Node
## Demonstrates a level's rules.
##
## Keys:
## 	[space bar]: Generate a new puzzle.
## 	[=/-]: Increase/decrease the puzzle difficulty and generate a new puzzle.

@export var LevelRulesScene: PackedScene

func _ready() -> void:
	randomize()
	%GameplayPanel.mission_string = "1-1"
	_refresh_difficulty_label()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_SPACE:
			_show_puzzle()
		KEY_MINUS:
			%GameplayPanel.player_puzzle_difficulty = int(clamp(%GameplayPanel.player_puzzle_difficulty - 1, 0, 8))
			_show_puzzle()
		KEY_EQUAL:
			%GameplayPanel.player_puzzle_difficulty = int(clamp(%GameplayPanel.player_puzzle_difficulty + 1, 0, 8))
			_show_puzzle()


func _refresh_difficulty_label() -> void:
	%DifficultyLabel.text = tr("Difficulty: %s" % [%GameplayPanel.player_puzzle_difficulty])


func _show_puzzle() -> void:
	%GameplayPanel.level_ids.assign(["evasive-touch"])
	%GameplayPanel.level_rules_scenes_by_id = {"evasive-touch": LevelRulesScene}
	%GameplayPanel.reset()
	%GameplayPanel.show_puzzle()
	_refresh_difficulty_label()

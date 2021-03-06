extends Node

onready var _gameplay_panel := $GameplayPanel

export (PackedScene) var LevelRulesScene: PackedScene

func _ready() -> void:
	randomize()
	_gameplay_panel.game_difficulty = GameplayPanel.GameDifficulty.HARD


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_SPACE:
			_show_puzzle()
		KEY_EQUAL:
			_gameplay_panel.player_puzzle_difficulty = int(clamp(_gameplay_panel.player_puzzle_difficulty + 1, 0, 8))
			_show_puzzle()
		KEY_MINUS:
			_gameplay_panel.player_puzzle_difficulty = int(clamp(_gameplay_panel.player_puzzle_difficulty - 1, 0, 8))
			_show_puzzle()


func _show_puzzle() -> void:
	_gameplay_panel.level_rules_scenes = [LevelRulesScene]
	_gameplay_panel.reset()
	_gameplay_panel.show_puzzle()

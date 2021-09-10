class_name GameplayPanel
extends Panel

enum GameDifficulty {
	EASY,
	MEDIUM,
	HARD,
}

signal before_shark_found(card)
signal shark_found(card)
signal before_frog_found(card)
signal frog_found(card)

var game_difficulty: int = GameDifficulty.EASY setget set_game_difficulty
var player_puzzle_difficulty := 0
var player_streak := 0
var _level_rules: LevelRules
var _max_puzzle_difficulty := 0
var _shark_difficulty_decrease := 0
var _start_difficulty := 0

onready var _game_state := $GameState
onready var _level_cards := $LevelCards

onready var level_rules_scenes := [
	preload("res://src/main/SecretCollectLevelRules.tscn"),
	preload("res://src/main/FroggoLevelRules.tscn"),
	preload("res://src/main/FrodokuLevelRules.tscn"),
	preload("res://src/main/MazeLevelRules.tscn"),
	preload("res://src/main/WordFindLevelRules.tscn"),
]

func _ready() -> void:
	level_rules_scenes.shuffle()
	_refresh_game_difficulty()


func set_game_difficulty(new_game_difficulty: int) -> void:
	game_difficulty = new_game_difficulty
	_refresh_game_difficulty()


func show_puzzle() -> void:
	visible = true
	reset()
	_level_rules.add_cards()


func reset() -> void:
	_game_state.reset()
	
	if _level_rules:
		_level_rules.queue_free()
		remove_child(_level_rules)
	
	var next_level_rules_scene: PackedScene = level_rules_scenes.pop_front()
	level_rules_scenes.shuffle()
	level_rules_scenes.push_back(next_level_rules_scene)
	_level_rules = next_level_rules_scene.instance()
	_level_rules.puzzle_difficulty = player_puzzle_difficulty
	add_child(_level_rules)
	_level_rules.level_cards_path = _level_rules.get_path_to(_level_cards)
	
	_level_cards.reset()


func restart(new_game_difficulty: int) -> void:
	set_game_difficulty(new_game_difficulty)
	player_puzzle_difficulty = _start_difficulty
	player_streak = 0


func _refresh_game_difficulty() -> void:
	_max_puzzle_difficulty = 8
	_shark_difficulty_decrease = 2
	
	match game_difficulty:
		GameDifficulty.EASY:
			_start_difficulty = 0
			_max_puzzle_difficulty = 4
			_shark_difficulty_decrease = 4
		GameDifficulty.MEDIUM:
			_start_difficulty = 2
			_max_puzzle_difficulty = 8
			_shark_difficulty_decrease = 3
		GameDifficulty.HARD:
			_start_difficulty = 4
			_max_puzzle_difficulty = 8
			_shark_difficulty_decrease = 2


func _on_LevelCards_frog_found(card: CardControl) -> void:
	player_puzzle_difficulty = \
			int(clamp(player_puzzle_difficulty + 1, 0, _max_puzzle_difficulty))
	if player_streak >= 1:
		player_puzzle_difficulty = \
				int(clamp(player_puzzle_difficulty + 1, 0, _max_puzzle_difficulty))
	player_streak += 1
	emit_signal("frog_found", card)


func _on_LevelCards_shark_found(card: CardControl) -> void:
	player_puzzle_difficulty = \
			int(clamp(player_puzzle_difficulty - _shark_difficulty_decrease, 0, _max_puzzle_difficulty))
	player_streak = 0
	emit_signal("shark_found", card)


func _on_LevelCards_before_frog_found(card: CardControl) -> void:
	emit_signal("before_frog_found", card)


func _on_LevelCards_before_shark_found(card: CardControl) -> void:
	emit_signal("before_shark_found", card)

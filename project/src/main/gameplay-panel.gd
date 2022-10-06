class_name GameplayPanel
extends Panel

signal before_shark_found(card)
signal shark_found(card)
signal before_frog_found(card)
signal frog_found(card)

# a string like '2-3' for the current set of levels, like Super Mario Bros. '1-1' is the first set.
var mission_string := "1-1" setget set_mission_string

# difficulty ranging 0-8 for the current puzzle. 0 == very easy, 8 == very hard
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
	preload("res://src/main/PatternMemoryLevelRules.tscn"),
	preload("res://src/main/FruitMazeRules.tscn"),
]

func _ready() -> void:
	level_rules_scenes.shuffle()
	_refresh_mission_string()


func set_mission_string(new_mission_string: String) -> void:
	mission_string = new_mission_string
	_refresh_mission_string()


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


func restart(new_mission_string: String) -> void:
	set_mission_string(new_mission_string)
	player_puzzle_difficulty = _start_difficulty
	player_streak = 0


func _refresh_mission_string() -> void:
	_max_puzzle_difficulty = 8
	_shark_difficulty_decrease = 2
	
	match mission_string:
		"1-1", "2-1", "3-1":
			_start_difficulty = 0
			_max_puzzle_difficulty = 4
			_shark_difficulty_decrease = 4
		"1-2", "2-2", "3-2":
			_start_difficulty = 2
			_max_puzzle_difficulty = 8
			_shark_difficulty_decrease = 3
		"1-3", "2-3", "3-3":
			_start_difficulty = 4
			_max_puzzle_difficulty = 8
			_shark_difficulty_decrease = 2
		_:
			_start_difficulty = 0
			_max_puzzle_difficulty = 4
			_shark_difficulty_decrease = 4


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

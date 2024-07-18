class_name GameplayPanel
extends Panel
## Panel which shows the level the player is currently playing.

signal before_shark_found(card)
signal shark_found(card)
signal before_frog_found(card)
signal frog_found(card)

## List of level IDs to show if the mission is not found
const DEFAULT_LEVEL_IDS := ["froggo", "maze"]

## a string like '2-3' for the current set of levels, like Super Mario Bros. '1-1' is the first set.
var mission_string := "1-1":
	set(new_mission_string):
		mission_string = new_mission_string
		_refresh_mission_string()

## difficulty ranging 0-8 for the current puzzle. 0 == very easy, 8 == very hard
var player_puzzle_difficulty := 0
var player_streak := 0
var level_ids: Array[String]
var _level_rules: LevelRules
var _max_puzzle_difficulty := 0
var _shark_difficulty_decrease := 0
var _start_difficulty := 0

## key: (String) level id
## value: (PackedScene) scene with LevelRules for the specified level
@onready var level_rules_scenes_by_id := {
	"secret-collect": preload("res://src/main/level/SecretCollectRules.tscn"),
	"froggo": preload("res://src/main/level/FroggoRules.tscn"),
	"frodoku": preload("res://src/main/level/FrodokuRules.tscn"),
	"maze": preload("res://src/main/level/MazeRules.tscn"),
	"word-find": preload("res://src/main/level/WordFindRules.tscn"),
	"pattern-memory": preload("res://src/main/level/PatternMemoryRules.tscn"),
	"fruit-maze": preload("res://src/main/level/FruitMazeRules.tscn"),
}

func _ready() -> void:
	level_ids.assign(DEFAULT_LEVEL_IDS)
	_refresh_mission_string()


func show_puzzle() -> void:
	visible = true
	reset()
	_level_rules.add_cards()


func reset() -> void:
	%GameState.reset()
	
	if _level_rules:
		_level_rules.queue_free()
		remove_child(_level_rules)
	
	# determine the level to play
	var next_level_id: String = level_ids.pop_front()
	level_ids.push_back(next_level_id)
	
	# load the level rules and update the cards
	_level_rules = _level_rules_from_id(next_level_id)
	add_child(_level_rules)
	_level_rules.level_cards = %LevelCards
	%LevelCards.reset()


func restart(new_mission_string: String) -> void:
	mission_string = new_mission_string
	player_puzzle_difficulty = _start_difficulty
	player_streak = 0


## Loads the level rules for the specified level id, which can include a suffix.
##
## The level id combines a string id like 'froggo' with an optional difficulty adjustment suffix between '--' and '++':
##  '--': very easy; difficulty is adjusted down into the range [0, 4] inclusive
##  '-': easy; difficulty is adjusted down into the range [0, 5] inclusive
##  '+': hard; difficulty is adjusted up into the range [0, 7] inclusive
##  '++': very hard; difficulty is adjusted up into the range [0, 8] inclusive
##
## The 'hard' and 'very hard' adjustments override the maximum puzzle difficulties for the region.
func _level_rules_from_id(level_id: String) -> LevelRules:
	var puzzle_difficulty := player_puzzle_difficulty
	
	if level_id.ends_with("++"):
		level_id = level_id.trim_suffix("++")
		
		# adjust the puzzle difficulty up to a value in the range [0, 8], inclusive
		puzzle_difficulty = int(clamp(puzzle_difficulty + 2, 0, max(_max_puzzle_difficulty, 8)))
	elif level_id.ends_with("--"):
		level_id = level_id.trim_suffix("--")
		
		# adjust the puzzle difficulty down to a value in the range [0, 4], inclusive
		puzzle_difficulty = int(clamp(puzzle_difficulty - 2, 0, min(_max_puzzle_difficulty, 4)))
	elif level_id.ends_with("+"):
		level_id = level_id.trim_suffix("+")
		
		# adjust the puzzle difficulty up to a value in the range [0, 7], inclusive
		puzzle_difficulty = int(clamp(puzzle_difficulty + 1, 0, max(_max_puzzle_difficulty, 7)))
	elif level_id.ends_with("-"):
		level_id = level_id.trim_suffix("-")
		
		# adjust the puzzle difficulty down to a value in the range [0, 5], inclusive
		puzzle_difficulty = int(clamp(puzzle_difficulty - 1, 0, min(_max_puzzle_difficulty, 5)))
	
	var next_level_rules_scene: PackedScene = level_rules_scenes_by_id[level_id]
	var level_rules: LevelRules = next_level_rules_scene.instantiate()
	level_rules.puzzle_difficulty = puzzle_difficulty
	
	return level_rules


## Assigns the level_ids and difficulty settings based on the current mission string
func _refresh_mission_string() -> void:
	var mission_prefix := Utils.substring_before(mission_string, "-")
	var mission_suffix := Utils.substring_after(mission_string, "-")
	match mission_suffix:
		"1":
			_start_difficulty = 0
			_max_puzzle_difficulty = 4
			_shark_difficulty_decrease = 4
		"2":
			_start_difficulty = 2
			_max_puzzle_difficulty = 5
			_shark_difficulty_decrease = 3
		"3", _:
			_start_difficulty = 4
			_max_puzzle_difficulty = 7
			_shark_difficulty_decrease = 2
	
	var missions := WorldData.worlds[int(mission_prefix) - 1].missions[int(mission_suffix) - 1]
	level_ids.assign(missions)


func _on_level_cards_frog_found(card: CardControl) -> void:
	player_puzzle_difficulty = \
			int(clamp(player_puzzle_difficulty + 1, 0, _max_puzzle_difficulty))
	if player_streak >= 1:
		player_puzzle_difficulty = \
				int(clamp(player_puzzle_difficulty + 1, 0, _max_puzzle_difficulty))
	player_streak += 1
	frog_found.emit(card)


func _on_level_cards_shark_found(card: CardControl) -> void:
	player_puzzle_difficulty = \
			int(clamp(player_puzzle_difficulty - _shark_difficulty_decrease, 0, _max_puzzle_difficulty))
	player_streak = 0
	shark_found.emit(card)


func _on_level_cards_before_frog_found(card: CardControl) -> void:
	before_frog_found.emit(card)


func _on_level_cards_before_shark_found(card: CardControl) -> void:
	before_shark_found.emit(card)

class_name GameplayPanel
extends Panel
## Panel which shows the level the player is currently playing.

signal before_shark_found(card)
signal shark_found(card)
signal before_frog_found(card)
signal frog_found(card)

## List of level IDs to show if the mission is not found
const DEFAULT_LEVEL_IDS := ["froggo", "maze"]

## Dictionary of levels for each mission.
##
## Each mission is comprised of one or more levels and mission adjustments. Most worlds includes two training missions
## 'x-1' and 'x-2' which teaches you to play two levels, then a final mission which includes a combination of missions.
## Each level includes an optional difficulty adjustment suffix between '--' and '++', so that players can be exposed
## to easier versions of levels while they are learning the rules. The general pattern goes like this:
##
## 	x-1: (easy new level A) (old level B)
## 	x-2: (easy new level C) (old level D)
## 	x-3: (level A) (level C) (very hard level B) (very hard level D) (very easy level E)
##
## To summarize, players are trained on easy versions of levels. Then they're tested on the normal versions of those
## levels. They are also tested on very hard versions of levels they've played in the past, and they are tested on very
## easy versions of levels they've never seen before.
##
## key: (String) mission string
## value: (Array, String) level ids with an optional difficulty adjustment. '--' = very easy, '++' = very hard
const LEVEL_IDS_BY_MISSION_STRING := {
	"1-1": ["froggo-", "maze-"],
	"1-2": ["pattern-memory-", "word-find-"],
	"1-3": ["froggo", "pattern-memory", "maze", "word-find", "secret-collect--"],
	
	"2-1": ["secret-collect-", "word-find"],
	"2-2": ["fruit-maze-", "maze"],
	"2-3": ["secret-collect", "fruit-maze", "word-find++", "maze++", "frodoku--"],
	
	"3-1": ["frodoku-", "fruit-maze"],
	"3-2": ["secret-collect-", "froggo"],
	"3-3": ["frodoku", "secret-collect", "fruit-maze++", "froggo++", "pattern-memory++"],
}

## a string like '2-3' for the current set of levels, like Super Mario Bros. '1-1' is the first set.
var mission_string := "1-1" : set = set_mission_string

## difficulty ranging 0-8 for the current puzzle. 0 == very easy, 8 == very hard
var player_puzzle_difficulty := 0
var player_streak := 0
var level_ids: Array[String]
var _level_rules: LevelRules
var _max_puzzle_difficulty := 0
var _shark_difficulty_decrease := 0
var _start_difficulty := 0

@onready var _game_state := $GameState
@onready var _level_cards := $LevelCards

## key: (String) level id
## value: (PackedScene) scene with LevelRules for the specified level
@onready var level_rules_scenes_by_id := {
	"secret-collect": preload("res://src/main/levels/SecretCollectRules.tscn"),
	"froggo": preload("res://src/main/levels/FroggoRules.tscn"),
	"frodoku": preload("res://src/main/levels/FrodokuRules.tscn"),
	"maze": preload("res://src/main/levels/MazeRules.tscn"),
	"word-find": preload("res://src/main/levels/WordFindRules.tscn"),
	"pattern-memory": preload("res://src/main/levels/PatternMemoryRules.tscn"),
	"fruit-maze": preload("res://src/main/levels/FruitMazeRules.tscn"),
}

func _ready() -> void:
	level_ids.assign(DEFAULT_LEVEL_IDS)
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
	
	# determine the level to play
	var next_level_id: String = level_ids.pop_front()
	level_ids.push_back(next_level_id)
	
	# load the level rules and update the cards
	_level_rules = _level_rules_from_id(next_level_id)
	add_child(_level_rules)
	_level_rules.level_cards_path = _level_rules.get_path_to(_level_cards)
	_level_cards.reset()


func restart(new_mission_string: String) -> void:
	set_mission_string(new_mission_string)
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
	
	level_ids.assign(LEVEL_IDS_BY_MISSION_STRING.get(mission_string, DEFAULT_LEVEL_IDS))


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

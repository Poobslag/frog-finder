class_name GameplayPanel
extends Panel

signal before_shark_found
signal shark_found(card)
signal before_frog_found
signal frog_found(card)

const START_DIFFICULTY := 1

var player_difficulty := START_DIFFICULTY
var player_streak := 0
var _level_rules: LevelRules

onready var _game_state := $GameState
onready var _level_cards := $LevelCards

onready var level_rules_scenes := [
	preload("res://src/main/SecretCollectLevelRules.tscn"),
	preload("res://src/main/FroggoLevelRules.tscn"),
	preload("res://src/main/FrodokuLevelRules.tscn"),
]

func _ready() -> void:
	level_rules_scenes.shuffle()


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
	_level_rules.difficulty = player_difficulty
	add_child(_level_rules)
	_level_rules.level_cards_path = _level_rules.get_path_to(_level_cards)
	
	_level_cards.reset()


func restart() -> void:
	player_difficulty = START_DIFFICULTY
	player_streak = 0


func _on_LevelCards_frog_found(card: CardControl) -> void:
	player_difficulty = int(clamp(player_difficulty + 1, 0, 8))
	if player_streak >= 1:
		player_difficulty = int(clamp(player_difficulty + 1, 0, 8))
	player_streak += 1
	emit_signal("frog_found", card)


func _on_LevelCards_shark_found(card: CardControl) -> void:
	player_difficulty = int(clamp(player_difficulty - 2, 0, 8))
	player_streak = 0
	emit_signal("shark_found", card)


func _on_LevelCards_before_frog_found() -> void:
	emit_signal("before_frog_found")


func _on_LevelCards_before_shark_found() -> void:
	emit_signal("before_shark_found")

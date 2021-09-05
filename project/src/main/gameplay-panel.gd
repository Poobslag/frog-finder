class_name GameplayPanel
extends Panel

signal before_shark_found
signal shark_found(card)
signal before_frog_found
signal frog_found(card)

const START_DIFFICULTY := 1

onready var _game_state := $GameState
onready var _level_cards := $LevelCards
onready var _level_rules := $LevelRules

var player_difficulty := START_DIFFICULTY
var player_streak := 0

func show_puzzle() -> void:
	visible = true
	
	reset()
	_level_rules.add_cards()


func reset() -> void:
	_game_state.reset()
	_level_rules.difficulty = player_difficulty
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

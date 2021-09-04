extends Panel

signal player_lost
signal player_won

onready var _game_state := $GameState
onready var _level_cards := $LevelCards
onready var _level_rules := $LevelRules

var player_difficulty := 1
var player_streak := 0

func show_puzzle() -> void:
	visible = true
	
	_game_state.reset()
	
	_level_rules.difficulty = player_difficulty
	_level_cards.reset()
	_level_rules.add_cards()


func _on_LevelCards_frog_found() -> void:
	player_difficulty = int(clamp(player_difficulty + 1, 0, 8))
	if player_streak >= 1:
		player_difficulty = int(clamp(player_difficulty + 1, 0, 8))
	player_streak += 1
	emit_signal("player_won")


func _on_LevelCards_shark_found() -> void:
	player_difficulty = int(clamp(player_difficulty - 2, 0, 8))
	player_streak = 0
	emit_signal("player_lost")

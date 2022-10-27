class_name MainMenuPanel
extends Panel

signal start_pressed(mission_string)
signal before_frog_found(card)
signal frog_found(card)
signal before_shark_found(card)
signal shark_found(card)
signal menu_shown

onready var _game_state := $TitleGameState
onready var _level_button_holder := $LevelButtonHolder

onready var _all_cards := [
	$Card1F, $Card1R, $Card1O, $Card1G,
	$Card2F, $Card2I, $Card2N, $Card2D, $Card2E, $Card2R,
]

func _ready() -> void:
	for card in _all_cards:
		card.show_front()
		card.connect("before_frog_found", self, "_on_CardControl_before_frog_found", [card])
		card.connect("frog_found", self, "_on_CardControl_frog_found", [card])
		card.connect("before_shark_found", self, "_on_CardControl_before_shark_found", [card])
		card.connect("shark_found", self, "_on_CardControl_shark_found", [card])
	
	for card in [$Card1O, $Card2I]:
		card.hide_front()


func show_menu() -> void:
	visible = true
	_game_state.reset()
	$Card1O.reset()
	$Card2I.reset()
	
	$Card1O.card_front_type = CardControl.CardType.SHARK if randf() < 0.15 else CardControl.CardType.FROG
	$Card2I.card_front_type = CardControl.CardType.SHARK if randf() < 0.15 else CardControl.CardType.FROG
	
	emit_signal("menu_shown")


func _on_CardControl_before_frog_found(card: CardControl) -> void:
	emit_signal("before_frog_found", card)


func _on_CardControl_before_shark_found(card: CardControl) -> void:
	emit_signal("before_shark_found", card)


func _on_CardControl_frog_found(card: CardControl) -> void:
	emit_signal("frog_found", card)


func _on_CardControl_shark_found(card: CardControl) -> void:
	emit_signal("shark_found", card)


func _on_LevelButtons_level_pressed(level_index: int) -> void:
	var mission_string := Utils.mission_string(PlayerData.world_index, level_index)
	emit_signal("start_pressed", mission_string)

class_name MainMenuPanel
extends Panel
## Panel which shows the main menu where the player can adjust settings and choose missions.

## Emitted when one of the level buttons is pressed.
##
## Parameters:
## 	'mission_string': A hyphenated mission ID like '1-3' or '4-1'.
signal start_pressed(mission_string)

signal before_frog_found(card)
signal frog_found(card)
signal before_shark_found(card)
signal shark_found(card)
signal menu_shown

@onready var _game_state := $TitleGameState
@onready var _level_button_holder := $LevelButtonHolder

## List of CardControls for cards making up the phrase 'frog finder' on the main menu. Some of these cards are hidden
## so they can be clicked.
@onready var _all_cards := [
	$Title/Card1F, $Title/Card1R, $Title/Card1O, $Title/Card1G,
	$Title/Card2F, $Title/Card2I, $Title/Card2N, $Title/Card2D, $Title/Card2E, $Title/Card2R,
]

func _ready() -> void:
	for card in _all_cards:
		card.show_front()
		card.connect("before_frog_found",Callable(self,"_on_CardControl_before_frog_found").bind(card))
		card.connect("frog_found",Callable(self,"_on_CardControl_frog_found").bind(card))
		card.connect("before_shark_found",Callable(self,"_on_CardControl_before_shark_found").bind(card))
		card.connect("shark_found",Callable(self,"_on_CardControl_shark_found").bind(card))
	
	for card in [$Title/Card1O, $Title/Card2I]:
		card.hide_front()


func show_menu() -> void:
	visible = true
	_game_state.reset()
	$Title/Card1O.reset()
	$Title/Card2I.reset()
	
	$Title/Card1O.card_front_type = CardControl.CardType.SHARK if randf() < 0.15 else CardControl.CardType.FROG
	$Title/Card2I.card_front_type = CardControl.CardType.SHARK if randf() < 0.15 else CardControl.CardType.FROG
	
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

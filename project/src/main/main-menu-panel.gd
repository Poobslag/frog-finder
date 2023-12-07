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
@onready var _title := $Title

func show_menu() -> void:
	visible = true
	_game_state.reset()
	menu_shown.emit()
	_title.randomize_mystery_cards()
	_connect_title_card_listeners()


## Connect 'frog_found', 'shark_found' listeners for new title cards.
func _connect_title_card_listeners() -> void:
	if not is_node_ready():
		return
	
	for card in _title.get_children():
		if card.is_connected("before_frog_found", Callable(self, "_on_card_control_before_frog_found").bind(card)):
			# Avoid connecting redundant listeners for cards which already existed. This happens for mystery cards.
			continue
		
		card.connect("before_frog_found", Callable(self, "_on_card_control_before_frog_found").bind(card))
		card.connect("frog_found", Callable(self, "_on_card_control_frog_found").bind(card))
		card.connect("before_shark_found", Callable(self, "_on_card_control_before_shark_found").bind(card))
		card.connect("shark_found", Callable(self, "_on_card_control_shark_found").bind(card))


func _on_card_control_before_frog_found(card: CardControl) -> void:
	before_frog_found.emit(card)


func _on_card_control_before_shark_found(card: CardControl) -> void:
	before_shark_found.emit(card)


func _on_card_control_frog_found(card: CardControl) -> void:
	frog_found.emit(card)


func _on_card_control_shark_found(card: CardControl) -> void:
	shark_found.emit(card)


func _on_level_buttons_level_pressed(level_index: int) -> void:
	var mission_string := Utils.mission_string(PlayerData.world_index, level_index)
	start_pressed.emit(mission_string)


func _on_title_cards_changed() -> void:
	_connect_title_card_listeners()

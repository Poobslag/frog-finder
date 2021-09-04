extends Node

export (NodePath) var _main_menu_panel_path: NodePath
export (NodePath) var _gameplay_panel_path: NodePath
export (NodePath) var _intermission_panel_path: NodePath
export (NodePath) var _game_over_panel_path: NodePath

onready var _main_menu_panel: MainMenuPanel = get_node(_main_menu_panel_path)
onready var _gameplay_panel: GameplayPanel = get_node(_gameplay_panel_path)
onready var _intermission_panel: IntermissionPanel = get_node(_intermission_panel_path)
onready var _game_over_panel: GameOverPanel = get_node(_game_over_panel_path)

func _ready() -> void:
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_hide_panels()
	
	yield(get_tree(), "idle_frame")
	_main_menu_panel.show_menu()


func _hide_panels() -> void:
	_main_menu_panel.visible = false
	_gameplay_panel.visible = false
	_game_over_panel.visible = false
	_intermission_panel.visible = false


func _show_intermission_panel(card: CardControl) -> void:
	_hide_panels()
	_intermission_panel.add_level_result(card)
	_intermission_panel.show_intermission_panel()
	if _intermission_panel.is_full():
		# we win
		yield(get_tree().create_timer(5.0), "timeout")
		_hide_panels()
		_game_over_panel.show_player_won()
	else:
		yield(get_tree().create_timer(3.0), "timeout")
		_hide_panels()
		_gameplay_panel.show_puzzle()


func _on_MainMenuPanel_start_button_pressed() -> void:
	_hide_panels()
	_intermission_panel.restart()
	_gameplay_panel.restart()
	_gameplay_panel.show_puzzle()


func _on_GameplayPanel_shark_found(card: CardControl) -> void:
	_show_intermission_panel(card)


func _on_GameplayPanel_frog_found(card: CardControl) -> void:
	_show_intermission_panel(card)


func _on_GameOverPanel_start_button_pressed() -> void:
	_hide_panels()
	_main_menu_panel.show_menu()

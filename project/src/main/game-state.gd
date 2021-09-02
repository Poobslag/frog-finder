extends Node

export (NodePath) var _main_menu_panel_path: NodePath
export (NodePath) var _gameplay_panel_path: NodePath
export (NodePath) var _game_over_panel_path: NodePath

onready var _main_menu_panel: Panel = get_node(_main_menu_panel_path)
onready var _gameplay_panel: Panel = get_node(_gameplay_panel_path)
onready var _game_over_panel: Panel = get_node(_game_over_panel_path)

func _ready() -> void:
	_hide_panels()
	_main_menu_panel.visible = true


func _hide_panels() -> void:
	_main_menu_panel.visible = false
	_gameplay_panel.visible = false
	_game_over_panel.visible = false


func _on_MainMenuPanel_start_button_pressed() -> void:
	_hide_panels()
	_gameplay_panel.show_puzzle()


func _on_GameplayPanel_player_lost() -> void:
	_hide_panels()
	_game_over_panel.show_player_lost()


func _on_GameplayPanel_player_won() -> void:
	_hide_panels()
	_game_over_panel.show_player_won()


func _on_GameOverPanel_start_button_pressed() -> void:
	_hide_panels()
	_gameplay_panel.visible = true

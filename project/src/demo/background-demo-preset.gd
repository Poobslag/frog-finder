extends MarginContainer
## Demonstrates the background, using the game's preset colors.
##
## This demo is useful for testing the game's logic for picking preset colors.

const MAX_WORLD_INDEX := 99

@export var background: Background

@onready var _label := $VBoxContainer/HBoxContainer/Label

func _ready() -> void:
	PlayerData.connect("world_index_changed", Callable(self, "_on_player_data_world_index_changed"))
	_refresh_label_text()


func _refresh_label_text() -> void:
	_label.text = "World %s" % [PlayerData.world_index + 1]


func _on_world_down_button_pressed() -> void:
	PlayerData.world_index = int(clamp(PlayerData.world_index - 1, 0, MAX_WORLD_INDEX))


func _on_world_up_button_pressed() -> void:
	PlayerData.world_index = int(clamp(PlayerData.world_index + 1, 0, MAX_WORLD_INDEX))


func _on_go_button_pressed() -> void:
	background.change()


func _on_player_data_world_index_changed() -> void:
	_refresh_label_text()

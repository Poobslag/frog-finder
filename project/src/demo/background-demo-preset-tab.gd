extends MarginContainer
## Demonstrates the background, using the game's preset colors.
##
## This demo is useful for testing the game's logic for picking preset colors.

const MAX_WORLD_INDEX := 99

@export var background: Background

func _ready() -> void:
	PlayerData.world_index_changed.connect(_on_player_data_world_index_changed)
	_refresh_label_text()


func _refresh_label_text() -> void:
	%WorldLabel.text = "World %s" % [PlayerData.world_index + 1]


func _on_world_down_button_pressed() -> void:
	PlayerData.world_index = int(clamp(PlayerData.world_index - 1, 0, MAX_WORLD_INDEX))


func _on_world_up_button_pressed() -> void:
	PlayerData.world_index = int(clamp(PlayerData.world_index + 1, 0, MAX_WORLD_INDEX))


func _on_go_button_pressed() -> void:
	background.change()


func _on_player_data_world_index_changed() -> void:
	_refresh_label_text()

extends Control
## The level and world buttons visible on the main menu.
##
## This script shows and hides the buttons and emits signals as the different buttons are pressed.

## Emitted when the 'previous world' button is pressed.
signal prev_world_pressed

## Emitted when the 'next world' button is pressed.
signal next_world_pressed

## Emitted when one of the level buttons is pressed.
##
## Parameters:
## 	'level_index': A number in the range [0, 2] for which button was pressed.
signal level_pressed(level_index)

@onready var _level_buttons := [%Level1, %Level2, %Level3]

func _ready() -> void:
	var main_menu_panels: Array[Node] = get_tree().get_nodes_in_group("main_menu_panels")
	if main_menu_panels.size() == 1:
		main_menu_panels[0].menu_shown.connect(_on_main_menu_panel_menu_shown)
	else:
		push_warning("Unexpected main menu panel count: %s" % [main_menu_panels.size()])


func _on_prev_pressed() -> void:
	prev_world_pressed.emit()


func _on_next_pressed() -> void:
	next_world_pressed.emit()


func _on_level_pressed(level_index: int) -> void:
	level_pressed.emit(level_index)


func _on_main_menu_panel_menu_shown() -> void:
	var world_index := get_index()
	
	for level_index in range(_level_buttons.size()):
		var level_button: ClickableIcon = _level_buttons[level_index]
		var mission_string := Utils.mission_string(world_index, level_index)
		match PlayerData.get_mission_cleared(mission_string):
			PlayerData.MissionResult.NONE:
				level_button.icon_index = level_index * 3 + 0
			PlayerData.MissionResult.SHARK:
				level_button.icon_index = level_index * 3 + 1
			PlayerData.MissionResult.FROG:
				level_button.icon_index = level_index * 3 + 2
	
	var boss_mission := Utils.mission_string(world_index, 2)
	if PlayerData.get_mission_cleared(boss_mission) != PlayerData.MissionResult.NONE \
			and get_index() < get_parent().get_child_count() - 1:
		%Next.visible = true
	else:
		%Next.visible = false

extends Control

signal prev_world_pressed
signal next_world_pressed
signal level_pressed(level_index)

onready var next_button: Node = $Next

onready var _level_buttons := [$Level1, $Level2, $Level3]

func _ready() -> void:
	var main_menu_panels: Array = get_tree().get_nodes_in_group("main_menu_panels")
	if main_menu_panels.size() == 1:
		main_menu_panels[0].connect("menu_shown", self, "_on_MainMenuPanel_menu_shown")
	else:
		push_warning("Unexpected main menu panel count: %s" % [main_menu_panels.size()])


func _on_Prev_pressed() -> void:
	emit_signal("prev_world_pressed")


func _on_Next_pressed() -> void:
	emit_signal("next_world_pressed")


func _on_Level_pressed(level_index: int) -> void:
	emit_signal("level_pressed", level_index)


func _on_MainMenuPanel_menu_shown() -> void:
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
		next_button.visible = true
	else:
		next_button.visible = false

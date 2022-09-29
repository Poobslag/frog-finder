extends Control

signal prev_world_pressed
signal next_world_pressed
signal level_pressed(level_index)

func _on_Prev_pressed() -> void:
	emit_signal("prev_world_pressed")


func _on_Next_pressed() -> void:
	emit_signal("next_world_pressed")


func _on_Level_pressed(level_index: int) -> void:
	emit_signal("level_pressed", level_index)

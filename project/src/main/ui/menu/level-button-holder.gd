extends Control

func _ready() -> void:
	_refresh_world_index(get_current_world_index())


func set_current_world_index(new_current_world_index: int) -> void:
	new_current_world_index = int(clamp(new_current_world_index, 0, get_child_count()))
	_refresh_world_index(new_current_world_index)


func get_current_world_index() -> int:
	var result := -1
	for i in range(get_child_count()):
		if get_child(i).visible:
			result = i
	return result


## Ensure exactly one set of world buttons is visible.
func _refresh_world_index(new_current_world_index: int) -> void:
	if new_current_world_index == -1:
		new_current_world_index = 0
	
	for i in range(get_child_count()):
		get_child(i).visible = true if i == new_current_world_index else false


func _on_LevelButtons_next_world_pressed() -> void:
	var old_world_index := get_current_world_index()
	set_current_world_index(old_world_index + 1)


func _on_LevelButtons_prev_world_pressed() -> void:
	var old_world_index := get_current_world_index()
	set_current_world_index(old_world_index - 1)

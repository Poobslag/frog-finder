extends Control

func _ready() -> void:
	_refresh_world_index()
	PlayerData.connect("world_index_changed", Callable(self, "_on_PlayerData_world_index_changed"))


## Ensure exactly one set of world buttons is visible.
func _refresh_world_index() -> void:
	var new_world_index := PlayerData.world_index
	if new_world_index == -1:
		new_world_index = 0
	
	for i in range(get_child_count()):
		get_child(i).visible = true if i == new_world_index else false


## Returns the currently visible child index, which is used instead of world index in some cases.
##
## The visible child index should almost always match the world index unless there is a bug. But if there is a bug,
## it's possible our 3rd child will be visible when the world index is 5. Rather than letting the player advance the
## world index to 6, 7, and 8 -- we recalculate the new world index based on the current visible child, not the current
## world index.
func _current_visible_child_index() -> int:
	var result := -1
	for i in range(get_child_count()):
		if get_child(i).visible:
			result = i
			break
	return result


func _on_LevelButtons_next_world_pressed() -> void:
	var visible_child_index := _current_visible_child_index()
	PlayerData.world_index = int(clamp(visible_child_index + 1, 0, get_child_count()))


func _on_LevelButtons_prev_world_pressed() -> void:
	var visible_child_index := _current_visible_child_index()
	PlayerData.world_index = int(clamp(visible_child_index - 1, 0, get_child_count()))


func _on_PlayerData_world_index_changed() -> void:
	_refresh_world_index()

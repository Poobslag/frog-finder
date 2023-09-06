extends Control
## Shows the decorations for the currently selected world.

func _ready() -> void:
	_refresh_world_index()
	PlayerData.connect("world_index_changed", Callable(self, "_on_PlayerData_world_index_changed"))


## Ensure exactly one set of world decorations is visible.
func _refresh_world_index() -> void:
	var new_world_index := PlayerData.world_index
	if new_world_index == -1:
		new_world_index = 0
	
	for i in range(get_child_count()):
		get_child(i).visible = true if i == new_world_index else false


func _on_PlayerData_world_index_changed() -> void:
	_refresh_world_index()

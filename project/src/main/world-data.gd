extends Node
## Stores information about all worlds, such as their music, intermissions and levels.

const DATA_FILENAME := "res://assets/main/world-data.json"

var worlds: Array[World] = []

func _ready() -> void:
	_load_world_data()


func get_world(index: int) -> World:
	return worlds[index]


func _load_world_data() -> void:
	if not FileAccess.file_exists(DATA_FILENAME):
		return
	var data_text := FileAccess.get_file_as_string(DATA_FILENAME)
	var test_json_conv := JSON.new()
	test_json_conv.parse(data_text)
	var worlds_json: Array = test_json_conv.get_data()
	for world_data_json in worlds_json:
		var new_world: World = World.new()
		new_world.from_json_dict(world_data_json)
		worlds.append(new_world)

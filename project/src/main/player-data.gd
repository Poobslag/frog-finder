extends Node

enum MissionResult {
	NONE, # The player has not finished this mission yet
	SHARK, # The player finished the mission by getting eaten
	FROG, # The player finished the mission by finding enough frogs
}

enum MusicPreference {
	RANDOM,
	MUSIC_1, # first song in each area; 'long song'
	MUSIC_2, # second song in each area; 'short song'
	MUSIC_3, # third song in each area; 'instrumental song'
	OFF,
}

const DATA_FILENAME := "user://player-data.json"

signal world_index_changed
signal music_preference_changed

var world_index := 0 setget set_world_index
var music_preference: int = MusicPreference.RANDOM setget set_music_preference
var frog_count := 0
var shark_count := 0

## key: (String) hyphenated mission ID like '1-3' or '4-1'
## value: (int) enum from MissionResult defining the mission result
var missions_cleared := {}

var save_json := {}

func _ready() -> void:
	load_player_data()


func set_mission_cleared(mission_string: String, mission_result: int) -> void:
	missions_cleared[mission_string] = mission_result


## Returns an enum from MissionResult for how the player did on a set of levels.
##
## Parameters:
## 	'mission_string': A hyphenated mission ID like '1-3' or '4-1'.
##
## Result:
## 	An enum from MissionResult specifying how the player did on a set of levels.
func get_mission_cleared(mission_string: String) -> int:
	return missions_cleared.get(mission_string, MissionResult.NONE)


func set_world_index(new_world_index: int) -> void:
	world_index = new_world_index
	emit_signal("world_index_changed")


func set_music_preference(new_music_preference: int) -> void:
	music_preference = new_music_preference
	emit_signal("music_preference_changed")


func increment_music_preference() -> void:
	set_music_preference((music_preference + 1) % MusicPreference.size())


func save_player_data() -> void:
	var new_save_json := {}
	new_save_json["world"] = world_index
	new_save_json["music_preference"] = music_preference
	new_save_json["frog_count"] = frog_count
	new_save_json["shark_count"] = shark_count
	new_save_json["missions_cleared"] = missions_cleared
	
	if new_save_json != save_json:
		FileUtils.write_file(DATA_FILENAME, JSON.print(new_save_json, "  "))


func load_player_data() -> void:
	if not FileUtils.file_exists(DATA_FILENAME):
		return
	var save_text := FileUtils.get_file_as_text(DATA_FILENAME)
	save_json = parse_json(save_text)
	
	# backwards compatibility; music_preference used to range from 0-7
	if save_json.has("music_preference") and int(save_json["music_preference"]) > MusicPreference.OFF:
		save_json["music_preference"] = MusicPreference.RANDOM
	
	if save_json.has("world"):
		set_world_index(int(save_json["world"]))
	if save_json.has("music_preference"):
		# handle old music preference; used to go from 0-7
		set_music_preference(int(save_json["music_preference"]))
	if save_json.has("frog_count"):
		frog_count = int(save_json["frog_count"])
	if save_json.has("shark_count"):
		shark_count = int(save_json["shark_count"])
	if save_json.has("missions_cleared"):
		var new_missions_cleared: Dictionary = save_json["missions_cleared"]
		_convert_float_values_to_ints(new_missions_cleared)
		missions_cleared = new_missions_cleared


## Converts the float values in a Dictionary to int values.
##
## Godot's JSON parser converts all ints into floats, so we need to change them back. See Godot #9499
## https://github.com/godotengine/godot/issues/9499
static func _convert_float_values_to_ints(dict: Dictionary) -> void:
	for key in dict:
		if dict[key] is float:
			dict[key] = int(dict[key])

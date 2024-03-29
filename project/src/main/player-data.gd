extends Node
## Stores the player's progress and settings.
##
## This includes details about their progression through the game such as how many frogs they've found and which levels
## they've cleared. It also includes details about their settings such as whether they want music to play.

signal world_index_changed
signal music_preference_changed

enum MissionResult {
	NONE, ## The player has not finished this mission yet
	SHARK, ## The player finished the mission by getting eaten
	FROG, ## The player finished the mission by finding enough frogs
}

enum MusicPreference {
	RANDOM, ## Random song from each area
	MUSIC_1, ## First song in each area; 'long song'
	MUSIC_2, ## Second song in each area; 'short song'
	MUSIC_3, ## Third song in each area; 'instrumental song'
	OFF, ## No music
}

const DATA_FILENAME := "user://player-data.json"

var world_index := 0:
	set(new_world_index):
		world_index = new_world_index
		world_index_changed.emit()

var music_preference: int = MusicPreference.RANDOM:
	set(new_music_preference):
		music_preference = new_music_preference
		music_preference_changed.emit()

var frog_count := 0
var shark_count := 0

## number of times the player has watched frogs dance
var frog_dance_count := 0

## key: (String) hyphenated mission ID like '1-3' or '4-1'
## value: (int) enum from MissionResult defining the mission result
var missions_cleared := {}

## key: comic name like 'world-1-intro'
## value: (bool) true
var comics_shown := {}

## key: (String) save data key
## key: (?) save data value for the specified key
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


func get_world() -> World:
	return WorldData.get_world(world_index)


func increment_music_preference() -> void:
	music_preference = (music_preference + 1) % MusicPreference.size()


func save_player_data() -> void:
	var new_save_json := {}
	new_save_json["world"] = world_index
	new_save_json["music_preference"] = music_preference
	new_save_json["frog_count"] = frog_count
	new_save_json["shark_count"] = shark_count
	new_save_json["missions_cleared"] = missions_cleared
	new_save_json["frog_dance_count"] = frog_dance_count
	new_save_json["comics_shown"] = comics_shown
	
	if new_save_json != save_json:
		FileAccess.open(DATA_FILENAME, FileAccess.WRITE).store_string(JSON.stringify(new_save_json, "  "))


func load_player_data() -> void:
	if not FileAccess.file_exists(DATA_FILENAME):
		return
	var save_text := FileAccess.get_file_as_string(DATA_FILENAME)
	var test_json_conv := JSON.new()
	test_json_conv.parse(save_text)
	save_json = test_json_conv.get_data()
	
	# backwards compatibility; music_preference used to range from 0-7
	if save_json.has("music_preference") and int(save_json["music_preference"]) > MusicPreference.OFF:
		save_json["music_preference"] = MusicPreference.RANDOM
	
	if save_json.has("music_preference"):
		# handle old music preference; used to go from 0-7
		music_preference = int(save_json["music_preference"])
	if save_json.has("world"):
		world_index = int(save_json["world"])
	if save_json.has("frog_count"):
		frog_count = int(save_json["frog_count"])
	if save_json.has("shark_count"):
		shark_count = int(save_json["shark_count"])
	if save_json.has("missions_cleared"):
		var new_missions_cleared: Dictionary = save_json["missions_cleared"]
		Utils.convert_dict_floats_to_ints(new_missions_cleared)
		missions_cleared = new_missions_cleared
	if save_json.has("frog_dance_count"):
		frog_dance_count = int(save_json["frog_dance_count"])
	if save_json.has("comics_shown"):
		comics_shown = save_json["comics_shown"]

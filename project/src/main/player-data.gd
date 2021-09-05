class_name PlayerData
extends Node

const DATA_FILENAME := "user://player-data.json"

export (NodePath) var _music_player_path: NodePath

onready var _music_player: MusicPlayer = get_node(_music_player_path)

var frog_count := 0
var shark_count := 0
var save_json := {}

func _ready() -> void:
	load_player_data()


func save_player_data() -> void:
	var new_save_json := {}
	new_save_json["music_preference"] = _music_player.music_preference
	new_save_json["frog_count"] = frog_count
	new_save_json["shark_count"] = shark_count
	if new_save_json != save_json:
		write_file(DATA_FILENAME, JSON.print(new_save_json, "  "))


func load_player_data() -> void:
	if not file_exists(DATA_FILENAME):
		return
	var save_text := get_file_as_text(DATA_FILENAME)
	save_json = parse_json(save_text)
	if save_json.has("music_preference"):
		_music_player.music_preference = save_json["music_preference"]
		_music_player.play_preferred_song()
	if save_json.has("frog_count"):
		frog_count = save_json["frog_count"]
	if save_json.has("shark_count"):
		shark_count = save_json["shark_count"]


static func file_exists(path: String) -> bool:
	var f := File.new()
	var exists := f.file_exists(path)
	f.close()
	return exists


static func get_file_as_text(path: String) -> String:
	if not file_exists(path):
		push_error("File not found: %s" % path)
		return ""
	
	var f := File.new()
	f.open(path, File.READ)
	var text := f.get_as_text()
	f.close()
	return text


static func write_file(path: String, text: String) -> void:
	var f := File.new()
	f.open(path, f.WRITE)
	f.store_string(text)
	f.close()

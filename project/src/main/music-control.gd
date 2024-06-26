extends Control
## Button which lets the player control the music.

const WIGGLE_FRAMES_BY_MUSIC_PREFERENCE := {
	PlayerData.MusicPreference.RANDOM: [0, 1],
	PlayerData.MusicPreference.MUSIC_1: [2, 3],
	PlayerData.MusicPreference.MUSIC_2: [6, 7],
	PlayerData.MusicPreference.MUSIC_3: [10, 11],
	PlayerData.MusicPreference.OFF: [14, 15],
}

func _ready() -> void:
	_refresh_sprite()
	PlayerData.music_preference_changed.connect(_on_player_data_music_preference_changed)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & MOUSE_BUTTON_LEFT:
		PlayerData.increment_music_preference()


func _refresh_sprite() -> void:
	if not is_inside_tree():
		return
	
	# workaround for Godot #72627 (https://github.com/godotengine/godot/issues/72627); Cannot cast typed arrays using
	# type hints
	%IconSprite.wiggle_frames.assign(WIGGLE_FRAMES_BY_MUSIC_PREFERENCE[PlayerData.music_preference])
	%IconSprite.assign_wiggle_frame()


func _on_player_data_music_preference_changed() -> void:
	_refresh_sprite()

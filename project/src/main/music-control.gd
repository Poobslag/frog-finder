extends Control
## Button which lets the player control the music.

const WIGGLE_FRAMES_BY_MUSIC_PREFERENCE := {
	PlayerData.MusicPreference.RANDOM: [0, 1],
	PlayerData.MusicPreference.MUSIC_1: [2, 3],
	PlayerData.MusicPreference.MUSIC_2: [6, 7],
	PlayerData.MusicPreference.MUSIC_3: [10, 11],
	PlayerData.MusicPreference.OFF: [14, 15],
}

@onready var _sprite: WiggleSprite = $Sprite2D

func _ready() -> void:
	_refresh_sprite()
	PlayerData.connect("music_preference_changed",Callable(self,"_on_PlayerData_music_preference_changed"))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & MOUSE_BUTTON_LEFT:
		PlayerData.increment_music_preference()


func _refresh_sprite() -> void:
	if not is_inside_tree():
		return
	
	# workaround for Godot #58285; typed arrays don't work with setters
	_sprite.wiggle_frames = WIGGLE_FRAMES_BY_MUSIC_PREFERENCE[PlayerData.music_preference] as Array[int]
	_sprite.assign_wiggle_frame()


func _on_PlayerData_music_preference_changed() -> void:
	_refresh_sprite()

extends Control

const WIGGLE_FRAMES_BY_MUSIC_PREFERENCE := {
	MusicPlayer.MusicPreference.RANDOM: [0, 1],
	MusicPlayer.MusicPreference.MUSIC_1: [2, 3],
	MusicPlayer.MusicPreference.MUSIC_2: [4, 5],
	MusicPlayer.MusicPreference.MUSIC_3: [6, 7],
	MusicPlayer.MusicPreference.MUSIC_4: [8, 9],
	MusicPlayer.MusicPreference.OFF: [10, 11],
}

export (NodePath) var music_player_path: NodePath

onready var _sprite: WiggleSprite = $Sprite
onready var _music_player := get_node(music_player_path)

func _ready() -> void:
	refresh_sprite()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & BUTTON_LEFT:
		_music_player.increment_music_preference()


func refresh_sprite() -> void:
	if not is_inside_tree():
		return
	
	_sprite.wiggle_frames = WIGGLE_FRAMES_BY_MUSIC_PREFERENCE[_music_player.music_preference]
	_sprite.assign_wiggle_frame()

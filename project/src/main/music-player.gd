class_name MusicPlayer
extends Node

signal music_preference_changed

enum MusicPreference {
	RANDOM,
	MUSIC_1,
	MUSIC_2,
	MUSIC_3,
	MUSIC_4,
	OFF,
}

# volume to fade out to; once the music reaches this volume, it's stopped
const MIN_VOLUME := -40.0

# volume to fade in to
const MAX_VOLUME := 0.0

const FADE_OUT_DURATION := 0.8
const FADE_IN_DURATION := 0.5

var music_preference: int = MusicPreference.RANDOM setget set_music_preference
var _current_song: AudioStreamPlayer
var _position_by_song := {}

onready var _songs_by_music_preference := {
	MusicPreference.RANDOM: [$AWellTemperedFrog, $CanYouFindTheFrog, $HalfAFrog, $OneFrogTwoFrog],
	MusicPreference.MUSIC_1: [$AWellTemperedFrog],
	MusicPreference.MUSIC_2: [$CanYouFindTheFrog],
	MusicPreference.MUSIC_3: [$HalfAFrog],
	MusicPreference.MUSIC_4: [$OneFrogTwoFrog],
	MusicPreference.OFF: [],
}

onready var _frog_songs := [$AWellTemperedFrog, $CanYouFindTheFrog, $HalfAFrog, $OneFrogTwoFrog]
onready var _shark_song := $WeAreTheBaddies
onready var _ending_song := $HugFromAFrog

onready var _fade_tween := $FadeTween

func _ready() -> void:
	# wait for player data to load before playing our preferred song
	yield(get_tree(), "idle_frame")
	play_preferred_song()


func play_preferred_song() -> void:
	var songs: Array = _songs_by_music_preference[music_preference]
	var new_song: AudioStreamPlayer
	if songs:
		songs.shuffle()
		
		new_song = songs.pop_front()
		# shuffle the song order, but put our song in the back
		songs.shuffle()
		songs.push_back(new_song)
	else:
		new_song = null
	_play_song(new_song)


func _play_song(new_song: AudioStreamPlayer) -> void:
	if _current_song and _current_song != new_song:
		fade_out()
	var previous_song := _current_song
	_current_song = new_song
	if _current_song != previous_song:
		if _current_song:
			var from_position: float = _position_by_song.get(_current_song, 0)
			_current_song.play(from_position)
			if from_position != 0:
				# interpolate when playing a song from the middle, to avoid pops and clicks
				_current_song.volume_db = MIN_VOLUME
				_fade_tween.remove(_current_song, "volume_db")
				_fade_tween.interpolate_property(_current_song, "volume_db", _current_song.volume_db, MAX_VOLUME, FADE_IN_DURATION)
			else:
				_current_song.volume_db = MAX_VOLUME
		
		_fade_tween.start()


func play_shark_song() -> void:
	_play_song(_shark_song)


func fade_out(duration := FADE_OUT_DURATION) -> void:
	_position_by_song[_current_song] = _current_song.get_playback_position()
	_fade_tween.remove(_current_song, "volume_db")
	_fade_tween.interpolate_property(_current_song, "volume_db", _current_song.volume_db, MIN_VOLUME, duration)
	_fade_tween.start()
	_current_song = null


func play_ending_song() -> void:
	if _position_by_song.get(_ending_song, 0.0) > 80:
		# more than half way through the ending song; start over
		_position_by_song.erase(_ending_song)
	_play_song(_ending_song)


func is_playing_shark_song() -> bool:
	return _current_song == _shark_song


func is_playing_frog_song() -> bool:
	return _current_song in _frog_songs


func increment_music_preference() -> void:
	set_music_preference((music_preference + 1) % MusicPreference.size())
	play_preferred_song()


func set_music_preference(new_music_preference: int) -> void:
	if new_music_preference == music_preference:
		return
	
	music_preference = new_music_preference
	emit_signal("music_preference_changed")


func _on_FadeTween_tween_completed(object: Object, key: NodePath) -> void:
	if key == ":volume_db" and object.volume_db == MIN_VOLUME:
		object.stop()

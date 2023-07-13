extends Node
## Manages all of the songs in the game and plays music appropriately.

## Volume to fade out to; once the music reaches this volume, it's stopped
const MIN_VOLUME := -40.0

## Volume to fade in to
const MAX_VOLUME := 0.0

const FADE_OUT_DURATION := 0.8
const FADE_IN_DURATION := 0.5

var _current_song: AudioStreamPlayer

## key: (AudioStreamPlayer) song
## value: (float) previous playback position
var _position_by_song := {}

## key: (AudioStreamPlayer) song
## value: (Tween) tween adjusting volume
var _tweens_by_song := {}

## List of AudioStreamPlayer instances to play if the world does not define any music.
@onready var _default_songs := [
	[$ItsAWonderfulFrog, $CanYouFindTheFrog, $AWellTemperedFrogInstrumental]
]

## song to play when the frogs dance after a stage
@onready var _dance_song := $FrogDance

## AudioStreamPlayer instance to play if the world does not define a shark song.
@onready var _default_shark_song := $WeAreTheBaddies

## key: (int) world index
## value: (Array, AudioStreamPlayer) list of frog songs to play for a world
@onready var _songs_by_world_index := {
	0: [$ItsAWonderfulFrog, $CanYouFindTheFrog, $AWellTemperedFrogInstrumental],
	1: [$RainyDayFrog, $ImGonnaFindThatFrog, $ImJustAFrogInstrumental],
	2: [$StillCantFindTheFrog, $HalfAFrog, $SneakySneakyFrogInstrumental],
}

## List of AudioStreamPlayer instances corresponding to 'frog songs', songs which play by default or when the player
## finds a frog
@onready var _frog_songs := [
	$AWellTemperedFrog, $AWellTemperedFrogInstrumental, $CanYouFindTheFrog, $HalfAFrog,
	$ImGonnaFindThatFrog, $ImJustAFrog, $ImJustAFrogInstrumental, $ItsAWonderfulFrog, $LostInTheFrog, $OneFrogTwoFrog,
	$RainyDayFrog, $SneakySneakyFrog, $SneakySneakyFrogInstrumental, $StillCantFindTheFrog, $TakeComfortInYourFrog,
]

## List of AudioStreamPlayer instances corresponding to 'shark songs', songs which play when the player finds a shark
@onready var _shark_songs := [
	$WereGonnaEatYouUp, $WeAreTheBaddies,
]

## key: (int) world index
## value: (Array, AudioStreamPlayer) list of shark songs to play for a world
@onready var _shark_song_by_world_index := {
	0: $WeAreTheBaddies,
	1: $WereGonnaEatYouUp,
	2: $WereGonnaEatYouUp,
}

## AudioStreamPlayer which plays when the player finds enough frogs to finish a mission.
@onready var _ending_song := $HugFromAFrog

func _ready() -> void:
	PlayerData.connect("music_preference_changed",Callable(self,"_on_PlayerData_music_preference_changed"))
	PlayerData.connect("world_index_changed",Callable(self,"_on_PlayerData_world_index_changed"))


func play_preferred_song() -> void:
	var world_songs: Array = _songs_by_world_index.get(PlayerData.world_index, _default_songs)
	match PlayerData.music_preference:
		PlayerData.MusicPreference.MUSIC_1:
			world_songs = [world_songs[0]]
		PlayerData.MusicPreference.MUSIC_2:
			world_songs = [world_songs[1]]
		PlayerData.MusicPreference.MUSIC_3:
			world_songs = [world_songs[2]]
		PlayerData.MusicPreference.OFF:
			world_songs = []
		_, PlayerData.MusicPreference.RANDOM:
			world_songs = world_songs.duplicate()
	
	var new_song: AudioStreamPlayer
	if world_songs.size() == 1:
		new_song = world_songs[0]
	elif world_songs.size() > 1:
		if _current_song == world_songs[0]:
			# playing the main song from this world; switch to a non-main song
			new_song = world_songs[randi_range(1, world_songs.size() - 1)]
		elif _current_song == world_songs[1] or _current_song == world_songs[2]:
			# playing a non-main song from this world; switch to the main song
			new_song = world_songs[0]
		else:
			var song_index := -1
			for other_world_songs in _songs_by_world_index.values():
				song_index = other_world_songs.find(_current_song)
				if song_index != -1:
					break
			
			if song_index == -1:
				# playing no song, or a shark song, or something unusual
				new_song = Utils.rand_value(world_songs)
			else:
				new_song = world_songs[song_index]
	_play_song(new_song)


func _play_song(new_song: AudioStreamPlayer) -> void:
	if _current_song and _current_song != new_song:
		fade_out()
	var previous_song := _current_song
	_current_song = new_song
	if _current_song != previous_song:
		if _current_song:
			var from_position: float = _position_by_song.get(_current_song, 0)
			
			# This line often triggers a warning because of Godot #75762
			# (https://github.com/godotengine/godot/issues/75762). There is no known workaround.
			_current_song.play(from_position)
			
			if from_position != 0:
				# sample when playing a song from the middle, to avoid pops and clicks
				_current_song.volume_db = MIN_VOLUME
				_fade(_current_song, MAX_VOLUME, FADE_IN_DURATION)
			else:
				_current_song.volume_db = MAX_VOLUME


func play_shark_song() -> void:
	var shark_song: AudioStreamPlayer = _shark_song_by_world_index.get(PlayerData.world_index, _default_shark_song)
	_play_song(shark_song)


func play_dance_song() -> void:
	# dance song does not save position
	_position_by_song.erase(_dance_song)
	_play_song(_dance_song)


func fade_out(duration := FADE_OUT_DURATION) -> void:
	if not _current_song:
		return
	
	_position_by_song[_current_song] = _current_song.get_playback_position()
	_fade(_current_song, MIN_VOLUME, duration)
	_current_song = null


## Force the currently playing song to fade in.
##
## This can be called immediately after playing a song to ensure it fades in, rather than starting abruptly.
func fade_in(duration := FADE_OUT_DURATION) -> void:
	if not _current_song:
		return
	
	_current_song.volume_db = MIN_VOLUME
	_fade(_current_song, MAX_VOLUME, duration)


func play_ending_song() -> void:
	if _position_by_song.get(_ending_song, 0.0) > 80:
		# more than half way through the ending song; start over
		_position_by_song.erase(_ending_song)
	_play_song(_ending_song)


func is_playing_shark_song() -> bool:
	return _current_song in _shark_songs


func is_playing_frog_song() -> bool:
	return _current_song in _frog_songs


func is_playing_dance_song() -> bool:
	return _current_song == _dance_song


func is_playing_ending_song() -> bool:
	return _current_song == _ending_song


func get_playback_position() -> float:
	var result := 0.0
	if _current_song:
		result = _current_song.get_playback_position()
	return result


## Slowly apply a fade in or fade out effect to the specified song.
##
## Parameters:
## 	'song': The song to fade in or fade out
##
## 	'new_volume_db': The volume_db value to fade to
##
## 	'duration': The duration of the fade effect
func _fade(song: AudioStreamPlayer, new_volume_db: float, duration: float) -> void:
	if _tweens_by_song.has(song):
		_tweens_by_song[song].kill()
	_tweens_by_song[song] = create_tween()
	var fade_tween: Tween = _tweens_by_song[song]
	fade_tween.tween_property(song, "volume_db", new_volume_db, duration)
	
	if new_volume_db == MIN_VOLUME:
		## stop playback after music fades out
		fade_tween.tween_callback(_current_song.stop)


func _on_PlayerData_music_preference_changed() -> void:
	play_preferred_song()


func _on_PlayerData_world_index_changed() -> void:
	play_preferred_song()


func _on_FrogDance_finished() -> void:
	_current_song = null

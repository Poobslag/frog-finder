extends Node

onready var songs: Array = [
	$AWellTemperedFrog,
	$CanYouFindTheFrog,
	$HalfAFrog,
	$OneFrogTwoFrog,
]


func _ready() -> void:
	randomize()
	songs.shuffle()
	
	var song: AudioStreamPlayer = songs.pop_front()
	song.play()
	# shuffle the song order, but put our song in the back
	songs.shuffle()
	songs.push_back(song)

extends Node
## Demonstrates the music player.
##
## Keys:
## 	[D]: Play a dance song
## 	[E]: Play an ending song
## 	[P]: Play a normal level song
## 	[S]: Play shark song

func _ready() -> void:
	PlayerData.music_preference = PlayerData.MusicPreference.RANDOM
	PlayerData.world_index = 0


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_D:
			MusicPlayer.play_dance_song()
		KEY_E:
			MusicPlayer.play_ending_song()
		KEY_P:
			MusicPlayer.play_preferred_song()
		KEY_S:
			MusicPlayer.play_shark_song()

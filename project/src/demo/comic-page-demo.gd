extends Node
## Demonstrates the comic animation.
##
## Keys:
## 	[P]: Play/stop the comic animation.
## 	[right brace key]: Advance the comic animation

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_P:
			if $ComicPage.is_playing():
				$ComicPage.stop()
			else:
				$ComicPage.play()
		KEY_BRACKETRIGHT:
			$ComicPage.advance(3.0)
		KEY_BRACKETLEFT:
			$ComicPage.advance(-3.0)

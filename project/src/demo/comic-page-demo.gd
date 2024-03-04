extends Node
## Demonstrates the comic animation.
##
## Keys:
## 	[0-9]: Select the comic scene to play.
## 	[P]: Play/stop the comic animation.
## 	[brace keys]: Advance/rewind the comic animation

@export_range(0, 1) var default_comic_index := 0

var _comic_page: ComicPage

@onready var _comic_scenes_by_index := {
	0: preload("res://src/main/comic/World1ComicPage.tscn"),
	1: preload("res://src/main/comic/World2ComicPage.tscn"),
}

@onready var _label := $Label

func _ready() -> void:
	_set_page(_comic_scenes_by_index[default_comic_index])


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1:
			_set_page(_comic_scenes_by_index[0])
		KEY_2:
			_set_page(_comic_scenes_by_index[1])
		KEY_P:
			if _comic_page.is_playing():
				_comic_page.stop()
			else:
				_comic_page.play()
		KEY_BRACKETLEFT:
			_comic_page.advance(-3.0)
		KEY_BRACKETRIGHT:
			_comic_page.advance(3.0)


func _set_page(comic_scene: PackedScene) -> void:
	if _comic_page:
		remove_child(_comic_page)
		_comic_page.queue_free()
		_comic_page = null
	
	_comic_page = comic_scene.instantiate()
	_comic_page.name = "ComicPage"
	add_child(_comic_page)
	
	_label.text = comic_scene.resource_path

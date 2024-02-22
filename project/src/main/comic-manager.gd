extends Control
## Shows comic interludes.
##
## These comic interludes are shown on the main menu when the player launches the game or enters a new world. This node
## stores a library of which scenes contain which interludes. It loads the appropriate scenes and plays the animations.

@export var main_menu_panel: Panel

## key: (String) comic id
## value: (PackedScene) comic scene for the specified world
@onready var comic_scenes_by_id := {
	"world-1-intro": preload("res://src/main/comic/World1ComicPage.tscn"),
	"world-2-intro": preload("res://src/main/comic/World2ComicPage.tscn"),
}

## The number of time the main menu has been shown since launching the game. We play a comic interlude the first time
## the game is launched.
var _main_menu_show_count := 0

func _ready() -> void:
	PlayerData.world_index_changed.connect(_on_player_data_world_index_changed)


## Shows the comic interlude for the current world.
##
## Parameters:
## 	'force': If true, the comic interlude will play even if the player has seen it before.
func show_comic(force: bool = false) -> void:
	var comic_id := "world-%s-intro" % [PlayerData.world_index + 1]
	if not comic_scenes_by_id.has(comic_id):
		# no comic for this world
		return
	
	if not force and PlayerData.comics_shown.has(comic_id):
		# player has already seen this comic
		return
	
	PlayerData.comics_shown[comic_id] = true
	if has_node("ComicPage"):
		remove_child($ComicPage)
	var new_comic_page: Control = comic_scenes_by_id[comic_id].instantiate()
	new_comic_page.name = "ComicPage"
	add_child(new_comic_page)
	$ComicPage.play()


## When the main menu panel is shown for the first time, we show a comic interlude.
func _on_main_menu_panel_panel_menu_shown() -> void:
	_main_menu_show_count += 1
	
	if _main_menu_show_count == 1:
		# show an intro comic when the player launches the game
		show_comic(true)


## When the player navigates to a new world for the first time, we show a comic interlude.
func _on_player_data_world_index_changed() -> void:
	if main_menu_panel.visible:
		# show an intro comic when the player reaches a new chapter
		show_comic()


func _on_cheat_code_detector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "fromic":
		detector.play_cheat_sound(true)
		show_comic(true)

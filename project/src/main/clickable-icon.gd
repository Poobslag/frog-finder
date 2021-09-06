extends Control

signal button_pressed

enum IconType {
	BYE,
	FIND,
	DONT_FIND,
	LOVE,
	DONT_LOVE,
	EASY,
	MEDIUM,
	HARD,
}

const WIGGLE_FRAMES_BY_ICON_TYPE := {
	IconType.BYE: [0, 1],
	IconType.FIND: [2, 3],
	IconType.DONT_FIND: [4, 5],
	IconType.LOVE: [6, 7],
	IconType.DONT_LOVE: [8, 9],
	IconType.EASY: [10, 11],
	IconType.MEDIUM: [12, 13],
	IconType.HARD: [14, 15],
}

const WOW_COUNT := 4

export (IconType) var icon_type: int setget set_icon_type

func _ready() -> void:
	refresh_sprite()
	var wow_sprite_index := randi() % WOW_COUNT
	$WowSprite.wiggle_frames = [wow_sprite_index * 2 + 0, wow_sprite_index * 2 + 1]


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & BUTTON_LEFT:
		emit_signal("button_pressed")


func set_icon_type(new_icon_type: int) -> void:
	icon_type = new_icon_type
	refresh_sprite()


func refresh_sprite() -> void:
	if not is_inside_tree():
		return
	
	$IconSprite.wiggle_frames = WIGGLE_FRAMES_BY_ICON_TYPE[icon_type]
	$IconSprite.assign_wiggle_frame()

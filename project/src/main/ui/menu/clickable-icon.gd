@tool
class_name ClickableIcon
extends Control
## A clickable menu icon which looks like a card.
##
## These icons look like cards used in puzzles, but can be clicked while they are face-up. For this reason we surround
## them with 'wow sprites' so that the player understands they are interactive.

signal pressed

@export var icon_texture: Texture2D:
	set(new_icon_texture):
		icon_texture = new_icon_texture
		_refresh_sprite()

@export var icon_index: int:
	set(new_icon_index):
		icon_index = new_icon_index
		_refresh_sprite()

@onready var _icon_sprite := $IconSprite

func _ready() -> void:
	_refresh_sprite()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_icon_sprite = $IconSprite


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & MOUSE_BUTTON_LEFT:
		pressed.emit()


func _refresh_sprite() -> void:
	if not is_inside_tree():
		return
	
	Utils.assign_card_texture(_icon_sprite, icon_texture)
	_icon_sprite.wiggle_frames = [2 * icon_index + 0, 2 * icon_index + 1] as Array[int]
	_icon_sprite.assign_wiggle_frame()

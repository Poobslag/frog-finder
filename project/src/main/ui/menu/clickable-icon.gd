tool
class_name ClickableIcon
extends Control

signal pressed

export (Texture) var icon_texture: Texture setget set_icon_texture
export (int) var icon_index: int setget set_icon_index

onready var _icon_sprite := $IconSprite

## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_icon_sprite = $IconSprite


func _ready() -> void:
	_refresh_sprite()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & BUTTON_LEFT:
		emit_signal("pressed")


func set_icon_texture(new_icon_texture: Texture) -> void:
	icon_texture = new_icon_texture
	_refresh_sprite()


func set_icon_index(new_icon_index: int) -> void:
	icon_index = new_icon_index
	_refresh_sprite()


func _refresh_sprite() -> void:
	if not is_inside_tree():
		return
	
	Utils.assign_card_texture(_icon_sprite, icon_texture)
	_icon_sprite.wiggle_frames = [2 * icon_index + 0, 2 * icon_index + 1]
	_icon_sprite.assign_wiggle_frame()

class_name Background
extends Control

const TWEEN_DURATION := 2.5
const BACKGROUND_COLOR := Color("3679a5")
const TEXTURE_COLOR := Color("45a5e6")

# the background texture at the front of the list is currently visible
onready var textures := [
	$TextureRect1, $TextureRect2, $TextureRect3, $TextureRect4,
	$TextureRect5, $TextureRect6, $TextureRect7, $TextureRect8,
	$TextureRect9, $TextureRect10, $TextureRect11, $TextureRect12,
	$TextureRect13, $TextureRect14, $TextureRect15, $TextureRect16,
	$TextureRect17, $TextureRect18, $TextureRect19, $TextureRect20,
	$TextureRect21, $TextureRect22, $TextureRect23, $TextureRect24,
	$TextureRect25, $TextureRect26, $TextureRect27, $TextureRect28,
	$TextureRect29, $TextureRect30, $TextureRect31, $TextureRect32,
	$TextureRect33, $TextureRect34, $TextureRect35, $TextureRect36,
	$TextureRect37, $TextureRect38, $TextureRect39, $TextureRect40,
]

var hues := [
	0.0,
	0.05,
	0.10,
	0.15,
	0.20,
	0.30,
	0.40,
	0.50,
	0.55,
	0.60,
	0.63,
	0.66,
	0.70,
	0.75,
	0.80,
	0.90,
]

onready var _color_rect := $ColorRect
onready var _change_tween := $ChangeTween

func _ready() -> void:
	change(true)


func change(immediate: bool = false) -> void:
	var previous_texture: TextureRect = textures.pop_front()
	textures.shuffle()
	textures.push_back(previous_texture)
	textures[0].visible = true
	
	var previous_hue: float = hues.pop_front()
	hues.shuffle()
	hues.push_back(previous_hue)
	
	var texture_color := Color().from_hsv(hues[0], rand_range(0.5, 0.8), 0.50)
	var rect_color := Color().from_hsv(texture_color.h, texture_color.s, 0.25)
	
	if randf() < 0.3:
		var swap := texture_color
		texture_color = rect_color
		rect_color = swap
	
	if immediate:
		previous_texture.visible = false
		_color_rect.color = rect_color
		textures[0].modulate = texture_color
	else:
		textures[0].modulate = to_transparent(texture_color)
		
		_change_tween.interpolate_property(_color_rect, "color",
				_color_rect.color, rect_color, TWEEN_DURATION)
		_change_tween.interpolate_property(textures[0], "modulate",
				textures[0].modulate, texture_color, TWEEN_DURATION)
		_change_tween.interpolate_property(previous_texture, "modulate",
				previous_texture.modulate, to_transparent(previous_texture.modulate), TWEEN_DURATION)
		_change_tween.start()


func _on_ChangeTween_tween_completed(object: Object, key: NodePath) -> void:
	if key == ":modulate" and object.modulate.a == 0.0:
		object.visible = false


"""
Returns a transparent version of the specified color.

Tweening from forest green to 'Color.transparent' results in some strange in-between frames which are grey or white.
It's better to tween to a transparent forest green.
"""
static func to_transparent(color: Color, alpha := 0.0) -> Color:
	return Color(color.r, color.g, color.b, alpha)

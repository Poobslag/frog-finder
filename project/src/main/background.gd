class_name Background
extends Control
## Draws the animal backdrop which appears behind the menus and puzzles.

const TWEEN_DURATION := 2.5
const BACKGROUND_COLOR := Color("3679a5")
const TEXTURE_COLOR := Color("45a5e6")

## Hue values in the range [0, 1] used for backgrounds. The hue at the front of the list is currently visible.
var hues := [
	0.0, 0.05, 0.10, 0.15, 0.20,
	0.30, 0.40, 0.50, 0.55, 0.60,
	0.63, 0.66, 0.70, 0.75, 0.80,
	0.90,
]

var texture_color: Color

## TextureRect instances used for backgrounds. The texture at the front of the list is currently visible.
@onready var textures := [
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

func _ready() -> void:
	PlayerData.world_index_changed.connect(_on_player_data_world_index_changed)
	
	var new_texture_color := _random_texture_color_for_world()
	change_specific(new_texture_color, true)


## Changes to a random background color and texture.
func change() -> void:
	var new_texture_color := _random_texture_color_for_world()
	change_specific(new_texture_color)


## Returns a random background texture color, using a generic set of preselected hues.
func random_texture_color() -> Color:
	var previous_hue: float = hues.pop_front()
	hues.shuffle()
	hues.push_back(previous_hue)
	return Color.from_hsv(hues[0], randf_range(0.5, 0.8), 0.50)


## Changes to a specific background color and random texture.
##
## Parameters:
## 	'new_texture_color': The color to change to.
##
## 	'immediate': (Optional) If true, skips the smooth color transition.
func change_specific(new_texture_color: Color, immediate: bool = false) -> void:
	texture_color = new_texture_color
	var previous_texture: TextureRect = textures.pop_front()
	textures.shuffle()
	textures.push_back(previous_texture)
	textures[0].visible = true
	
	var rect_color := Color.from_hsv(new_texture_color.h, new_texture_color.s, 0.25)
	
	if randf() < 0.3:
		var swap := new_texture_color
		new_texture_color = rect_color
		rect_color = swap
	
	if immediate:
		previous_texture.visible = false
		%ColorRect.color = rect_color
		textures[0].modulate = new_texture_color
	else:
		# Workaround for Godot #69282 (https://github.com/godotengine/godot/issues/69282); calling static function
		# from within a class generates a warning
		@warning_ignore("static_called_on_instance")
		textures[0].modulate = to_transparent(new_texture_color)
		
		var change_tween := create_tween().set_parallel()
		change_tween.tween_property(%ColorRect, "color",
				rect_color, TWEEN_DURATION)
		change_tween.tween_property(textures[0], "modulate",
				new_texture_color, TWEEN_DURATION)
		# Workaround for Godot #69282 (https://github.com/godotengine/godot/issues/69282); calling static function
		# from within a class generates a warning
		@warning_ignore("static_called_on_instance")
		change_tween.tween_property(previous_texture, "modulate",
				to_transparent(previous_texture.modulate), TWEEN_DURATION)
		change_tween.chain().tween_callback(_on_change_tween_tween_completed.bind(previous_texture))


func _random_texture_color_for_world() -> Color:
	var result: Color
	
	if PlayerData.get_world().background_colors:
		# the world defines colors; return a random one
		var possible_colors := PlayerData.get_world().background_colors
		if texture_color in possible_colors and possible_colors.size() >= 2:
			# don't return the same color we're already using
			possible_colors.remove_at(possible_colors.find(texture_color))
		
		result = Utils.rand_value(possible_colors)
	else:
		# the world doesn't define colors; use the 'random_texture_color' function
		result = random_texture_color()
	
	return result


func _on_change_tween_tween_completed(previous_texture: TextureRect) -> void:
	previous_texture.visible = false


func _on_player_data_world_index_changed() -> void:
	change()


## Returns a transparent version of the specified color.
##
## Tweening from forest green to 'Color.TRANSPARENT' results in some strange in-between frames which are grey or white.
## It's better to tween to a transparent forest green.
static func to_transparent(color: Color, alpha := 0.0) -> Color:
	return Color(color.r, color.g, color.b, alpha)

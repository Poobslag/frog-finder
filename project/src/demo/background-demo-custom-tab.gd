extends Node
## Demonstrates the background, letting the user customize the background colors.
##
## This demo is useful for creating and testing new color themes. The colors are output in GDScript so they can be
## copied into the game's code.

@export var PickerRowScene: PackedScene
@export var background: Background

var _suppress_listeners := false

func _ready() -> void:
	# remove all color pickers
	_refresh_picker_row_count(0)
	
	var colors := []
	for _i in range(5):
		colors.append(background.random_texture_color())
	
	_refresh_text_from_color_array(colors)
	_refresh_from_text()
	
	PlayerData.world_index_changed.connect(_on_player_data_world_index_changed)


## Refreshes the TextEdit contents from the picker rows.
func _refresh_text_from_picker_buttons() -> void:
	_suppress_listeners = true
	var colors := _colors_from_picker_buttons()
	_refresh_text_from_color_array(colors)
	_suppress_listeners = false


## Refreshes the TextEdit contents from the specified color array.
func _refresh_text_from_color_array(colors: Array) -> void:
	var color_strings := []
	for color in colors:
		color_strings.append(color.to_html(false))
	%TextEdit.text = JSON.stringify(color_strings)


## Calculate the color strings from our picker rows.
func _colors_from_picker_buttons() -> Array:
	var colors := []
	for picker_row_obj in get_tree().get_nodes_in_group("picker_rows"):
		var picker_row: BackgroundDemoPickerRow = picker_row_obj
		colors.append(picker_row.color)
	if colors.is_empty():
		colors.append(Color.BLACK)
	return colors


func _picker_row_count() -> int:
	return get_tree().get_nodes_in_group("picker_rows").size()


## Refreshes the picker rows and button states from the TextEdit contents.
func _refresh_from_text() -> void:
	_suppress_listeners = true
	
	# calculate the colors from the text edit
	var parsed_colors := _parse_colors_from_text()
	
	# add or remove picker rows
	_refresh_picker_row_count(parsed_colors.size())
	
	# update picker row colors
	_refresh_picker_row_colors(parsed_colors)
	
	%AddButton.disabled = parsed_colors.size() >= 10
	%RemoveButton.disabled = parsed_colors.size() <= 1
	
	_suppress_listeners = false


## Parse a color array from the TextEdit contents.
##
## Returns:
## 	A list of Color instances parsed from the TextEdit contents.
func _parse_colors_from_text() -> Array:
	var parsed_colors := []
	
	var test_json_conv := JSON.new()
	test_json_conv.parse(%TextEdit.text)
	var result_obj = test_json_conv.get_data()
	if result_obj is Array:
		for result_item in result_obj:
			parsed_colors.append(Color.from_string(result_item, Color.BLACK))
	
	if not parsed_colors:
		parsed_colors = [Color.BLACK]
	
	return parsed_colors


## Adds/removes picker rows to match the specified count.
##
## Parameters:
## 	'new_picker_row_count': The desired number of picker rows.
func _refresh_picker_row_count(new_picker_row_count: int) -> void:
	var picker_rows := get_tree().get_nodes_in_group("picker_rows")
	if new_picker_row_count > picker_rows.size():
		for _i in range(new_picker_row_count - picker_rows.size()):
			_add_picker_row()
	elif picker_rows.size() > new_picker_row_count:
		for _i in range(picker_rows.size() - new_picker_row_count):
			_remove_picker_row()


## Updates the picker rows colors to match the specified colors.
##
## Parameters:
## 	'new_colors': A list of Color instances to assign to the picker rows.
func _refresh_picker_row_colors(new_colors: Array) -> void:
	var picker_rows := get_tree().get_nodes_in_group("picker_rows")
	for i in range(picker_rows.size()):
		picker_rows[i].color = new_colors[i]


func _add_picker_row() -> void:
	var new_picker: BackgroundDemoPickerRow = PickerRowScene.instantiate()
	%PickerContainer.add_child(new_picker)
	
	# connect listeners
	new_picker.go_button_pressed.connect(_on_picker_row_color_picked)
	new_picker.color_picked.connect(_on_picker_row_go_button_pressed)
	new_picker.shuffle_button_pressed.connect(_on_picker_row_shuffle_button_pressed.bind(_picker_row_count() - 1))


func _remove_picker_row() -> void:
	var picker_rows := get_tree().get_nodes_in_group("picker_rows")
	var picker_row: BackgroundDemoPickerRow = picker_rows.back()
	picker_row.queue_free()
	%PickerContainer.remove_child(picker_row )


func _on_picker_row_color_picked(color: Color) -> void:
	_refresh_text_from_picker_buttons()
	background.change_specific(color)


func _on_picker_row_go_button_pressed(color: Color) -> void:
	background.change_specific(color)


func _on_picker_row_shuffle_button_pressed(picker_row_index: int) -> void:
	var new_color := background.random_texture_color()
	
	var colors := _colors_from_picker_buttons()
	colors[picker_row_index] = new_color
	_refresh_text_from_color_array(colors)
	_refresh_from_text()
	background.change_specific(new_color)


func _on_text_edit_text_changed() -> void:
	_refresh_from_text()


func _on_add_button_pressed() -> void:
	var colors := _colors_from_picker_buttons()
	colors.append(Color.BLACK)
	_refresh_text_from_color_array(colors)
	_refresh_from_text()


func _on_remove_button_pressed() -> void:
	var colors := _colors_from_picker_buttons()
	colors.pop_back()
	_refresh_text_from_color_array(colors)
	_refresh_from_text()


## When the world index changes, we refresh the color pickers to the world's colors.
##
## This lets us review and edit the color palettes for each world by hopping between the 'preset' and 'custom' tabs.
func _on_player_data_world_index_changed() -> void:
	var colors := PlayerData.get_world().background_colors
	if colors:
		_refresh_text_from_color_array(colors)
		_refresh_from_text()

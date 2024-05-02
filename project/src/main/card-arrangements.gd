extends Node
## Stores the arrangements of the cards shown between levels.
##
## Cards are arranged in different shapes like a baseball hat or a bowtie. These shapes are stored in a json file as
## ASCII pictures which are easy for humans to read. This script converts those pictures into coordinates which are
## easy for computers to use.

## Path3D to the json file with card arrangements. Can be changed for tests.
const DEFAULT_ARRANGEMENTS_PATH := "res://assets/main/card-arrangements.json"

## The card arrangement to use if no arrangement can be found.
const DEFAULT_CARD_POSITIONS := [
	Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
	Vector2(0.5, 1), Vector2(1.5, 1),
	Vector2(1, 0),
]

## An ordered sequence of chars used in ASCII pictures.
##
## ASCII pictures don't need to use all of these characters, it is OK to skip some. It is arguably more intuitive to
## skip zero, that way the number '5' corresponds to the fifth level. This sequence defines which ones come earlier.
const ORDERED_CHARS := "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

## Path3D to the json file with card arrangements. Can be changed for tests.
var arrangements_path := DEFAULT_ARRANGEMENTS_PATH:
	set(new_arrangements_path):
		arrangements_path = new_arrangements_path
		_load_raw_json_data()

## If 'true', every mission will only have one level.
##
## This setting is enabled with a cheat code.
var one_frog_cheat: bool = false

## key: (String) A mission string such as '1-3' or '4-1' corresponding to a sequence of levels.
## value: (Array, Vector2) Cards positions for that mission, measured in card widths. For instance, [1, 3] corresponds
## 	to the 2nd row and 4th column. These card positions also define how many levels are in the mission, as the mission
## 	is complete when all cards are turned over.
var _card_positions_by_mission_string := {}

## key: (String) A character used in ASCII pictures.
## value: (int) A number corresponding to how early the card should appear in the arrangement.
var _index_by_char := {}

func _ready() -> void:
	for i in range(ORDERED_CHARS.length()):
		_index_by_char[ORDERED_CHARS[i]] = i
	
	_load_raw_json_data()


func get_card_positions(mission_string: String) -> Array[Vector2]:
	var result: Array[Vector2] = _card_positions_by_mission_string.get(mission_string, DEFAULT_CARD_POSITIONS)
	
	# cheat is enabled; just one frog
	if one_frog_cheat:
		result = [Vector2.ZERO]
	
	return result


## Converts an ASCII picture into a list of coordinates.
##
## Example input:
## 	["  1  ",
## 	 "2   4",
## 	 "  3  "]
##
## The ascii picture is an array of strings, where each string corresponds to a row in the picture and each character
## corresponds to a column in the picture. Characters like '1', '2' and '3' correspond to positions of cards.
## Characters like ' ' correspond to empty space.
##
## The response is a list of coordinates like [[1, 0], [0, 0.5]] corresponding to the positions of cards, where
## [2, 0.5] corresponds to a card in the third column, and half-way between the first and second rows. Coordinates in
## the ascii picture are divided by two to allow for cards to fall between rows/columns for more complex pictures.
##
## Parameters:
## 	'picture': (Array, String) An array of strings corresponding to an ASCII picture defining a card arrangement.
##
## Returns:
## 	An array of Vector2 instances defining an ordering of card positions, measured in card widths. For example,
## 	[2, 0.5] corresponds to a card in the third column, and half-way between the first and second rows.
func positions_from_picture(picture: Array[String]) -> Array[Vector2]:
	# key: (int) char index like '1' or '11' corresponding to the picture characters '1' or 'b'
	# value: (Vector2) coordinate in the picture
	var coords_by_char_index := {}
	
	# convert the picture to a key/value
	for pic_y in range(picture.size()):
		var row_string: String = picture[pic_y]
		for pic_x in row_string.length():
			var pic_char := row_string[pic_x]
			if pic_char in _index_by_char:
				coords_by_char_index[_index_by_char[pic_char]] = Vector2(pic_x, pic_y)
	
	if coords_by_char_index:
		# determine the leftmost and uppermost card positions
		var min_coord: Vector2 = coords_by_char_index.values()[0]
		for char_index in coords_by_char_index:
			var coord: Vector2 = coords_by_char_index[char_index]
			min_coord.x = min(min_coord.x, coord.x)
			min_coord.y = min(min_coord.y, coord.y)
		
		# adjust card positions so that the leftmost and uppermost cards are at position zero
		for char_index in coords_by_char_index:
			var coord: Vector2 = coords_by_char_index[char_index]
			coords_by_char_index[char_index] = coord - min_coord
	
	var sorted_char_indexes := coords_by_char_index.keys()
	sorted_char_indexes.sort()
	
	# convert picture positions like [2, 7] into card positions like [1.0, 3.5]
	var positions: Array[Vector2] = []
	for char_index in sorted_char_indexes:
		positions.append(coords_by_char_index[char_index] * Vector2(0.5, 0.5))
	
	return positions


## Loads the card arrangements from JSON.
func _load_raw_json_data() -> void:
	_card_positions_by_mission_string.clear()
	
	var arrangements_text := FileAccess.get_file_as_string(arrangements_path)
	var test_json_conv := JSON.new()
	test_json_conv.parse(arrangements_text)
	var arrangements_json: Dictionary = test_json_conv.get_data()
	for mission_string in arrangements_json:
		var picture: Array[String] = []
		# Workaround for Godot #72627 (https://github.com/godotengine/godot/issues/72627); Cannot cast typed arrays
		# using type hints
		picture.assign(arrangements_json[mission_string])
		var positions := positions_from_picture(picture)
		_card_positions_by_mission_string[mission_string] = positions

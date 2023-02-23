extends Node
## Stores the arrangements of the frogs in frog dances.

const MAX_FROG_COUNT := 10

## Path to the json file with frog arrangements. Can be changed for tests.
const DEFAULT_ARRANGEMENTS_PATH := "res://assets/main/frog-arrangements.json"

## The card arrangement to use if no arrangement can be found.
const DEFAULT_FROG_POSITIONS := [
	Vector2(0, 0),
]

## Number of dancers which should appear after each dance.
##
## The number increases gradually from one frog to ten frogs, and then resets back to one.
var FROG_DANCER_COUNTS := [
	 1,  2,  3,
	 2,  3,  4,
	 3,  4,  5,
	 4,  5,  6,
	 5,  6,  7,
	 6,  7,  8,
	 7,  8,  9,
	 8,  9, 10,
	 9, 10, 10,
	10, 10,  1,
	10,  1,  2,
]

## Path to the json file with card arrangements. Can be changed for tests.
var arrangements_path := DEFAULT_ARRANGEMENTS_PATH setget set_arrangements_path

## key: (int) Number of frogs in a frog dance
## value: (Array, Vector2) Arrangements for the specified frog count, measured in frog widths
var _arrangements_by_frog_count := {
}

func _ready() -> void:
	_load_raw_json_data()


func set_arrangements_path(new_arrangements_path: String) -> void:
	arrangements_path = new_arrangements_path
	_load_raw_json_data()


## Returns the number of frogs which should participate in the dance.
##
## The number of frogs increases as the player watches more dances.
##
## Parameters:
## 	'frog_dance_count': Number of times the player has watched frogs dance
func get_dancer_count(frog_dance_count: int) -> int:
	return FROG_DANCER_COUNTS[frog_dance_count % FROG_DANCER_COUNTS.size()]


## Returns a random arrangement for the specified frog count.
##
## Parameters:
## 	'frog_count': Number of frogs in a frog dance
##
## Returns:
## 	A list of coordinates like [[0, 0], [1, 0], [0, -0.5]] corresponding to the positions of frogs.
func get_arrangement(frog_count: int) -> Array:
	if not _arrangements_by_frog_count.has(frog_count):
		return DEFAULT_FROG_POSITIONS
	
	return Utils.rand_value(_arrangements_by_frog_count[frog_count])


func get_arrangements(frog_count: int) -> Array:
	return _arrangements_by_frog_count[frog_count]


## Converts an ASCII picture into a list of coordinates.
##
## Example input:
## 	["  f  ",
## 	 "f   f",
## 	 "  f  "]
##
## The ascii picture is an array of strings, where each string corresponds to a row in the picture and each character
## corresponds to a column in the picture. 'F' represents the lead frog, each arrangement should have exactly one. 'f'
## represents a backup frog. Arrangements can have any number of backup frogs. ' ' represents empty space.
##
## The response is a list of coordinates like [[0, 0], [1, 0], [0, -0.5]] corresponding to the positions of frogs.
## Entries such as [2, -0.5] correspond to a frog two frog widths to the left and one frog width behind the middle.
## Coordinates in the ascii picture are divided by two to allow for cards to fall between rows/columns for more complex
## arrangements.
##
## Parameters:
## 	'picture': (Array, String) An array of strings corresponding to an ASCII picture defining a card arrangement.
##
## Returns:
## 	An array of Vector2 instances defining frog positions, measured in frog widths. For example, [2, 0.5] corresponds
## 	to a position two frog widths to the left and one frog width behind the lead frog.
func positions_from_picture(picture: Array) -> Array:
	var coords := []
	
	# convert the picture to a key/value
	for pic_y in range(picture.size()):
		var row_string: String = picture[pic_y]
		for pic_x in row_string.length():
			var pic_char := row_string[pic_x]
			match pic_char:
				'f': coords.append(0.5 * Vector2(pic_x, pic_y))
				' ': pass
				_: print("Unexpected frog arrangement char: '%s'" % [pic_char])
	
	if coords:
		coords.sort()
		
		# determine the leftmost, uppermost, rightmost and bottommost frog positions
		var min_coord: Vector2 = coords[0]
		var max_coord: Vector2 = coords[0]
		for coord in coords:
			min_coord.x = min(min_coord.x, coord.x)
			min_coord.y = min(min_coord.y, coord.y)
			max_coord.x = max(max_coord.x, coord.x)
			max_coord.y = max(max_coord.y, coord.y)
		var center_coord := 0.5 * (max_coord + min_coord)

		# adjust frog positions so that they're centered at position [0, 0]
		for i in range(coords.size()):
			coords[i] -= center_coord
	
	return coords


## Loads the card arrangements from JSON.
func _load_raw_json_data() -> void:
	_arrangements_by_frog_count.clear()
	
	var arrangements_text := FileUtils.get_file_as_text(arrangements_path)
	var arrangements_json: Array = parse_json(arrangements_text)
	for picture in arrangements_json:
		var positions := positions_from_picture(picture)
		if not _arrangements_by_frog_count.has(positions.size()):
			_arrangements_by_frog_count[positions.size()] = []
		_arrangements_by_frog_count[positions.size()].append(positions)

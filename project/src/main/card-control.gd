@tool
class_name CardControl
extends Control
## Shows a card. These cards can turn over to reveal frogs, sharks, fruit, or other surprises.

signal before_card_flipped
signal before_frog_found
signal frog_found
signal before_shark_found
signal shark_found

enum CardFace {
	BACK,
	FRONT,
}

enum CardType {
	NONE,
	FROG,
	SHARK,
	MYSTERY,
	LETTER,
	ARROW,
	HEX_ARROW,
	FISH,
	LIZARD,
	FRUIT,
}

## key: (String) card details string corresponding to letters
## value: (Array, int) indexes which correspond to possible pairs of wiggle frames.
const LETTER_INDEXES_BY_DETAILS := {
	"a": [0],
	"d": [1],
	"e": [2],
	"f": [3, 4],
	"f1": [3],
	"f2": [4],
	"g": [5],
	"h": [6],
	"i": [7],
	"k": [8],
	"n": [9],
	"o": [10],
	"r": [11, 12],
	"r1": [11],
	"r2": [12],
	"s": [13],
}

## key: (String) card details string corresponding to a set of cardinal directions
## value: (Array, int) indexes which correspond to possible pairs of wiggle frames.
const ARROW_INDEXES_BY_DETAILS := {
	"": [0, 1],
	"n": [2, 3, 4],
	"e": [5, 6, 7],
	"s": [8, 9, 10],
	"w": [11, 12, 13],
	"ne": [14, 15, 16],
	"se": [17, 18, 19],
	"sw": [20, 21, 22],
	"nw": [23, 24, 25],
	"ns": [26, 27, 28],
	"ew": [29, 30, 31],
}

## Hex arrows have six directions: north, south, east, forst, west, xeath.
## They are referenced in that exact order for forks (southeast, northxeath, forstwest)
##
##    n
## w  |  e
##  \_|_/
##  / | \
## x  |  f
##    s
##
## key: (String) card details string corresponding to a set of hex directions
## value: (Array, int) indexes which correspond to possible pairs of wiggle frames.
const HEX_ARROW_INDEXES_BY_DETAILS := {
	"": [0, 1],
	"n": [2, 3, 4],
	"e": [5, 6, 7],
	"f": [8, 9, 10],
	"s": [11, 12, 13],
	"x": [14, 15, 16],
	"w": [17, 18, 19],
	"nf": [20, 21],
	"se": [22, 23],
	"sw": [24, 25],
	"nx": [26, 27],
	"ns": [28, 29],
	"ex": [30, 31, 32],
	"fw": [33, 34, 35],
	"nfx": [36, 37],
	"sew": [38, 39],
	"efwx": [40, 41],
	"nefwx": [42, 43],
	"sefwx": [44, 45],
	"nsefwx": [46, 47],
}

## List of String card details string corresponding to fruit cards' contents.
##
## These strings are ordered to match fruit-sheet.png.
const FRUIT_DETAILS := [
	"apple",
	"pear",
	"orange",
	"banana",
	"peach",
	"grape",
	"cherry",
	"strawberry",
	"kiwi",
	"pineapple",
	"watermelon",
	"pretzel",
]

## key: (String) card details string corresponding to the card back
## value: (Array, int) indexes which correspond to possible pairs of wiggle frames.
const MYSTERY_INDEXES_BY_DETAILS := {
	"": [0, 1, 2, 3],
	"b": [0, 1, 2, 3],
	"r": [4, 5, 6, 7],
}

const FROG_COUNT := 16
const SHARK_COUNT := 16
const MYSTERY_COUNT := 8
const LETTER_COUNT := 14
const ARROW_COUNT := 32
const HEX_ARROW_COUNT := 48
const FRUIT_COUNT := 12
const FISH_COUNT := 8
const LIZARD_COUNT := 32

@export var card_back_type: CardType = CardType.MYSTERY:
	set(new_card_back_type):
		card_back_type = new_card_back_type
		_refresh_card_textures()

@export var card_back_details: String:
	set(new_card_back_details):
		card_back_details = new_card_back_details
		_refresh_card_textures()

@export var card_front_type: CardType = CardType.MYSTERY:
	set(new_card_front_type):
		card_front_type = new_card_front_type
		_refresh_card_textures()

@export var card_front_details: String:
	set(new_card_front_details):
		card_front_details = new_card_front_details
		_refresh_card_textures()

@export var game_state: GameState

## 'true' if the frog/shark doesn't count, maybe because it was on the main menu
@export var practice := false

@export var shown_face := CardFace.BACK:
	set(new_shown_face):
		shown_face = new_shown_face
		_refresh_shown_face()

var _frog_sounds := [
	preload("res://assets/main/sfx/frog-voice-0.wav"),
	preload("res://assets/main/sfx/frog-voice-1.wav"),
	preload("res://assets/main/sfx/frog-voice-2.wav"),
	preload("res://assets/main/sfx/frog-voice-3.wav"),
	preload("res://assets/main/sfx/frog-voice-4.wav"),
	preload("res://assets/main/sfx/frog-voice-5.wav"),
	preload("res://assets/main/sfx/frog-voice-6.wav"),
	preload("res://assets/main/sfx/frog-voice-7.wav"),
]

var _shark_sounds := [
	preload("res://assets/main/sfx/shark-voice-0.wav"),
	preload("res://assets/main/sfx/shark-voice-1.wav"),
	preload("res://assets/main/sfx/shark-voice-2.wav"),
	preload("res://assets/main/sfx/shark-voice-3.wav"),
	preload("res://assets/main/sfx/shark-voice-4.wav"),
	preload("res://assets/main/sfx/shark-voice-5.wav"),
	preload("res://assets/main/sfx/shark-voice-6.wav"),
	preload("res://assets/main/sfx/shark-voice-7.wav"),
]

var _pending_warning := ""

@onready var _frog_sheet := preload("res://assets/main/frog-frame-00-sheet.png")
@onready var _letter_sheet := preload("res://assets/main/letter-sheet.png")
@onready var _shark_sheet := preload("res://assets/main/shark-frame-00-sheet.png")
@onready var _mystery_sheet := preload("res://assets/main/mystery-sheet.png")
@onready var _fish_sheet := preload("res://assets/main/fish-sheet.png")
@onready var _lizard_sheet := preload("res://assets/main/lizard-sheet.png")
@onready var _arrow_sheet := preload("res://assets/main/arrow-sheet.png")
@onready var _hex_arrow_sheet := preload("res://assets/main/hex-arrow-sheet.png")
@onready var _fruit_sheet := preload("res://assets/main/fruit-sheet.png")

func _ready() -> void:
	_refresh_card_textures()
	_refresh_shown_face()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & MOUSE_BUTTON_LEFT:
		_flip_card()


func _process(_delta: float) -> void:
	if _pending_warning:
		push_warning(_pending_warning)
		_pending_warning = ""


func reset() -> void:
	%CardBack.visible = true
	%CardFront.visible = false
	card_back_type = CardType.MYSTERY
	card_back_details = ""
	card_front_type = CardType.MYSTERY
	card_front_details = ""
	
	%StopDanceTimer.stop()
	%FrogFoundTimer.stop()
	%SharkFoundTimer.stop()
	_refresh_card_textures()


func is_front_shown() -> bool:
	return %CardFront.visible


func show_front() -> void:
	shown_face = CardFace.FRONT


func hide_front() -> void:
	shown_face = CardFace.BACK


func copy_from(other_card: CardControl) -> void:
	card_back_type = other_card.card_back_type
	card_back_details = other_card.card_back_details
	card_front_type = other_card.card_front_type
	card_front_details = other_card.card_front_details
	_refresh_card_textures()
	
	%CardFront.frame = other_card.get_node("%CardFront").frame
	%CardFront.wiggle_frames = other_card.get_node("%CardFront").wiggle_frames
	%CardFront.visible = other_card.get_node("%CardFront").visible
	
	%CardBack.frame = other_card.get_node("%CardBack").frame
	%CardBack.wiggle_frames = other_card.get_node("%CardBack").wiggle_frames
	%CardBack.visible = other_card.get_node("%CardBack").visible


func cheer() -> void:
	if card_front_type != CardType.FROG:
		return
	
	var frog_index := int(%CardFront.wiggle_frames[0] / 4)
	%CardFront.wiggle_frames = [frog_index * 4 + 2, frog_index * 4 + 3] as Array[int]
	var wiggle_index: int = %CardFront.frame % %CardFront.wiggle_frames.size()
	%CardFront.frame = %CardFront.wiggle_frames[wiggle_index]
	
	# reset the wiggle so the characters don't have one very abbreviated dance frame
	%CardFront.reset_wiggle()
	%StopDanceTimer.start(4.0)


func _refresh_shown_face() -> void:
	if not is_inside_tree():
		return
	
	if shown_face == CardFace.BACK and %CardBack.visible \
			or shown_face == CardFace.FRONT and %CardFront.visible:
		# appropriate card face is already shown
		return
	
	%CardBack.visible = true if shown_face == CardFace.BACK else false
	%CardFront.visible = true if shown_face == CardFace.FRONT else false
	
	if shown_face == CardFace.FRONT:
		# reset the wiggle so the characters don't have one very abbreviated dance frame
		%CardFront.reset_wiggle()


func _refresh_card_textures() -> void:
	if not is_inside_tree():
		return
	
	_refresh_card_face(%CardBack, card_back_type, card_back_details)
	_refresh_card_face(%CardFront, card_front_type, card_front_details)


func _refresh_card_face(card_sprite: Sprite2D, card_type: int, card_details: String) -> void:
	var card_randi := randi()
	
	if Engine.is_editor_hint():
		# don't randomize frames in the editor, it causes unnecessary churn in our .tscn files
		card_randi = 0
	
	_pending_warning = ""
	match card_type:
		CardType.FROG:
			Utils.assign_card_texture(card_sprite, _frog_sheet)
			var frog_index := card_randi % FROG_COUNT
			card_sprite.wiggle_frames = [4 * frog_index + 0, 4 * frog_index + 1] as Array[int]
		CardType.SHARK:
			Utils.assign_card_texture(card_sprite, _shark_sheet)
			var shark_index := card_randi % SHARK_COUNT
			card_sprite.wiggle_frames = [2 * shark_index + 0, 2 * shark_index + 1] as Array[int]
		CardType.MYSTERY:
			Utils.assign_card_texture(card_sprite, _mystery_sheet)
			var mystery_index: int
			if MYSTERY_INDEXES_BY_DETAILS.has(card_details):
				var mystery_indexes: Array[int] = []
				# Workaround for Godot #72627 (https://github.com/godotengine/godot/issues/72627); Cannot cast typed
				# arrays using type hints
				mystery_indexes.assign(MYSTERY_INDEXES_BY_DETAILS[card_details])
				# Workaround for Godot #69282 (https://github.com/godotengine/godot/issues/69282); calling static function
				# from within a class generates a warning
				@warning_ignore("static_called_on_instance")
				mystery_index = _mostly_rand_value(mystery_indexes)
			else:
				mystery_index = card_randi % MYSTERY_COUNT
			card_sprite.wiggle_frames = [2 * mystery_index + 0, 2 * mystery_index + 1] as Array[int]
		CardType.LETTER:
			Utils.assign_card_texture(card_sprite, _letter_sheet)
			var letter_index: int
			if LETTER_INDEXES_BY_DETAILS.has(card_details):
				var letter_indexes: Array[int] = []
				# Workaround for Godot #72627 (https://github.com/godotengine/godot/issues/72627); Cannot cast typed
				# arrays using type hints
				letter_indexes.assign(LETTER_INDEXES_BY_DETAILS[card_details])
				# Workaround for Godot #69282 (https://github.com/godotengine/godot/issues/69282); calling static function
				# from within a class generates a warning
				@warning_ignore("static_called_on_instance")
				letter_index = _mostly_rand_value(letter_indexes)
			else:
				# We never want random letters in a level. If this is happening, something is wrong.
				_pending_warning = "Unrecognized letter: %s" % [card_details]
				letter_index = card_randi % LETTER_COUNT
			card_sprite.wiggle_frames = [2 * letter_index + 0, 2 * letter_index + 1] as Array[int]
		CardType.ARROW:
			Utils.assign_card_texture(card_sprite, _arrow_sheet)
			var arrow_index: int
			if ARROW_INDEXES_BY_DETAILS.has(card_details):
				var arrow_indexes: Array[int] = []
				# Workaround for Godot #72627 (https://github.com/godotengine/godot/issues/72627); Cannot cast typed
				# arrays using type hints
				arrow_indexes.assign(ARROW_INDEXES_BY_DETAILS[card_details])
				# Workaround for Godot #69282 (https://github.com/godotengine/godot/issues/69282); calling static function
				# from within a class generates a warning
				@warning_ignore("static_called_on_instance")
				arrow_index = _mostly_rand_value(arrow_indexes)
			else:
				# We never want random arrows in a level. If this is happening, something is wrong.
				_pending_warning = "Unrecognized arrow: %s" % [card_details]
				arrow_index = card_randi % ARROW_COUNT
			card_sprite.wiggle_frames = [2 * arrow_index + 0, 2 * arrow_index + 1] as Array[int]
		CardType.HEX_ARROW:
			Utils.assign_card_texture(card_sprite, _hex_arrow_sheet)
			var arrow_index: int
			if HEX_ARROW_INDEXES_BY_DETAILS.has(card_details):
				var arrow_indexes: Array = HEX_ARROW_INDEXES_BY_DETAILS[card_details]
				# Workaround for Godot #69282 (https://github.com/godotengine/godot/issues/69282); calling static function
				# from within a class generates a warning
				@warning_ignore("static_called_on_instance")
				arrow_index = _mostly_rand_value(arrow_indexes)
			else:
				# We never want random arrows in a level. If this is happening, something is wrong.
				_pending_warning = "Unrecognized hex arrow: %s" % [card_details]
				arrow_index = card_randi % HEX_ARROW_COUNT
			card_sprite.wiggle_frames = [2 * arrow_index + 0, 2 * arrow_index + 1] as Array[int]
		CardType.FISH:
			Utils.assign_card_texture(card_sprite, _fish_sheet)
			var fish_index := card_randi % FISH_COUNT
			card_sprite.wiggle_frames = [2 * fish_index + 0, 2 * fish_index + 1] as Array[int]
		CardType.LIZARD:
			Utils.assign_card_texture(card_sprite, _lizard_sheet)
			var lizard_index := card_randi % LIZARD_COUNT
			card_sprite.wiggle_frames = [2 * lizard_index + 0, 2 * lizard_index + 1] as Array[int]
		CardType.FRUIT:
			Utils.assign_card_texture(card_sprite, _fruit_sheet)
			var fruit_index: int
			if FRUIT_DETAILS.has(card_details):
				fruit_index = FRUIT_DETAILS.find(card_details)
			else:
				# We never want random arrows in a level. If this is happening, something is wrong.
				_pending_warning = "Unrecognized fruit: %s" % [card_details]
				fruit_index = card_randi % FRUIT_COUNT
			card_sprite.wiggle_frames = [2 * fruit_index + 0, 2 * fruit_index + 1] as Array[int]
	
	if card_sprite.wiggle_frames:
		card_sprite.frame = card_sprite.wiggle_frames[0]


func _flip_card() -> void:
	if %CardFront.visible:
		# card is already flipped
		return
	
	if not game_state.flip_timer.is_stopped():
		# player is already flipping a card
		return
	
	if not game_state.can_interact:
		# the level hasn't started, or the level has ended
		return
	
	%PopBrustSfx.pitch_scale = randf_range(0.9, 1.10)
	%PopBrustSfx.play()
	before_card_flipped.emit()
	
	show_front()
	game_state.flip_timer.start()
	game_state.flip_timer.timeout.connect(_on_flip_timer_timeout)


func _on_flip_timer_timeout() -> void:
	game_state.flip_timer.timeout.disconnect(_on_flip_timer_timeout)
	match card_front_type:
		CardType.FROG:
			if practice:
				# this frog doesn't count; maybe it was on the main menu
				pass
			else:
				game_state.can_interact = false
			
			before_frog_found.emit()
			%CheerTimer.start()
			%FrogFoundTimer.start(2.0)
		CardType.SHARK:
			if practice:
				# this shark doesn't count; maybe it was on the main menu
				pass
			else:
				game_state.can_interact = false
			before_shark_found.emit()
			%SharkFoundTimer.start(3.2)
			%CreatureSfx.stream = Utils.rand_value(_shark_sounds)
			%CreatureSfx.pitch_scale = randf_range(0.8, 1.2)
			%CreatureSfx.play()


func _on_stop_dance_timer_timeout() -> void:
	if card_front_type != CardType.FROG:
		return
	
	var frog_index := int(%CardFront.wiggle_frames[0] / 4)
	%CardFront.wiggle_frames = [frog_index * 4 + 0, frog_index * 4 + 1] as Array[int]


func _on_frog_found_timer_timeout() -> void:
	frog_found.emit()


func _on_shark_found_timer_timeout() -> void:
	shark_found.emit()


func _on_cheer_timer_timeout() -> void:
	%CreatureSfx.stream = Utils.rand_value(_frog_sounds)
	%CreatureSfx.pitch_scale = randf_range(0.8, 1.2)
	%CreatureSfx.play()
	cheer()


## Returns a random value from the specified array, unless the code is running in the Godot editor.
##
## We don't randomize frames in the editor, it causes unnecessary churn in our .tscn files.
static func _mostly_rand_value(values: Array):
	return values[0] if Engine.is_editor_hint() else values[randi() % values.size()]

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

@export var card_back_type: CardType = CardType.MYSTERY : set = set_card_back_type
@export var card_back_details: String : set = set_card_back_details
@export var card_front_type: CardType = CardType.MYSTERY : set = set_card_front_type
@export var card_front_details: String : set = set_card_front_details

@export var game_state_path := NodePath("../GameState") : set = set_game_state_path
@export var practice := false

@export var shown_face := CardFace.BACK : set = set_shown_face

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

var _game_state: GameState
var _pending_warning := ""

@onready var _card_back_sprite := $CardBack
@onready var _card_front_sprite := $CardFront

@onready var _cheer_timer := $CheerTimer
@onready var _frog_found_timer := $FrogFoundTimer
@onready var _shark_found_timer := $SharkFoundTimer
@onready var _stop_dance_timer := $StopDanceTimer

@onready var _creature_sfx := $CreatureSfx
@onready var _pop_brust_sfx := $PopBrustSfx

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
	_refresh_game_state_path()
	_refresh_shown_face()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & MOUSE_BUTTON_LEFT:
		_flip_card()


func _process(_delta: float) -> void:
	if _pending_warning:
		push_warning(_pending_warning)
		_pending_warning = ""


func set_game_state_path(new_game_state_path: NodePath) -> void:
	game_state_path = new_game_state_path
	_refresh_game_state_path()


func set_shown_face(new_shown_face: CardFace) -> void:
	shown_face = new_shown_face
	_refresh_shown_face()


func set_card_back_type(new_card_back_type: CardType) -> void:
	card_back_type = new_card_back_type
	_refresh_card_textures()


func set_card_front_type(new_card_front_type: CardType) -> void:
	card_front_type = new_card_front_type
	_refresh_card_textures()


func set_card_back_details(new_card_back_details: String) -> void:
	card_back_details = new_card_back_details
	_refresh_card_textures()


func set_card_front_details(new_card_front_details: String) -> void:
	card_front_details = new_card_front_details
	_refresh_card_textures()


func reset() -> void:
	_card_back_sprite.visible = true
	_card_front_sprite.visible = false
	card_back_type = CardType.MYSTERY
	card_back_details = ""
	card_front_type = CardType.MYSTERY
	card_front_details = ""
	
	_stop_dance_timer.stop()
	_frog_found_timer.stop()
	_shark_found_timer.stop()
	_refresh_card_textures()


func is_front_shown() -> bool:
	return _card_front_sprite.visible


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
	
	_card_front_sprite.frame = other_card._card_front_sprite.frame
	_card_front_sprite.wiggle_frames = other_card._card_front_sprite.wiggle_frames
	_card_front_sprite.visible = other_card._card_front_sprite.visible
	
	_card_back_sprite.frame = other_card._card_back_sprite.frame
	_card_back_sprite.wiggle_frames = other_card._card_back_sprite.wiggle_frames
	_card_back_sprite.visible = other_card._card_back_sprite.visible


func cheer() -> void:
	if card_front_type != CardType.FROG:
		return
	
	var frog_index := int(_card_front_sprite.wiggle_frames[0] / 4)
	_card_front_sprite.wiggle_frames = [frog_index * 4 + 2, frog_index * 4 + 3] as Array[int]
	var wiggle_index: int = _card_front_sprite.frame % _card_front_sprite.wiggle_frames.size()
	_card_front_sprite.frame = _card_front_sprite.wiggle_frames[wiggle_index]
	
	# reset the wiggle so the characters don't have one very abbreviated dance frame
	_card_front_sprite.reset_wiggle()
	_stop_dance_timer.start(4.0)


func _refresh_shown_face() -> void:
	if not is_inside_tree():
		return
	
	if shown_face == CardFace.BACK and _card_back_sprite.visible \
			or shown_face == CardFace.FRONT and _card_front_sprite.visible:
		# appropriate card face is already shown
		return
	
	_card_back_sprite.visible = true if shown_face == CardFace.BACK else false
	_card_front_sprite.visible = true if shown_face == CardFace.FRONT else false
	
	if shown_face == CardFace.FRONT:
		# reset the wiggle so the characters don't have one very abbreviated dance frame
		_card_front_sprite.reset_wiggle()


func _refresh_game_state_path() -> void:
	if not is_inside_tree():
		return
	
	if game_state_path.is_empty():
		return
	
	_game_state = get_node(game_state_path)


func _refresh_card_textures() -> void:
	if not is_inside_tree():
		return
	
	_refresh_card_face(_card_back_sprite, card_back_type, card_back_details)
	_refresh_card_face(_card_front_sprite, card_front_type, card_front_details)


func _refresh_card_face(card_sprite: Sprite2D, card_type: int, card_details: String) -> void:
	_pending_warning = ""
	match card_type:
		CardType.FROG:
			Utils.assign_card_texture(card_sprite, _frog_sheet)
			var frog_index := randi() % FROG_COUNT
			card_sprite.wiggle_frames = [4 * frog_index + 0, 4 * frog_index + 1] as Array[int]
		CardType.SHARK:
			Utils.assign_card_texture(card_sprite, _shark_sheet)
			var shark_index := randi() % SHARK_COUNT
			card_sprite.wiggle_frames = [2 * shark_index + 0, 2 * shark_index + 1] as Array[int]
		CardType.MYSTERY:
			Utils.assign_card_texture(card_sprite, _mystery_sheet)
			var mystery_index: int
			if MYSTERY_INDEXES_BY_DETAILS.has(card_details):
				var mystery_indexes: Array = MYSTERY_INDEXES_BY_DETAILS[card_details]
				mystery_index = Utils.rand_value(mystery_indexes)
			else:
				mystery_index = randi() % MYSTERY_COUNT
			card_sprite.wiggle_frames = [2 * mystery_index + 0, 2 * mystery_index + 1] as Array[int]
		CardType.LETTER:
			Utils.assign_card_texture(card_sprite, _letter_sheet)
			var letter_index: int
			if LETTER_INDEXES_BY_DETAILS.has(card_details):
				var letter_indexes: Array = LETTER_INDEXES_BY_DETAILS[card_details]
				letter_index = Utils.rand_value(letter_indexes)
			else:
				# We never want random letters in a level. If this is happening, something is wrong.
				_pending_warning = "Unrecognized letter: %s" % [card_details]
				letter_index = randi() % LETTER_COUNT
			card_sprite.wiggle_frames = [2 * letter_index + 0, 2 * letter_index + 1] as Array[int]
		CardType.ARROW:
			Utils.assign_card_texture(card_sprite, _arrow_sheet)
			var arrow_index: int
			if ARROW_INDEXES_BY_DETAILS.has(card_details):
				var arrow_indexes: Array = ARROW_INDEXES_BY_DETAILS[card_details]
				arrow_index = Utils.rand_value(arrow_indexes)
			else:
				# We never want random arrows in a level. If this is happening, something is wrong.
				_pending_warning = "Unrecognized arrow: %s" % [card_details]
				arrow_index = randi() % ARROW_COUNT
			card_sprite.wiggle_frames = [2 * arrow_index + 0, 2 * arrow_index + 1] as Array[int]
		CardType.HEX_ARROW:
			Utils.assign_card_texture(card_sprite, _hex_arrow_sheet)
			var arrow_index: int
			if HEX_ARROW_INDEXES_BY_DETAILS.has(card_details):
				var arrow_indexes: Array = HEX_ARROW_INDEXES_BY_DETAILS[card_details]
				arrow_index = Utils.rand_value(arrow_indexes)
			else:
				# We never want random arrows in a level. If this is happening, something is wrong.
				_pending_warning = "Unrecognized hex arrow: %s" % [card_details]
				arrow_index = randi() % HEX_ARROW_COUNT
			card_sprite.wiggle_frames = [2 * arrow_index + 0, 2 * arrow_index + 1] as Array[int]
		CardType.FISH:
			Utils.assign_card_texture(card_sprite, _fish_sheet)
			var fish_index := randi() % FISH_COUNT
			card_sprite.wiggle_frames = [2 * fish_index + 0, 2 * fish_index + 1] as Array[int]
		CardType.LIZARD:
			Utils.assign_card_texture(card_sprite, _lizard_sheet)
			var lizard_index := randi() % LIZARD_COUNT
			card_sprite.wiggle_frames = [2 * lizard_index + 0, 2 * lizard_index + 1] as Array[int]
		CardType.FRUIT:
			Utils.assign_card_texture(card_sprite, _fruit_sheet)
			var fruit_index: int
			if FRUIT_DETAILS.has(card_details):
				fruit_index = FRUIT_DETAILS.find(card_details)
			else:
				# We never want random arrows in a level. If this is happening, something is wrong.
				_pending_warning = "Unrecognized fruit: %s" % [card_details]
				fruit_index = randi() % FRUIT_COUNT
			card_sprite.wiggle_frames = [2 * fruit_index + 0, 2 * fruit_index + 1] as Array[int]
	
	if card_sprite.wiggle_frames:
		card_sprite.frame = card_sprite.wiggle_frames[0]


func _flip_card() -> void:
	if _card_front_sprite.visible:
		# card is already flipped
		return
	
	if not _game_state.flip_timer.is_stopped():
		# player is already flipping a card
		return
	
	if not _game_state.can_interact:
		# the level hasn't started, or the level has ended
		return
	
	_pop_brust_sfx.pitch_scale = randf_range(0.9, 1.10)
	_pop_brust_sfx.play()
	emit_signal("before_card_flipped")
	
	show_front()
	_game_state.flip_timer.start()
	_game_state.flip_timer.connect("timeout", Callable(self, "_on_FlipTimer_timeout"))


func _on_FlipTimer_timeout() -> void:
	_game_state.flip_timer.disconnect("timeout", Callable(self, "_on_FlipTimer_timeout"))
	match card_front_type:
		CardType.FROG:
			if practice:
				# this frog doesn't count; maybe it was on the main menu
				pass
			else:
				_game_state.can_interact = false
			
			emit_signal("before_frog_found")
			_cheer_timer.start()
			_frog_found_timer.start(2.0)
		CardType.SHARK:
			if practice:
				# this shark doesn't count; maybe it was on the main menu
				pass
			else:
				_game_state.can_interact = false
			emit_signal("before_shark_found")
			_shark_found_timer.start(3.2)
			_creature_sfx.stream = Utils.rand_value(_shark_sounds)
			_creature_sfx.pitch_scale = randf_range(0.8, 1.2)
			_creature_sfx.play()


func _on_StopDanceTimer_timeout() -> void:
	if card_front_type != CardType.FROG:
		return
	
	var frog_index := int(_card_front_sprite.wiggle_frames[0] / 4)
	_card_front_sprite.wiggle_frames = [frog_index * 4 + 0, frog_index * 4 + 1] as Array[int]


func _on_FrogFoundTimer_timeout() -> void:
	emit_signal("frog_found")


func _on_SharkFoundTimer_timeout() -> void:
	emit_signal("shark_found")


func _on_CheerTimer_timeout() -> void:
	_creature_sfx.stream = Utils.rand_value(_frog_sounds)
	_creature_sfx.pitch_scale = randf_range(0.8, 1.2)
	_creature_sfx.play()
	cheer()

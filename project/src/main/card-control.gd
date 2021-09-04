class_name CardControl
extends Control

enum CardFace {
	NONE,
	FROG,
	SHARK,
	MYSTERY,
	LETTER,
}

const FROG_COUNT := 2
const SHARK_COUNT := 4
const MYSTERY_COUNT := 4
const LETTER_COUNT := 14

signal frog_found
signal shark_found

export (CardFace) var card_back_type: int = CardFace.MYSTERY setget set_card_back_type
export (String) var card_back_details: String
export (CardFace) var card_front_type: int = CardFace.MYSTERY setget set_card_front_type
export (String) var card_front_details: String

export (NodePath) var game_state_path := NodePath("../GameState")
export (bool) var practice := false

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

onready var _card_back_sprite := $CardBack
onready var _card_front_sprite := $CardFront

onready var _frog_sheet := load("res://assets/main/frog-frame-00-sheet.png")
onready var _letter_sheet := load("res://assets/main/letter-sheet.png")
onready var _shark_sheet := load("res://assets/main/shark-frame-00-sheet.png")
onready var _mystery_sheet := load("res://assets/main/mystery-sheet.png")
onready var _game_state := get_node(game_state_path)

func _ready() -> void:
	_refresh_card_textures()


func _refresh_card_textures() -> void:
	if not is_inside_tree():
		return
	
	_refresh_card_face(_card_back_sprite, card_back_type, card_back_details)
	_refresh_card_face(_card_front_sprite, card_front_type, card_front_details)


func _refresh_card_face(card_sprite: Sprite, card_type: int, card_details: String) -> void:
	match card_type:
		CardFace.FROG:
			card_sprite.texture = _frog_sheet
			card_sprite.vframes = 1
			var frog_index := randi() % FROG_COUNT
			card_sprite.wiggle_frames = [4 * frog_index + 0, 4 * frog_index + 1]
		CardFace.SHARK:
			card_sprite.texture = _shark_sheet
			card_sprite.vframes = 1
			var shark_index := randi() % SHARK_COUNT
			card_sprite.wiggle_frames = [2 * shark_index + 0, 2 * shark_index + 1]
		CardFace.MYSTERY:
			card_sprite.texture = _mystery_sheet
			card_sprite.vframes = 1
			var mystery_index := randi() % MYSTERY_COUNT
			card_sprite.wiggle_frames = [2 * mystery_index + 0, 2 * mystery_index + 1]
		CardFace.LETTER:
			card_sprite.texture = _letter_sheet
			card_sprite.vframes = 4
			var letter_index: int
			if LETTER_INDEXES_BY_DETAILS.has(card_details):
				var letter_indexes: Array = LETTER_INDEXES_BY_DETAILS[card_details]
				letter_index = letter_indexes[randi() % letter_indexes.size()]
			else:
				letter_index = randi() % LETTER_COUNT
			card_sprite.wiggle_frames = [2 * letter_index + 0, 2 * letter_index + 1]
	
	if card_sprite.wiggle_frames:
		card_sprite.frame = card_sprite.wiggle_frames[0]


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & BUTTON_LEFT:
		_flip_card()


func set_card_back_type(new_card_back_type: int) -> void:
	card_back_type = new_card_back_type
	_refresh_card_textures()


func set_card_front_type(new_card_front_type: int) -> void:
	card_front_type = new_card_front_type
	_refresh_card_textures()


func reset() -> void:
	_card_back_sprite.visible = true
	_card_front_sprite.visible = false
	$StopDanceTimer.stop()
	$FrogFoundTimer.stop()
	$SharkFoundTimer.stop()
	_refresh_card_textures()


func show_front() -> void:
	_card_back_sprite.visible = false
	_card_front_sprite.visible = true


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
	
	show_front()
	
	_game_state.flip_timer.start()
	_game_state.flip_timer.connect("timeout", self, "_on_FlipTimer_timeout")


func _on_FlipTimer_timeout() -> void:
	_game_state.flip_timer.disconnect("timeout", self, "_on_FlipTimer_timeout")
	match card_front_type:
		CardFace.FROG:
			var frog_index := int(_card_front_sprite.wiggle_frames[0] / 4)
			_card_front_sprite.wiggle_frames = [frog_index * 4 + 2, frog_index * 4 + 3]
			if practice:
				# this frog doesn't count; maybe it was on the main menu
				pass
			else:
				_game_state.can_interact = false
			
			$FrogFoundTimer.start(2.0)
			$StopDanceTimer.start(4.0)
		CardFace.SHARK:
			if practice:
				# this shark doesn't count; maybe it was on the main menu
				pass
			else:
				_game_state.can_interact = false
			$SharkFoundTimer.start(2.0)
			


func _on_StopDanceTimer_timeout() -> void:
	if card_front_type != CardFace.FROG:
		return
	
	var frog_index := int(_card_front_sprite.wiggle_frames[0] / 4)
	_card_front_sprite.wiggle_frames = [frog_index * 4 + 0, frog_index * 4 + 1]


func _on_FrogFoundTimer_timeout() -> void:
	emit_signal("frog_found")


func _on_SharkFoundTimer_timeout() -> void:
	emit_signal("shark_found")

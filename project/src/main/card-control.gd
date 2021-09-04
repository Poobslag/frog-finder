class_name CardControl
extends Control

enum CardType {
	NONE,
	FROG,
	SHARK,
	MYSTERY,
	LETTER,
}

const FROG_COUNT := 8
const SHARK_COUNT := 4
const MYSTERY_COUNT := 4
const LETTER_COUNT := 14

signal before_frog_found
signal frog_found
signal before_shark_found
signal shark_found

export (CardType) var card_back_type: int = CardType.MYSTERY setget set_card_back_type
export (String) var card_back_details: String setget set_card_back_details
export (CardType) var card_front_type: int = CardType.MYSTERY setget set_card_front_type
export (String) var card_front_details: String setget set_card_front_details

export (NodePath) var game_state_path := NodePath("../GameState") setget set_game_state_path
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
onready var _game_state: GameState

func _ready() -> void:
	_refresh_card_textures()
	_refresh_game_state_path()


func set_game_state_path(new_game_state_path: NodePath) -> void:
	game_state_path = new_game_state_path
	_refresh_game_state_path()


func _refresh_game_state_path() -> void:
	if not is_inside_tree():
		return
	
	if not game_state_path:
		return
	
	_game_state = get_node(game_state_path)


func _refresh_card_textures() -> void:
	if not is_inside_tree():
		return
	
	_refresh_card_face(_card_back_sprite, card_back_type, card_back_details)
	_refresh_card_face(_card_front_sprite, card_front_type, card_front_details)


func _refresh_card_face(card_sprite: Sprite, card_type: int, card_details: String) -> void:
	match card_type:
		CardType.FROG:
			card_sprite.texture = _frog_sheet
			card_sprite.vframes = 4
			var frog_index := randi() % FROG_COUNT
			card_sprite.wiggle_frames = [4 * frog_index + 0, 4 * frog_index + 1]
		CardType.SHARK:
			card_sprite.texture = _shark_sheet
			card_sprite.vframes = 1
			var shark_index := randi() % SHARK_COUNT
			card_sprite.wiggle_frames = [2 * shark_index + 0, 2 * shark_index + 1]
		CardType.MYSTERY:
			card_sprite.texture = _mystery_sheet
			card_sprite.vframes = 1
			var mystery_index := randi() % MYSTERY_COUNT
			card_sprite.wiggle_frames = [2 * mystery_index + 0, 2 * mystery_index + 1]
		CardType.LETTER:
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


func set_card_back_details(new_card_back_details: String) -> void:
	card_back_details = new_card_back_details
	_refresh_card_textures()


func set_card_front_details(new_card_front_details: String) -> void:
	card_front_details = new_card_front_details
	_refresh_card_textures()


func reset() -> void:
	_card_back_sprite.visible = true
	_card_front_sprite.visible = false
	$StopDanceTimer.stop()
	$FrogFoundTimer.stop()
	$SharkFoundTimer.stop()
	_refresh_card_textures()


func is_front_shown() -> bool:
	return _card_front_sprite.visible


func show_front() -> void:
	if $CardFront.visible:
		# already shown
		return
	
	# can't reference _card_back and _card_front fields. show_front() sometimes precedes _ready()
	$CardBack.visible = false
	$CardFront.visible = true
	
	# reset the wiggle so the characters don't have one very abbreviated dance frame
	$CardFront.reset_wiggle()


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


func cheer() -> void:
	if card_front_type != CardType.FROG:
		return
	
	var frog_index := int(_card_front_sprite.wiggle_frames[0] / 4)
	_card_front_sprite.wiggle_frames = [frog_index * 4 + 2, frog_index * 4 + 3]
	var wiggle_index: int = _card_front_sprite.frame % _card_front_sprite.wiggle_frames.size()
	_card_front_sprite.frame = _card_front_sprite.wiggle_frames[wiggle_index]
	
	# reset the wiggle so the characters don't have one very abbreviated dance frame
	_card_front_sprite.reset_wiggle()
	$StopDanceTimer.start(4.0)


func _on_FlipTimer_timeout() -> void:
	_game_state.flip_timer.disconnect("timeout", self, "_on_FlipTimer_timeout")
	match card_front_type:
		CardType.FROG:
			if practice:
				# this frog doesn't count; maybe it was on the main menu
				pass
			else:
				_game_state.can_interact = false
			
			emit_signal("before_frog_found")
			$CheerTimer.start()
			$FrogFoundTimer.start(2.0)
		CardType.SHARK:
			if practice:
				# this shark doesn't count; maybe it was on the main menu
				pass
			else:
				_game_state.can_interact = false
			emit_signal("before_shark_found")
			$SharkFoundTimer.start(2.0)


func _on_StopDanceTimer_timeout() -> void:
	if card_front_type != CardType.FROG:
		return
	
	var frog_index := int(_card_front_sprite.wiggle_frames[0] / 4)
	_card_front_sprite.wiggle_frames = [frog_index * 4 + 0, frog_index * 4 + 1]


func _on_FrogFoundTimer_timeout() -> void:
	emit_signal("frog_found")


func _on_SharkFoundTimer_timeout() -> void:
	emit_signal("shark_found")


func _on_CheerTimer_timeout() -> void:
	cheer()

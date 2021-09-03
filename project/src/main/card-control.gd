extends Control

enum CardFace {
	NONE,
	FROG,
	SHARK,
	MYSTERY,
}

const FROG_COUNT := 2
const SHARK_COUNT := 4
const MYSTERY_COUNT := 4

signal frog_found
signal shark_found

export (CardFace) var card_back_type: int = CardFace.NONE setget set_card_back_type
export (CardFace) var card_front_type: int = CardFace.NONE setget set_card_front_type
export (NodePath) var game_state_path := NodePath("../GameState")

onready var _card_back_sprite := $CardBack
onready var _card_front_sprite := $CardFront

onready var _frog_sheet := load("res://assets/main/frog-frame-00-sheet.png")
onready var _shark_sheet := load("res://assets/main/shark-frame-00-sheet.png")
onready var _mystery_sheet := load("res://assets/main/mystery-sheet.png")
onready var _game_state := get_node(game_state_path)

func _ready() -> void:
	_refresh_card_textures()


func _refresh_card_textures() -> void:
	if not is_inside_tree():
		return
	
	_refresh_card_face(card_back_type, _card_back_sprite)
	_refresh_card_face(card_front_type, _card_front_sprite)


func _refresh_card_face(card_type: int, card_sprite: Sprite) -> void:
	match card_type:
		CardFace.FROG:
			card_sprite.texture = _frog_sheet
			var frog_index := randi() % FROG_COUNT
			card_sprite.wiggle_frames = [4 * frog_index + 0, 4 * frog_index + 1]
		CardFace.SHARK:
			card_sprite.texture = _shark_sheet
			var shark_index := randi() % SHARK_COUNT
			card_sprite.wiggle_frames = [2 * shark_index + 0, 2 * shark_index + 1]
		CardFace.MYSTERY:
			card_sprite.texture = _mystery_sheet
			var mystery_index := randi() % MYSTERY_COUNT
			card_sprite.wiggle_frames = [2 * mystery_index + 0, 2 * mystery_index + 1]


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
	_refresh_card_textures()


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
	
	_card_back_sprite.visible = false
	_card_front_sprite.visible = true
	
	_game_state.flip_timer.start()
	_game_state.flip_timer.connect("timeout", self, "_on_FlipTimer_timeout")


func _on_FlipTimer_timeout() -> void:
	_game_state.flip_timer.disconnect("timeout", self, "_on_FlipTimer_timeout")
	match card_front_type:
		CardFace.FROG:
			var new_wiggle_frames := []
			for frame_index in range(_card_front_sprite.wiggle_frames.size()):
				new_wiggle_frames.append(_card_front_sprite.wiggle_frames[frame_index] + 2)
			_card_front_sprite.wiggle_frames = new_wiggle_frames
			_game_state.can_interact = false
			yield(get_tree().create_timer(2.0), "timeout")
			emit_signal("frog_found")
		CardFace.SHARK:
			_game_state.can_interact = false
			yield(get_tree().create_timer(2.0), "timeout")
			emit_signal("shark_found")

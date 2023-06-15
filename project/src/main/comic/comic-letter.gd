@tool
class_name ComicLetter
extends Sprite2D
## A sprite which shows a letter in a comic's title.
##
## The first panel of each comic includes the world's name, like 'Sunshine Shoals'. The letters are drawn and animated
## using sprites.

const EMPTY_FRAME_INDEXES := [14, 15]

## key: (String) letter
## value: (Array, int) animation frames showing that letter
const FRAME_INDEXES_BY_LETTER := {
	"a": [0],
	"d": [1],
	"e": [2],
	"f": [3, 4],
	"g": [5],
	"h": [6],
	"i": [7],
	"k": [8],
	"n": [9],
	"o": [10],
	"r": [11, 12],
	"s": [13],
	"": [14, 15],
}

## The string text displayed by this comic letter. This should be 0-1 characters like 'o' or ''.
@export var text := "" : set = set_text

@onready var _animation_player := $AnimationPlayer

## Animates the letter bobbing up and down.
var _bob_tween: Tween

func _ready() -> void:
	_refresh_text()

## Gradually shows the letter.
##
## The letter gradually becomes opaque, twisting and animating into view.
func show_letter() -> void:
	offset = Vector2(0, -6)
	_launch_bob_tween()
	
	_animation_player.stop()
	_animation_player.play("show")
	await get_tree().process_frame
	show()


## Immediately hides the letter.
##
## Titles are never hidden during comics, so this is only used when resetting the letter's state or during demos.
func hide_letter() -> void:
	_animation_player.stop()
	hide()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh_text()


## Updates our sprite frame to match our text.
func _refresh_text() -> void:
	if not is_inside_tree():
		return
	
	var frame_indexes: Array = FRAME_INDEXES_BY_LETTER.get(text, EMPTY_FRAME_INDEXES)
	frame = Utils.rand_value(frame_indexes)


## Launches the tween which makes the sprite slowly bob up and down.
func _launch_bob_tween() -> void:
	_bob_tween = Utils.recreate_tween(self, _bob_tween)
	_bob_tween.tween_property(self, "offset", Vector2(0, -6), 2.2).set_trans(Tween.TRANS_SINE)
	_bob_tween.tween_property(self, "offset", Vector2(0, 6), 2.2).set_trans(Tween.TRANS_SINE)
	_bob_tween.set_loops()

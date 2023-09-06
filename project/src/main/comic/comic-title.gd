@tool
extends Control
## Shows the title of a comic.
##
## The first panel of each comic includes the world's name, like 'Sunshine Shoals'. The letters are drawn and animated
## using sprites.

## Time in seconds between each of the title's letters appearing.
const PER_LETTER_DELAY := 0.07

@export var text: String : set = set_text
@export var ComicLetterScene: PackedScene

## An editor toggle which launches the title animation.
##
## Workaround for Godot #75479 (https://github.com/godotengine/godot/issues/75479). The AnimationPlayer animates the
## title with a call method track, but call method tracks are not called in the Godot editor. This property provides an
## alternate way of previewing the title animation.
@warning_ignore("unused_private_class_variable")
@export var _animate_title: bool : set = animate_title

## Container node containing the back row of letters.
@onready var _back_letters := $BackLetters

## Container node containing the front row of letters.
@onready var _front_letters := $FrontLetters

## Gradually makes the title's letters visible.
var _letter_tween: Tween

## Number of letter nodes already stored in BackLetters and FrontLetters.
var _prev_letter_count := 0

## The letter node which was most recently stored in BackLetters and FrontLetters.
var _prev_letter_node: ComicLetter

func _ready() -> void:
	_refresh_text()


## An editor toggle which launches the title animation.
func animate_title(value: bool) -> void:
	if not value:
		# only animate the title in the editor when the '_animate_title' property is toggled
		return
	
	hide_title()
	show_title()


## Immediately hides the letters in the title.
##
## Titles are never hidden during comics, so this is only used when resetting the letter's state or during demos.
func hide_title() -> void:
	_letter_tween = Utils.kill_tween(_letter_tween)
	var _letter_nodes := _ordered_letter_nodes()
	for letter_node in _letter_nodes:
		letter_node.hide_letter()


## Gradually reveals the letters in the title with a 'swoosh' effect.
func show_title() -> void:
	_letter_tween = Utils.recreate_tween(self, _letter_tween)
	_letter_tween.set_parallel()
	var _letter_nodes := _ordered_letter_nodes()
	for letter_index in range(_letter_nodes.size()):
		var letter_node := _letter_nodes[letter_index]
		_letter_tween.tween_callback(letter_node.show_letter).set_delay(letter_index * PER_LETTER_DELAY)


func set_text(new_text: String) -> void:
	if text == new_text:
		return
	
	text = new_text
	_refresh_text()


## Returns a list of letter nodes in BackLetters and FrontLetters ordered from left-to-right.
func _ordered_letter_nodes() -> Array[Node]:
	var result: Array[Node] = []
	result.append_array(_back_letters.get_children())
	for i in range(_front_letters.get_child_count()):
		result.insert(i * 2 + 1, _front_letters.get_child(i))
	return result


## Updates our letter nodes to match our text string.
func _refresh_text() -> void:
	if not is_inside_tree():
		return
	
	for child in _back_letters.get_children():
		child.queue_free()
		_back_letters.remove_child(child)
	for child in _front_letters.get_children():
		child.queue_free()
		_front_letters.remove_child(child)
	_prev_letter_node = null
	_prev_letter_count = 0
	
	var adjacent := true
	for letter_string in text:
		match letter_string:
			" ":
				adjacent = false
			_:
				_append_letter(letter_string, adjacent)
				adjacent = true


## Creates and stores a new letter node in BackLetters or FrontLetters.
##
## Parameters:
## 	'letter_string': A single-character string for the letter to add.
##
## 	'adjacent': If 'true', the letter will be adjacent to the previous letter. If 'false', there will be a gap.
func _append_letter(letter_string: String, adjacent := true) -> void:
	var new_letter_node: ComicLetter = ComicLetterScene.instantiate()
	
	# determine whether the letter goes in the front/back row
	var letter_parent: Control
	if adjacent and _prev_letter_node and _prev_letter_node.get_parent() == _back_letters:
		letter_parent = _front_letters
	else:
		letter_parent = _back_letters
	
	new_letter_node.text = letter_string
	
	# update the letter's position; it goes adjacent to the previous letter unless there's a space
	if not _prev_letter_node:
		new_letter_node.position.x = 45
	elif not adjacent:
		new_letter_node.position.x = _prev_letter_node.position.x + 200
	else:
		new_letter_node.position.x = _prev_letter_node.position.x + 60
	new_letter_node.position.y = 45
	
	new_letter_node.name = "ComicLetter%s" % [_prev_letter_count + 1]
	letter_parent.add_child(new_letter_node)
	new_letter_node.set_owner(get_tree().edited_scene_root)
	
	_prev_letter_node = new_letter_node
	_prev_letter_count += 1

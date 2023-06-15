extends Node

const LETTERS_BY_SCANCODE := {
	KEY_A:"a", KEY_B:"b", KEY_C:"c", KEY_D:"d", KEY_E:"e", KEY_F:"f", KEY_G:"g", KEY_H:"h", KEY_I:"i",
	KEY_J:"j", KEY_K:"k", KEY_L:"l", KEY_M:"m", KEY_N:"n", KEY_O:"o", KEY_P:"p", KEY_Q:"q", KEY_R:"r",
	KEY_S:"s", KEY_T:"t", KEY_U:"u", KEY_V:"v", KEY_W:"w", KEY_X:"x", KEY_Y:"y", KEY_Z:"z",
}

@onready var _current_letter := $Letter1

func _ready() -> void:
	for letter in [$Letter1, $Letter2]:
		letter.hide_letter()
		letter.text = Utils.rand_value(["f", "r", "o", "g"])
		letter.show_letter()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1:
			_current_letter = $Letter1
		KEY_2:
			_current_letter = $Letter2
		KEY_SPACE:
			if _current_letter.visible:
				_current_letter.hide_letter()
			else:
				_current_letter.show_letter()
		_:
			if Utils.key_scancode(event) in LETTERS_BY_SCANCODE:
				var letter: String = LETTERS_BY_SCANCODE[Utils.key_scancode(event)]
				_current_letter.text = letter

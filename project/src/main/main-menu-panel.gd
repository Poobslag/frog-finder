extends Panel

signal start_button_pressed

onready var _game_state := $GameState

func _on_StartButton_pressed() -> void:
	emit_signal("start_button_pressed")


func _ready() -> void:
	$Card1F.show_front()
	$Card1R.show_front()
	$Card1G.show_front()
	$Card2F.show_front()
	$Card2N.show_front()
	$Card2D.show_front()
	$Card2E.show_front()
	$Card2R.show_front()


func show_menu() -> void:
	visible = true
	_game_state.reset()
	$Card1O.reset()
	$Card2I.reset()
	
	$Card1O.card_front_type = CardControl.CardFace.SHARK if randf() < 0.15 else CardControl.CardFace.FROG
	$Card2I.card_front_type = CardControl.CardFace.SHARK if randf() < 0.15 else CardControl.CardFace.FROG

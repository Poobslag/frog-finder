extends Node
## Demonstrates the Intermission Panel.
##
## Keys:
## 	[1..0] -> [D]: Launches a random dance sequence with 1-10 frogs.
## 	[F]: Show a frog card.
## 	[1..3] -> [H]: Spawn some frogs, 1-3 of which will hug your hand.
## 	[M]: Play some music.
## 	[R]: Spawn a frog which will award a ribbon.
## 	[S]: Spawn a shark.
## 	[T]: Toggle the intermission tweak
## 	[1..0] -> [W]: Sets the world index.
## 	[escape]: Restore the player's hand, so it has all fingers and no ribbon.

@onready var _intermission_panel := $IntermissionPanel
@onready var _hand := $Hand

## The most recently pressed number key.
var number_event: InputEvent

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	PlayerData.music_preference = PlayerData.MusicPreference.OFF
	
	_intermission_panel.show_intermission_panel()
	_intermission_panel.restart("1-1")


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_D:
			_start_frog_dance()
		KEY_F:
			var card: CardControl = $IntermissionPanel/IntermissionCards.create_card()
			card.card_front_type = CardControl.CardType.FROG
			
			# must add as a child so its sprites/frames will be initialized
			add_child(card)
			card.queue_free()
			
			card.show_front()
			_intermission_panel.add_level_result(card)
		KEY_H:
			_start_frog_hug_timer()
		KEY_M:
			if PlayerData.music_preference == PlayerData.MusicPreference.OFF:
				PlayerData.music_preference = PlayerData.MusicPreference.RANDOM
			MusicPlayer.play_preferred_song()
		KEY_R:
			_start_frog_ribbon()
		KEY_S:
			_intermission_panel.start_shark_spawn_timer(3)
		KEY_T:
			if _intermission_panel.has_tweak():
				_intermission_panel.remove_tweak()
			else:
				_intermission_panel.add_tweak()
		KEY_W:
			_assign_world_index()
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			number_event = event
		KEY_ESCAPE:
			_hand.reset_fingers()
			_hand.ribbon = false


func _start_frog_hug_timer() -> void:
	var frog_count: int
	var huggable_fingers: int
	match Utils.key_scancode(number_event):
		KEY_1:
			frog_count = 1
			huggable_fingers = 5
		KEY_2:
			frog_count = 2
			huggable_fingers = 12
		KEY_3, _:
			frog_count = 3
			huggable_fingers = 30
	_intermission_panel.start_frog_hug_timer(frog_count, huggable_fingers)


func _start_frog_dance() -> void:
	_intermission_panel.reset()
	
	var frog_count: int
	match Utils.key_scancode(number_event):
		KEY_0:
			frog_count = 10
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			frog_count = Utils.key_num(number_event)
		_:
			frog_count = randi_range(1, 10)
	
	_intermission_panel.start_frog_dance(frog_count)


func _start_frog_ribbon() -> void:
	_intermission_panel.reset()
	
	_intermission_panel.start_frog_ribbon()


func _assign_world_index() -> void:
	PlayerData.world_index = Utils.key_num(number_event)

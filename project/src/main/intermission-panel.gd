class_name IntermissionPanel
extends Panel
## Panel which shows intermissions.
##
## These intermissions show the frogs/sharks the player's found and sometimes feature animated sequences with frogs and
## sharks.

signal bye_pressed

const SHARK_SPAWN_WAIT_TIME := 8.0
const CREATURE_SPAWN_BORDER := 80.0

## Delay (in seconds) between when each shark appears. The first item in the array corresponds to the number of seconds
## until the second shark appears.
const SHARK_DELAYS := [10.0, 2.0, 6.0, 2.0, 10.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0]

## Delay (in seconds) between when each frog appears. The first item in the array corresponds to the number of seconds
## until the second frog appears.
const FROG_DELAYS := [
	3.0, 3.0, 3.0, 3.0, 3.0, 2.0, 2.0, 2.0, 2.0, 2.0,
	1.5, 1.5, 1.5, 1.5, 1.5, 1.0, 1.0, 1.0, 1.0, 1.0,
	1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
]

var cards: Array[CardControl] = []
var sharks: Array[RunningShark] = []
var frogs: Array[RunningFrog] = []

## Stores relationships between 'frogs' and 'friends'. Friends affects a frog's pathfinding. As long as a frog's friend
## is chasing the hand, the frog will chase their friend instead. This prevents frogs from clustering too tightly.
##
## key: (RunningFrog) frog
## value: (RunningFrog) friend
var friends_by_frog := {}

var max_frogs := 0
var next_card_index := 0

var RunningSharkScene := preload("res://src/main/RunningShark.tscn")
var RunningFrogScene := preload("res://src/main/RunningFrog.tscn")

@export var hand: Hand

@onready var obstacles: Control = %Obstacles

@onready var _intermission_cards: LevelCards = %IntermissionCards

func _ready() -> void:
	hand.hug_finished.connect(_on_hand_hug_finished)


func is_full() -> bool:
	return next_card_index >= _intermission_cards.get_cards().size()


func restart(mission_string: String) -> void:
	next_card_index = 0
	cards.clear()
	_intermission_cards.reset()
	var card_positions: Array[Vector2] = CardArrangements.get_card_positions(mission_string)
	for i in range(card_positions.size()):
		var card := _intermission_cards.create_card()
		_intermission_cards.add_card(card, card_positions[i])
		cards.append(card)


func reset() -> void:
	%SharkSpawnTimer.stop()
	%FrogSpawnTimer.stop()
	%ByeButton.visible = false
	for child in obstacles.get_children():
		child.queue_free()
		obstacles.remove_child(child)
	sharks.clear()
	frogs.clear()
	
	if has_tweak():
		remove_tweak()
	if visible:
		add_tweak()


func add_level_result(found_card: CardControl) -> void:
	if is_full():
		return
	
	var next_card: CardControl = cards[next_card_index]
	next_card.copy_from(found_card)
	next_card.cheer()
	next_card_index += 1


func show_intermission_panel() -> void:
	visible = true
	reset()


func start_shark_spawn_timer(biteable_fingers: int = 1) -> void:
	hand.biteable_fingers = biteable_fingers
	%SharkSpawnTimer.start()
	for _finger in range(biteable_fingers):
		# spawn one shark per finger
		_spawn_shark(true)


func start_frog_hug_timer(huggable_fingers: int, new_max_frogs: int) -> void:
	max_frogs = new_max_frogs
	hand.huggable_fingers = huggable_fingers
	%FrogSpawnTimer.start()
	for _finger in range(huggable_fingers):
		# spawn one frog per finger
		var frog := _spawn_frog(true)
		_chase(frog)


func start_frog_dance(frog_count: int) -> void:
	var dance_frogs: Array[RunningFrog] = []
	
	# spawn frogs
	for _i in range(frog_count):
		var new_frog := _spawn_frog()
		dance_frogs.append(new_frog)
	
	frogs[0].finished_dance.connect(_on_running_frog_finished_dance)
	
	var arrangement := FrogArrangements.get_arrangement(frog_count)
	
	# frog runs into position, dances and leaves
	for i in range(frogs.size()):
		var dance_target := Rect2(Vector2.ZERO, obstacles.size).get_center()
		dance_target += arrangement[i] * Vector2(64, 48)
		
		_dance(frogs[i], dance_frogs, dance_target)


func start_frog_ribbon() -> void:
	_spawn_frog()
	
	frogs[0].give_ribbon(hand)
	
	if hand.ribbon:
		%ByeButton.visible = true
	else:
		frogs[0].finished_give_ribbon.connect(_on_running_frog_finished_give_ribbon)


func has_tweak() -> bool:
	return has_node("Tweak")


func add_tweak() -> void:
	if has_tweak():
		return
	
	if PlayerData.get_world().intermission_tweak_scene:
		var tweak := PlayerData.get_world().intermission_tweak_scene.instantiate()
		tweak.name = "Tweak"
		add_child(tweak)


func remove_tweak() -> void:
	if not has_tweak():
		return
	
	var tweak: IntermissionTweak = get_node("Tweak")
	tweak.queue_free()
	remove_child(tweak)


## Spawns a shark outside the edge of the screen.
##
## Parameters:
## 	'away_from_hand': If 'true', the shark will be spawned on the furthest edge from the player's cursor.
func _spawn_shark(away_from_hand: bool = false) -> void:
	var shark: RunningShark = RunningSharkScene.instantiate()
	shark.hand = hand
	shark.soon_position = _random_spawn_point(away_from_hand)
	shark.update_position()
	
	if sharks.size() % 2 == 1:
		# this shark has a friend
		shark.friend = sharks[sharks.size() - 1]
	
	obstacles.add_child(shark)
	sharks.append(shark)
	shark.chase()


## Spawns a frog outside the edge of the screen.
##
## Parameters:
## 	'away_from_hand': If 'true', the frog will be spawned on the furthest edge from the player's cursor.
func _spawn_frog(away_from_hand: bool = false) -> RunningFrog:
	var frog: RunningFrog = RunningFrogScene.instantiate()
	frog.soon_position = _random_spawn_point(away_from_hand)
	frog.update_position()
	
	if frogs.size() % 2 == 1:
		# this frog has a friend
		friends_by_frog[frog] = frogs[frogs.size() - 1]
	
	obstacles.add_child(frog)
	frogs.append(frog)
	return frog


## Calculates a random spawn point around the perimeter of the screen.
##
## Parameters:
## 	'away_from_hand': If 'true', the spawn point is a random point on the edge furthest from the screen. If the
## 		player's hand is on the left side of the screen, the spawn point will be somewhere on the right and vice-versa.
func _random_spawn_point(away_from_hand: bool) -> Vector2:
	var viewport_rect_size := get_viewport_rect().size
	
	var spawn_points := [
		Vector2(randf_range(0, viewport_rect_size.x), -CREATURE_SPAWN_BORDER), # top wall
		Vector2(viewport_rect_size.x + CREATURE_SPAWN_BORDER, randf_range(0, viewport_rect_size.y)), # right wall
		Vector2(randf_range(0, viewport_rect_size.x), viewport_rect_size.y + CREATURE_SPAWN_BORDER), # bottom wall
		Vector2(-CREATURE_SPAWN_BORDER, randf_range(0, viewport_rect_size.y)), # left wall
	]
	
	if away_from_hand:
		spawn_points.sort_custom(func(a: Vector2, b: Vector2) -> bool:
			return hand.global_position.distance_to(a) > hand.global_position.distance_to(b))
	else:
		spawn_points.shuffle()
	
	return spawn_points[0] - obstacles.global_position


## Puts a frog into 'chase mode'.
func _chase(frog: RunningFrog) -> void:
	frog.chase(hand, friends_by_frog.get(frog, null))


## Puts a frog into 'dance mode'.
func _dance(frog: RunningFrog, dance_frogs: Array[RunningFrog], dance_target: Vector2) -> void:
	frog.dance(dance_frogs, dance_target)


func _on_shark_spawn_timer_timeout() -> void:
	if not visible:
		# After finishing the game, sometimes an invisible 'ghost frog' keeps chasing the cursor. It's rare, but my
		# guess is it has to do with a race condition where this timer is triggered when the scene is invisible. I'm
		# adding the same check here in case it happens with sharks too.
		return
	
	var shark_delay_index := sharks.size() - 1
	if shark_delay_index < SHARK_DELAYS.size() and hand.biteable_fingers >= 1:
		_spawn_shark(true)
		%SharkSpawnTimer.start(SHARK_DELAYS[shark_delay_index])


func _on_frog_spawn_timer_timeout() -> void:
	if not visible:
		# After finishing the game, sometimes an invisible 'ghost' frog keeps chasing the cursor.
		# It's rare, but my guess is it has to do with a race condition where this timer is triggered when the scene
		# is invisible.
		return
	
	var frog_delay_index := frogs.size() - 1
	if frog_delay_index < FROG_DELAYS.size() and frogs.size() < max_frogs:
		var frog := _spawn_frog(true)
		_chase(frog)
		%FrogSpawnTimer.start(FROG_DELAYS[frog_delay_index])


func _on_hand_hug_finished() -> void:
	%ByeButton.visible = true


func _on_running_frog_finished_dance() -> void:
	%ByeButton.visible = true


func _on_running_frog_finished_give_ribbon() -> void:
	%ByeButton.visible = true


func _on_bye_button_pressed() -> void:
	bye_pressed.emit()


func _on_visibility_changed() -> void:
	if not visible:
		# When the intermission panel is hidden, we remove the tweak. This prevents things like beach balls from
		# bouncing and making noise, or prevents the player from clicking invisible parts of the intermission tweak.
		remove_tweak()

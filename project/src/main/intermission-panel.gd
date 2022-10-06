class_name IntermissionPanel
extends Panel

signal bye_pressed

export (NodePath) var hand_path: NodePath

const SHARK_SPAWN_WAIT_TIME := 8.0
const SHARK_SPAWN_BORDER := 80.0
const SHARK_DELAYS := [10.0, 2.0, 6.0, 2.0, 10.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0]
const FROG_DELAYS := [
	3.0, 3.0, 3.0, 3.0, 3.0, 2.0, 2.0, 2.0, 2.0, 2.0,
	1.5, 1.5, 1.5, 1.5, 1.5, 1.0, 1.0, 1.0, 1.0, 1.0,
	1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
]

const DEFAULT_CARD_POSITIONS := [
	Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
	Vector2(0.5, 1), Vector2(1.5, 1),
	Vector2(1, 0),
]

var card_positions_by_mission_string := {
	"1-1":
		[
			Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
			Vector2(0.5, 1), Vector2(1.5, 1),
			Vector2(1, 0),
		],
	"1-2":
		[
			Vector2(1, 2), Vector2(2, 2), Vector2(3, 2),
			Vector2(3.5, 1), Vector2(2.5, 1), Vector2(1.5, 1), Vector2(0.5, 1),
			Vector2(0, 0), Vector2(4, 0), Vector2(2, 0),
		],
	"1-3":
		[
			Vector2(2.5, 2.0), Vector2(2.0, 3.0), Vector2(1.5, 2.0), Vector2(1.0, 3.0),
			Vector2(0.5, 2.0), Vector2(0.0, 1.0), Vector2(0.5, 0.0), Vector2(1.5, 0.0),
			Vector2(2.0, 1.0), Vector2(3.0, 1.0), Vector2(3.5, 0.0), Vector2(4.5, 0.0),
			Vector2(5.0, 1.0), Vector2(4.5, 2.0), Vector2(4.0, 3.0), Vector2(3.5, 2.0),
			Vector2(3.0, 3.0),
		],
	"2-1":
		[
			Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
			Vector2(0.5, 1), Vector2(1.5, 1),
			Vector2(1, 0),
		],
	"2-2":
		[
			Vector2(1, 2), Vector2(2, 2), Vector2(3, 2),
			Vector2(3.5, 1), Vector2(2.5, 1), Vector2(1.5, 1), Vector2(0.5, 1),
			Vector2(0, 0), Vector2(4, 0), Vector2(2, 0),
		],
	"2-3":
		[
			Vector2(2.5, 2.0), Vector2(2.0, 3.0), Vector2(1.5, 2.0), Vector2(1.0, 3.0),
			Vector2(0.5, 2.0), Vector2(0.0, 1.0), Vector2(0.5, 0.0), Vector2(1.5, 0.0),
			Vector2(2.0, 1.0), Vector2(3.0, 1.0), Vector2(3.5, 0.0), Vector2(4.5, 0.0),
			Vector2(5.0, 1.0), Vector2(4.5, 2.0), Vector2(4.0, 3.0), Vector2(3.5, 2.0),
			Vector2(3.0, 3.0),
		],
	"3-1":
		[
			Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
			Vector2(0.5, 1), Vector2(1.5, 1),
			Vector2(1, 0),
		],
	"3-2":
		[
			Vector2(1, 2), Vector2(2, 2), Vector2(3, 2),
			Vector2(3.5, 1), Vector2(2.5, 1), Vector2(1.5, 1), Vector2(0.5, 1),
			Vector2(0, 0), Vector2(4, 0), Vector2(2, 0),
		],
	"3-3":
		[
			Vector2(2.5, 2.0), Vector2(2.0, 3.0), Vector2(1.5, 2.0), Vector2(1.0, 3.0),
			Vector2(0.5, 2.0), Vector2(0.0, 1.0), Vector2(0.5, 0.0), Vector2(1.5, 0.0),
			Vector2(2.0, 1.0), Vector2(3.0, 1.0), Vector2(3.5, 0.0), Vector2(4.5, 0.0),
			Vector2(5.0, 1.0), Vector2(4.5, 2.0), Vector2(4.0, 3.0), Vector2(3.5, 2.0),
			Vector2(3.0, 3.0),
		],
}

var cards: Array = []
var sharks: Array = []
var frogs: Array = []
var max_frogs := 0
var next_card_index := 0

var RunningSharkScene := preload("res://src/main/RunningShark.tscn")
var RunningFrogScene := preload("res://src/main/RunningFrog.tscn")

onready var _intermission_cards: LevelCards = $IntermissionCards
onready var hand: Hand = get_node(hand_path)
onready var _bye_button := $ByeButton

func _ready() -> void:
	hand.connect("hug_finished", self, "_on_Hand_hug_finished")


func is_full() -> bool:
	return next_card_index >= _intermission_cards.get_cards().size()


func restart(mission_string: String) -> void:
	next_card_index = 0
	cards.clear()
	_intermission_cards.reset()
	var card_positions: Array = card_positions_by_mission_string.get(mission_string, DEFAULT_CARD_POSITIONS)
	for i in range(card_positions.size()):
		var card := _intermission_cards.create_card()
		_intermission_cards.add_card(card, card_positions[i])
		cards.append(card)


func reset() -> void:
	$SharkSpawnTimer.stop()
	$FrogSpawnTimer.stop()
	_bye_button.visible = false
	for child in $Creatures.get_children():
		child.queue_free()
		$Creatures.remove_child(child)
	sharks.clear()
	frogs.clear()


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


func _spawn_shark() -> void:
	var shark: RunningShark = RunningSharkScene.instance()
	shark.hand = hand
	
	var viewport_rect_size := get_viewport_rect().size
	
	var spawn_points := [
		Vector2(rand_range(0, viewport_rect_size.x), -SHARK_SPAWN_BORDER), # top wall
		Vector2(viewport_rect_size.x + SHARK_SPAWN_BORDER, rand_range(0, viewport_rect_size.y)), # right wall
		Vector2(rand_range(0, viewport_rect_size.x), viewport_rect_size.y + SHARK_SPAWN_BORDER), # bottom wall
		Vector2(-SHARK_SPAWN_BORDER, rand_range(0, viewport_rect_size.y)), # left wall
	]
	spawn_points.sort_custom(self, "_sort_by_distance_from_hand")
	
	if sharks.size() % 2 == 1:
		# this shark has a friend
		shark.friend = sharks[sharks.size() - 1]
	
	shark.soon_position = spawn_points[0]
	$Creatures.add_child(shark)
	sharks.append(shark)
	shark.chase()


func _spawn_frog() -> void:
	var frog: RunningFrog = RunningFrogScene.instance()
	frog.hand = hand
	
	var viewport_rect_size := get_viewport_rect().size
	
	var spawn_points := [
		Vector2(rand_range(0, viewport_rect_size.x), -SHARK_SPAWN_BORDER), # top wall
		Vector2(viewport_rect_size.x + SHARK_SPAWN_BORDER, rand_range(0, viewport_rect_size.y)), # right wall
		Vector2(rand_range(0, viewport_rect_size.x), viewport_rect_size.y + SHARK_SPAWN_BORDER), # bottom wall
		Vector2(-SHARK_SPAWN_BORDER, rand_range(0, viewport_rect_size.y)), # left wall
	]
	spawn_points.sort_custom(self, "_sort_by_distance_from_hand")
	
	if frogs.size() % 2 == 1:
		# this frog has a friend
		frog.friend = frogs[frogs.size() - 1]
	
	frog.soon_position = spawn_points[0]
	$Creatures.add_child(frog)
	frogs.append(frog)
	frog.chase()


func start_shark_spawn_timer(biteable_fingers: int = 1) -> void:
	hand.biteable_fingers = biteable_fingers
	$SharkSpawnTimer.start()
	for _finger in range(biteable_fingers):
		# spawn one shark per finger
		_spawn_shark()


func start_frog_hug_timer(huggable_fingers: int, new_max_frogs: int) -> void:
	max_frogs = new_max_frogs
	hand.huggable_fingers = huggable_fingers
	$FrogSpawnTimer.start()
	for _finger in range(huggable_fingers):
		# spawn one frog per finger
		_spawn_frog()


func _sort_by_distance_from_hand(a: Vector2, b: Vector2) -> bool:
	return hand.rect_global_position.distance_to(a) > hand.rect_global_position.distance_to(b)


func _on_SharkSpawnTimer_timeout() -> void:
	if not visible:
		# After finishing the game, sometimes an invisible 'ghost frog' keeps chasing the cursor. It's rare, but my
		# guess is it has to do with a race condition where this timer is triggered when the scene is invisible. I'm
		# adding the same check here in case it happens with sharks too.
		return
	
	var shark_delay_index := sharks.size() - 1
	if shark_delay_index < SHARK_DELAYS.size() and hand.biteable_fingers >= 1:
		_spawn_shark()
		$SharkSpawnTimer.start(SHARK_DELAYS[shark_delay_index])


func _on_FrogSpawnTimer_timeout() -> void:
	if not visible:
		# After finishing the game, sometimes an invisible 'ghost' frog keeps chasing the cursor.
		# It's rare, but my guess is it has to do with a race condition where this timer is triggered when the scene
		# is invisible.
		return
	
	var frog_delay_index := frogs.size() - 1
	if frog_delay_index < FROG_DELAYS.size() and frogs.size() < max_frogs:
		_spawn_frog()
		$FrogSpawnTimer.start(FROG_DELAYS[frog_delay_index])


func _on_Hand_hug_finished() -> void:
	_bye_button.visible = true


func _on_ByeButton_pressed() -> void:
	emit_signal("bye_pressed")

class_name IntermissionPanel
extends Panel

export (NodePath) var hand_path: NodePath

const SHARK_SPAWN_WAIT_TIME := 8.0
const SHARK_SPAWN_BORDER := 80.0
const SHARK_DELAYS := [10.0, 2.0, 6.0, 2.0, 10.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0]

var card_positions := [
	Vector2(0, 3), Vector2(1, 3), Vector2(2, 3), Vector2(3, 3),
	Vector2(2.5, 2), Vector2(1.5, 2), Vector2(0.5, 2),
	Vector2(1, 1), Vector2(2, 1),
	Vector2(1.5, 0),
]

var cards: Array = []
var sharks: Array = []
var next_card_index := 0

var RunningSharkScene := preload("res://src/main/RunningShark.tscn")

onready var _intermission_cards: LevelCards = $IntermissionCards
onready var hand: Hand = get_node(hand_path)

func _ready() -> void:
	for i in range(0, card_positions.size()):
		var card := _intermission_cards.create_card()
		_intermission_cards.add_card(card, card_positions[i])
		cards.append(card)


func is_full() -> bool:
	return next_card_index >= cards.size()


func restart() -> void:
	next_card_index = 0
	for card_obj in cards:
		var card: CardControl = card_obj
		card.reset()


func reset() -> void:
	for child in $Creatures.get_children():
		child.queue_free()
		$Creatures.remove_child(child)
	sharks.clear()


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
	
	var spawn_points := [
		Vector2(rand_range(0, OS.window_size.x), -SHARK_SPAWN_BORDER), # top wall
		Vector2(OS.window_size.x + SHARK_SPAWN_BORDER, rand_range(0, OS.window_size.y)), # right wall
		Vector2(rand_range(0, OS.window_size.x), OS.window_size.y + SHARK_SPAWN_BORDER), # bottom wall
		Vector2(-SHARK_SPAWN_BORDER, rand_range(0, OS.window_size.y)), # left wall
	]
	spawn_points.sort_custom(self, "_sort_by_distance_from_hand")
	
	if sharks.size() % 2 == 1:
		# this shark has a friend
		shark.friend = sharks[sharks.size() - 1]
	
	shark.soon_position = spawn_points[0]
	$Creatures.add_child(shark)
	sharks.append(shark)
	shark.chase()


func start_shark_spawn_timer(biteable_fingers: int = 1) -> void:
	hand.biteable_fingers = biteable_fingers
	$SharkSpawnTimer.start()
	for _finger in range(0, biteable_fingers):
		# spawn one shark per finger
		_spawn_shark()


func _sort_by_distance_from_hand(a: Vector2, b: Vector2) -> bool:
	return hand.rect_global_position.distance_to(a) > hand.rect_global_position.distance_to(b)


func _on_SharkSpawnTimer_timeout() -> void:
	var shark_delay_index := sharks.size() - 1
	if shark_delay_index < SHARK_DELAYS.size() and hand.biteable_fingers >= 1:
		_spawn_shark()
		$SharkSpawnTimer.start(SHARK_DELAYS[shark_delay_index])

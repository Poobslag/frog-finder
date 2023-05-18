class_name CardShadow
extends Sprite2D
## Drop shadow which appears behind a card to separate it from the background.

## The card which this shadow should follow
var card: Node

func _ready() -> void:
	_refresh()


func _process(_delta: float) -> void:
	_refresh()


## Reposition the shadow and toggle its visibility.
func _refresh() -> void:
	# If this shadow's card has been freed, we free the shadow as well.
	if not is_instance_valid(card):
		queue_free()
		return
	
	visible = card.is_visible_in_tree()
	if visible:
		if card is Control:
			position = card.global_position + card.size / 2.0 - get_parent().global_position
		elif card is Node2D:
			position = card.global_position - get_parent().global_position

extends Node
## Demonstrates the interactions between bees and flowers.
##
## Keys:
## 	[Q,W]: Pluck the left/right flower.

func _ready() -> void:
	_refresh_prop_regions()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Q:
			%Flower1.pluck()
		KEY_W:
			%Flower2.pluck()


func _refresh_prop_regions() -> void:
	for flower in get_tree().get_nodes_in_group("flowers"):
		flower.region = Rect2(Vector2.ZERO, %Panel.size)


func _on_panel_resized() -> void:
	_refresh_prop_regions()

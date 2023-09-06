extends CanvasGroup
## Drop shadows which appears behind cards to separate them from the background.
##
## Shadows are created for any nodes in the 'card_shadow_casters' group which are children of the specified parent
## panel.

@export var CardShadowScene: PackedScene
@export var ParentPanelPath: NodePath

## The parent panel containing the cards and shadows. The scene tree contains multiple CardShadows instances, but each
## only creates shadows for cards in a particular ParentPanel.
var _parent_panel: Node

func _ready() -> void:
	_parent_panel = get_node(ParentPanelPath)
	
	## Create shadows for all cards in the scene tree which are children of our parent panel.
	for card in get_tree().get_nodes_in_group("card_shadow_casters"):
		if _parent_panel.is_ancestor_of(card):
			create_shadow(card)
	
	Global.card_shadow_caster_added.connect(_on_global_card_shadow_caster_added)


## Creates a shadow for the specified card.
func create_shadow(card: Node) -> void:
	var shadow: CardShadow = CardShadowScene.instantiate()
	shadow.card = card
	add_child(shadow)


## Create a shadow for the newly generated card if it is a child of our parent panel.
func _on_global_card_shadow_caster_added(card: Node) -> void:
	if _parent_panel.is_ancestor_of(card):
		create_shadow(card)

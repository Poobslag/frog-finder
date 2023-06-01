extends Node
## Manages global properties and signals

## Emitted when a node is added to the scene tree which belongs to the 'card_shadow_casters' group.
##
## Parameters:
## 	'card': The node which was added. This should be a Control or a Node2D.
@warning_ignore("unused_signal")
signal card_shadow_caster_added(card)

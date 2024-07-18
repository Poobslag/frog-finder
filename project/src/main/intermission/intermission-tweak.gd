class_name IntermissionTweak
extends Node
## Parent class for 'intermission tweaks', scripts which modify the intermission in some ways.
##
## Different intermission tweaks might change sprites, add objects or sound effects. This script acts as a generic
## framework for all tweaks.

@onready var panel: IntermissionPanel = get_parent()

func _ready() -> void:
	# Wait for the parent IntermissionPanel to be initialized.
	await get_tree().process_frame
	
	apply_tweak()


func _exit_tree() -> void:
	revert_tweak()


## Applies this tweak to the IntermissionPanel.
##
## Should be overridden by the extending class to initialize the tweak -- adding objects, changing sprites, etc.
func apply_tweak() -> void:
	pass


## Reverts this tweak from the IntermissionPanel.
##
## Should be overridden by the extending class to revert the tweak -- removing objects, reverting sprites, etc.
func revert_tweak() -> void:
	pass

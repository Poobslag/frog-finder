class_name CreatureBehavior
extends Node
## Defines a behavior for a frog or shark.
##
## This behavior is something complex like 'chasing after the cursor' or 'doing a dance', and can combine several
## actions or animations.

## Starts the behavior.
##
## Parameters:
## 	_creature: The RunningFrog or RunningShark which should perform this behavior.
func start_behavior(_creature: Node) -> void:
	pass


## Stops the behavior.
##
## This is called before changing to a new behavior. It should stop any timers and reset any transient data for this
## behavior.
##
## Parameters:
## 	_creature: The RunningFrog or RunningShark which should stop performing this behavior.
func stop_behavior(_creature: Node) -> void:
	pass

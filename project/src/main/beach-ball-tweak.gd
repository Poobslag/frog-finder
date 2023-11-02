extends IntermissionTweak
## Tweaks the intermission to include bouncing beach balls.
##
## The beach balls sit on the floor, but will bounce when frogs or sharks bump into them, or if the player clicks them.

## The maximum radius from the ball's center in world coordinates where it is considered 'clicked'
const BALL_CLICK_RADIUS := 50.0

@export var BeachBallScene: PackedScene

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & MOUSE_BUTTON_LEFT:
		var ball := _find_clicked_ball()
		if ball:
			ball.bounce()


## Returns the clicked ball for the current mouse position.
##
## If one or more balls are close enough to the mouse, this method returns the closest one. If no balls are close
## enough, this method returns null.
##
## Returns: The closest ball to the mouse, or 'null' if no balls are close enough to be clicked.
func _find_clicked_ball() -> BeachBall:
	var clicked_ball: BeachBall
	var clicked_ball_distance := 999999.0
	
	# find the ball closest to the mouse
	var local_mouse_position := panel.obstacles.get_local_mouse_position()
	for next_ball_obj in get_tree().get_nodes_in_group("beach_balls"):
		var next_ball: BeachBall = next_ball_obj
		var next_ball_distance := next_ball.get_clickable_position().distance_to(local_mouse_position)
		if next_ball_distance < clicked_ball_distance:
			clicked_ball = next_ball
			clicked_ball_distance = next_ball_distance
	
	# if the closest ball is outside the click radius, disregard it
	if clicked_ball_distance > BALL_CLICK_RADIUS:
		clicked_ball = null
	
	return clicked_ball


## Applies this tweak to the IntermissionPanel.
func apply_tweak() -> void:
	for _i in range(4):
		_add_ball()


## Reverts this tweak from the IntermissionPanel.
func revert_tweak() -> void:
	## remove all beach balls
	for ball in get_tree().get_nodes_in_group("beach_balls"):
		ball.queue_free()


## Adds a beach ball to a random location.
func _add_ball() -> void:
	var ball: BeachBall = BeachBallScene.instantiate()
	_refresh_bounce_rect(ball)
	ball.position = Vector2(
		randf_range(ball.bounce_rect.position.x, ball.bounce_rect.end.x),
		randf_range(ball.bounce_rect.position.y, ball.bounce_rect.end.y)
	)
	panel.obstacles.add_child(ball)


## Refreshes the boundaries for the specified beach ball.
func _refresh_bounce_rect(ball: BeachBall) -> void:
	ball.bounce_rect = Rect2(Vector2.ZERO, panel.obstacles.size)

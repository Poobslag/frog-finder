extends Node
## Demonstrates the beach ball sprite.
##
## Keys:
## 	[1..3]: Bounce a beach ball
## 	[=]: Add a beach ball
## 	[shift + =]: Add ten beach balls
## 	[-]: Remove a beach ball
## 	[shift + -]: Remove ten beach balls
## 	[space]: Bounce all beach balls

@export var BeachBallScene: PackedScene

func _ready() -> void:
	for _i in range(3):
		_add_ball()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1:
			_bounce_ball(0)
		KEY_2:
			_bounce_ball(1)
		KEY_3:
			_bounce_ball(2)
		KEY_SPACE:
			for i in range(%Panel.get_child_count()):
				_bounce_ball(i)
		KEY_MINUS:
			if Input.is_key_pressed(KEY_SHIFT):
				for _i in range(10):
					_remove_ball()
			else:
				_remove_ball()
		KEY_EQUAL:
			if Input.is_key_pressed(KEY_SHIFT):
				for _i in range(10):
					_add_ball()
			else:
				_add_ball()


func _add_ball() -> void:
	var ball: BeachBall = BeachBallScene.instantiate()
	ball.bounce_rect = Rect2(Vector2.ZERO, %Panel.size)
	ball.position.x = randf_range(ball.bounce_rect.position.x, ball.bounce_rect.end.x)
	ball.position.y = randf_range(ball.bounce_rect.position.y, ball.bounce_rect.end.y)
	%Panel.add_child(ball)


func _remove_ball() -> void:
	if %Panel.get_child_count() > 0:
		var ball: BeachBall = %Panel.get_child(-1)
		ball.queue_free()
		%Panel.remove_child(ball)


func _bounce_ball(index: int) -> void:
	if %Panel.get_child_count() > index:
		%Panel.get_child(index).bounce()


func _refresh_bounce_rect() -> void:
	for ball in %Panel.get_children():
		ball.bounce_rect = Rect2(Vector2.ZERO, %Panel.size)


func _on_panel_resized() -> void:
	_refresh_bounce_rect()

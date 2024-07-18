extends ClickableIcon
## Button which lets the player skip comic animations.

## Temporarily hides the button to prevent the player from skipping the comic too quickly.
func hide_briefly() -> void:
	visible = false
	%ShowTimer.start()


func _on_timer_timeout() -> void:
	visible = true

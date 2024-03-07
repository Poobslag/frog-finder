extends CreatureBehavior
## Defines how a frog dances.

## The different states a frog progresses through before and after a dance.
enum DanceState {
	NONE, ## The frog is not dancing or running.
	RUN_TO_DANCE, ## The frog is running to the dance target.
	WAIT_TO_DANCE, ## The frog is waiting at the dance target.
	DANCE, ## The frog is dancing.
	RUN_FROM_DANCE, ## The frog is running from the dance target.
}

## Threshold where the frog adjusts their animation to sync back up with the music.
const DESYNC_THRESHOLD_MSEC := 100

## Threshold where the frog is considered to have reached the dance target
const REACHED_TARGET_DISTANCE := 20.0

## RunningFrog instances participating in the current dance. The first frog is the leader.
var frogs: Array

var dance_target: Vector2

## A String like 'nip3 shuffle2 hips2_flip 59 !59 56 58' describing animations and frames for a dance.
var dance_moves: String

## The current state a frog is progressing through before, during or after a dance.
var _dance_state: int = DanceState.NONE

var _frog: RunningFrog

## Frogs which haven't reached their dance targets. The lead frog keeps track of this list to know when to tell
## everyone to start dancing.
##
## key: (RunningFrog) a frog which has not yet made it to their dance target
## value: (bool) true
var _frogs_running_to_dance := {}

## Checks whether the frog needs to adjust their animation to sync back up with the music.
@onready var _sync_check_timer := $SyncCheckTimer

## Makes decisions every few frames
@onready var _think_timer := $ThinkTimer

## Makes the frogs dance after a brief delay.
@onready var _wait_to_dance_timer := $WaitToDanceTimer

## Stores simple looped 4-frame dance animations.
@onready var _dance_animations: DanceAnimations = $DanceAnimations

## Strings together a series of dance animations.
@onready var _choreographer := $Choreographer

func _process(_delta: float) -> void:
	if _dance_state == DanceState.RUN_TO_DANCE:
		var close_enough := (dance_target - _frog.soon_position).length() <= REACHED_TARGET_DISTANCE
		var running_away := (dance_target - _frog.soon_position).dot(_frog.velocity) <= 0.0
		if close_enough and running_away:
			set_state(DanceState.WAIT_TO_DANCE)


## Starts a new dance. The frog runs towards their dance target.
func start_behavior(new_frog: Node) -> void:
	_frog = new_frog
	_think_timer.start(randf_range(0, 0.1))
	
	if is_lead_frog():
		for next_frog in frogs:
			_frogs_running_to_dance[next_frog] = true
			next_frog.reached_dance_target.connect(_on_running_frog_reached_dance_target.bind(next_frog))
	
	set_state(DanceState.RUN_TO_DANCE)


func set_state(new_dance_state: int) -> void:
	_dance_state = new_dance_state
	
	match new_dance_state:
		DanceState.RUN_TO_DANCE:
			# The frog runs to their dance target
			_adjust_velocity_toward_dance_target()
			_frog.run()
		DanceState.WAIT_TO_DANCE:
			# The frog waits for other frogs to reach their dance targets
			_frog.soon_position = dance_target
			_frog.update_position()
			_frog.velocity = Vector2.ZERO
			_frog.play_animation("stand")
			_frog.reached_dance_target.emit()
		DanceState.DANCE:
			# The frog does some dance moves
			_choreographer.play("dance")
			_sync_check_timer.start()
		DanceState.RUN_FROM_DANCE:
			# After the dance, the frog runs toward the edge of the screen
			if is_lead_frog():
				MusicPlayer.play_preferred_song()
				MusicPlayer.fade_in()
			_frog.velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * _frog.run_speed
			_frog.run()
			_frog.finished_dance.emit()
			_sync_check_timer.stop()


## Returns 'true' if this frog is the one giving out orders to other frogs.
##
## The 'lead frog' has several unique responsibilities. They make sure all the frogs have arrived, think of some cool
## dance moves, and tell the other frogs when to start dancing.
func is_lead_frog() -> bool:
	return frogs and _frog == frogs[0]


## Stops any timers and resets any transient data for this behavior.
func stop_behavior(_new_frog: Node) -> void:
	# disconnect signals
	if is_lead_frog():
		for next_frog in frogs:
			if next_frog.reached_dance_target.is_connected(_on_running_frog_reached_dance_target):
				next_frog.reached_dance_target.disconnect(_on_running_frog_reached_dance_target.bind([next_frog]))
	
	frogs = []
	dance_target = Vector2.ZERO
	dance_moves = ""
	
	_dance_state = DanceState.NONE
	_frog = null
	_frogs_running_to_dance.clear()
	
	_sync_check_timer.stop()
	_wait_to_dance_timer.stop()
	_dance_animations.stop()
	_choreographer.stop()


## Performs the specified move from our dance moves string.
##
## Before dancing, we're given a set of dance moves like 'nip3 shuffle2 hips2_flip 59 !59 56 58'. This method performs
## a specific move in that sequence, which might involve playing an animation like 'shuffle2' or holding a specific
## animation frame like '59'.
func perform_dance_move(dance_move_index: int) -> void:
	_frog.stop_animation()
	
	var dance_moves_array := dance_moves.split(" ")
	if dance_move_index < 0 or dance_move_index > dance_moves_array.size():
		push_error("Invalid dance move index: %s (dance_moves='%s')" % [dance_move_index, dance_moves])
	var dance_move := dance_moves_array[dance_move_index]
	if dance_move in _dance_animations.get_animation_list():
		_dance_animations.play(dance_move)
	else:
		_dance_animations.stop()
		_frog.flip_h = dance_move.begins_with("!")
		_frog.frame = int(dance_move.lstrip("!"))


## Calculates a set of dance names the frogs will do.
##
## The frogs cycle through four dances. It's possible to repeat a dance, but never back-to-back.
func _decide_dance_names() -> Array:
	var result := []
	for _i in range(4):
		var possible_dance_names: Array[String]
		if PlayerData.get_world().dances:
			# select from one of a few preset dances for the world
			possible_dance_names.assign(PlayerData.get_world().dances)
		else:
			# select from all available dances
			possible_dance_names = _dance_animations.dance_names
		
		if not result.is_empty():
			var new_dance_names: Array[String] = []
			# workaround for Godot #72627 (https://github.com/godotengine/godot/issues/72627); Cannot cast typed arrays using
			# type hints
			new_dance_names.assign(Utils.subtract(possible_dance_names, [result.back()]))
			possible_dance_names = new_dance_names
		result.append(Utils.rand_value(possible_dance_names))
	
	if PlayerData.get_world().dances:
		# ensure the mandatory dance is one of the first three dances
		var mandatory_dance: String = PlayerData.get_world().dances[0]
		
		if result.find(mandatory_dance) == -1 or result.find(mandatory_dance) == 3:
			# assign it to one of the first two dance slots; it's possible it's the fourth dance, and we don't want
			# the same dance back-to-back
			result[randi_range(0, 1)] = mandatory_dance
	
	return result


## Calculates the dance moves based on a set of dance names.
##
## A set of dance names is something like ['hips' 'coy' 'hips' 'shuffle'], but this method breaks them down into
## animation names and frames, like 'hips1_flip coy2 hips2 22 !21 21 23'
func _decide_dance_moves(dance_names: Array) -> String:
	var result := []
	## determine the animation names for the first three dances
	for i in range(3):
		var possible_animation_names: Array = _dance_animations.animation_names_by_dance_name[dance_names[i]]
		result.append(Utils.rand_value(possible_animation_names))
	
	## determine the animation frames for the four final poses of the fourth dance
	var all_pose_frames: Array = _dance_animations.frames_by_dance_name[dance_names[3]]
	var new_dance_moves := []
	for i in range(4):
		new_dance_moves.append(Utils.rand_value(all_pose_frames) * Utils.rand_value([-1, 1]))
		if i >= 1 and new_dance_moves[i] == new_dance_moves[i - 1]:
			new_dance_moves[i] *= -1
	
	for final_dance_move in new_dance_moves:
		result.append("%s%s" % ["!" if final_dance_move < 0 else "", abs(final_dance_move)])
	return " ".join(PackedStringArray(result))


## Orient the frog's velocity toward the dance target.
##
## This should only need to be called once when the frog starts running, but we call it again just in case the frog
## overruns their target.
func _adjust_velocity_toward_dance_target() -> void:
	var target_distance: Vector2 = dance_target - _frog.position
	_frog.velocity = target_distance.normalized() * _frog.run_speed


## After a frog runs for a little while, they lock themselves into their their dance target.
func _on_run_timer_timeout() -> void:
	set_state(DanceState.WAIT_TO_DANCE)


## When a frog reaches their dance target, the lead frog checks if it's time to start the dance.
func _on_running_frog_reached_dance_target(other_frog: RunningFrog) -> void:
	if not is_lead_frog():
		return
	
	other_frog.reached_dance_target.disconnect(_on_running_frog_reached_dance_target)
	_frogs_running_to_dance.erase(other_frog)
	if _frogs_running_to_dance.is_empty():
		# all frogs have reached their dance targets, we can start dancing
		var dance_names := _decide_dance_names()
		dance_moves = _decide_dance_moves(dance_names)
		for frog in frogs:
			frog.behavior.dance_moves = dance_moves
		
		_wait_to_dance_timer.start()
		MusicPlayer.fade_out(_wait_to_dance_timer.wait_time * 0.5)


## After pausing for a moment, the lead frog tells everyone to dance.
func _on_wait_to_dance_timer_timeout() -> void:
	if not is_lead_frog():
		return
	
	if PlayerData.music_preference != PlayerData.MusicPreference.OFF:
		MusicPlayer.play_dance_song()
	for frog in frogs:
		frog.behavior.set_state(DanceState.DANCE)


## Every once in awhile, we check to make sure the music is in sync with our animations.
##
## These can fall out of sync if the game runs too slow for some reason. I can force it to happen by dragging the
## window around.
func _on_sync_check_timer_timeout() -> void:
	if not MusicPlayer.is_playing_dance_song():
		return
	
	var desync_amount: float = MusicPlayer.get_playback_position() - _choreographer.current_animation_position
	
	if abs(desync_amount * 1000) > DESYNC_THRESHOLD_MSEC:
		_choreographer.advance(desync_amount)


## Every once in awhile, we check to make sure we're still running to our dance target.
##
## It's theoretically possible that we could run past our target and need to turn around.
func _on_think_timer_timeout() -> void:
	if _dance_state == DanceState.RUN_TO_DANCE:
		var close_enough := (_frog.soon_position - dance_target).length() <= REACHED_TARGET_DISTANCE
		if not close_enough:
			# make sure we're still running to the target
			_adjust_velocity_toward_dance_target()

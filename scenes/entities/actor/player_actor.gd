extends Actor

var _move_direction := Vector2.ZERO


#func actor_setup() -> void:
#	super()
#	change_state(Constants.ActorState.IDLING)

########## STATE #############

## update the current state
#func update_state() -> void:
#	# dont change state if dead
#	if _state == Constants.ActorState.DEAD:
#		return
#
#	if _state == Constants.ActorState.IDLING or _state == Constants.ActorState.MOVING:
#		_move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
#
#	if _move_direction != Vector2.ZERO and _state == Constants.ActorState.IDLING:
#		change_state(Constants.ActorState.MOVING)
#	elif velocity == Vector2.ZERO and _state == Constants.ActorState.MOVING:
#		change_state(Constants.ActorState.IDLING)
#
#
### process the current state, e.g. moving if in MOVING
#func process_current_state() -> void:
#	match _state:
#		Constants.ActorState.IDLING:
##			refresh_target()  # TODO: this will be too resource heavy. User timer to force refreshes.
#			pass
#
#		Constants.ActorState.CASTING:
#			pass
#
#		Constants.ActorState.ATTACKING:
#			pass
#
#		Constants.ActorState.MOVING:
#			_move()
#			_refresh_facing()
#
#		Constants.ActorState.DEAD:
#			pass
#
#
#func _move() -> void:
#	if _move_direction != Vector2.ZERO:
#		velocity = _move_direction * stats.move_speed
#	else:
#		velocity = velocity.move_toward(Vector2.ZERO, stats.move_speed)
#	move_and_slide()

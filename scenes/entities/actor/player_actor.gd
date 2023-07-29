extends Actor

var _move_direction := Vector2.ZERO

########## STATE #############

## update the current state
func update_state() -> void:
	# dont change state if dead
	if _state == Constants.ActorState.DEAD:
		return
	
	if _state == Constants.ActorState.IDLING or _state == Constants.ActorState.MOVING:
		_move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if _move_direction != Vector2.ZERO and _state == Constants.ActorState.IDLING:
		change_state(Constants.ActorState.MOVING)
	elif velocity == Vector2.ZERO and _state == Constants.ActorState.MOVING:
		change_state(Constants.ActorState.IDLING)
	
	
#	# if we have target, move towards them, else get new
#	if _target != null:
#		# cast if in range, else move closer
#		_navigation_agent.target_position = _target.global_position
#		var in_attack_range : bool = _navigation_agent.distance_to_target() <= attack_range
#		if in_attack_range and has_ready_attack:
#			# set target pos to current pos to stop moving
#			_navigation_agent.target_position = global_position
#
#			# if not yet attacking or casting, cast
#			if _state != Constants.ActorState.ATTACKING and _state != Constants.ActorState.CASTING:
#				attack_to_cast = _actions.get_random_attack()
#				change_state(Constants.ActorState.CASTING)  #  attack is triggered after cast
#
#		# has target but not in range, move towards target
#		else:
#			if _state != Constants.ActorState.MOVING:
#				change_state(Constants.ActorState.MOVING)
#
#	# has no target, go idle
#	else:
#		if _state != Constants.ActorState.MOVING:
#			change_state(Constants.ActorState.IDLING)


## process the current state, e.g. moving if in MOVING
func process_current_state() -> void:
	match _state:
		Constants.ActorState.IDLING:
#			refresh_target()  # TODO: this will be too resource heavy. User timer to force refreshes.
			pass
		
		Constants.ActorState.CASTING:
			pass
		
		Constants.ActorState.ATTACKING:
			pass
		
		Constants.ActorState.MOVING:
			_move()
			_refresh_facing()
		
		Constants.ActorState.DEAD:
			pass


func _move() -> void:
	if _move_direction != Vector2.ZERO:
		velocity = _move_direction * stats.move_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, stats.move_speed)
	move_and_slide()

#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
## Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#
#
#func _physics_process(delta):
#	# Add the gravity.
#	if not is_on_floor():
#		velocity.y += gravity * delta
#
#	# Handle Jump.
#	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		velocity.y = JUMP_VELOCITY
#
#	# Get the input direction and handle the movement/deceleration.
#	# As good practice, you should replace UI actions with custom gameplay actions.
#	var direction = Input.get_axis("ui_left", "ui_right")
#	if direction:
#		velocity.x = direction * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#
#	move_and_slide()

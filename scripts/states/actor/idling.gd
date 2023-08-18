extends BaseState



## actions on entering state
func enter_state() -> void:
	_creator.animated_sprite.play("idle")



func physics_process(_delta: float) -> void:
	if _creator.attack_to_cast == null:
		_creator.attack_to_cast = _creator.actions.get_random_attack()
		# get new target
		if _creator.attack_to_cast != null:
			_creator._attempt_target_refresh(
					_creator.attack_to_cast.target_type, 
					_creator.attack_to_cast.target_preferences,
			)


## take action based on current state
func decide_next_state() -> void:
	# has no target, go idle
	if _creator._target == null or _creator.attack_to_cast == null:
		return
	
	_creator._navigation_agent.target_position = _creator._target.global_position
	var in_attack_range : bool = \
			_creator._navigation_agent.distance_to_target() <= _creator.attack_to_cast.range
	
	# we have target and attack so cast if in range, else move closer
	if in_attack_range and _creator.has_ready_attack:
		# set target pos to current pos to stop moving
		_creator._navigation_agent.target_position = _creator.global_position
		_creator.state_machine.change_state(Constants.ActorState.CASTING)
	elif not in_attack_range and _creator.has_ready_attack:
		_creator.state_machine.change_state(Constants.ActorState.PURSUING)


## actions on exiting state
func exit_state() -> void:
	pass

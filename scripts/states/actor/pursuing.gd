extends BaseState


## actions on entering state
func enter_state() -> void:
	_creator.animated_sprite.play("walk")
	_creator._navigation_agent.target_position = _creator._target.global_position
	_creator._navigation_agent.velocity_computed.connect(
			_creator._on_navigation_agent_velocity_computed
	)


func physics_process(_delta: float) -> void:
	if _creator._target or not _creator._navigation_agent.is_navigation_finished():
		_creator.move_towards_target()
		_creator._refresh_facing()
		_creator._attempt_target_refresh(_creator.attack_to_cast)


## take action based on current state
func decide_next_state() -> void:
	if _creator._target == null or _creator.attack_to_cast == null:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)
		return
	
	if not _creator._target.is_in_group("alive"):
		_creator.state_machine.change_state(Constants.ActorState.IDLING)
		return
	
	_creator._navigation_agent.target_position = _creator._target.global_position
	
	var in_attack_range : bool = \
			_creator._navigation_agent.distance_to_target() <= _creator.attack_to_cast.range
	if in_attack_range and _creator.has_ready_attack:
		# set target pos to current pos to stop moving
		_creator._navigation_agent.target_position = _creator.global_position
		_creator.state_machine.change_state(Constants.ActorState.CASTING)
	elif _creator._navigation_agent.is_navigation_finished():
		_creator.state_machine.change_state(Constants.ActorState.IDLING)


## actions on exiting state
func exit_state() -> void:
	_creator._navigation_agent.velocity_computed.disconnect(
			_creator._on_navigation_agent_velocity_computed
	)
	pass

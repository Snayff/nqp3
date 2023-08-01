extends BaseState


## actions on entering state
func enter_state() -> void:
	_creator.animated_sprite.play("walk")



func physics_process(delta: float) -> void:
	_creator.move_towards_target()
	_creator._refresh_facing()


## take action based on current state
func update_state() -> void:
	if _creator._target == null or _creator.attack_to_cast == null:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)
		return
	
	_creator._navigation_agent.target_position = _creator._target.global_position
	var in_attack_range : bool = \
			_creator._navigation_agent.distance_to_target() <= _creator.attack_to_cast.range
	if in_attack_range and _creator.has_ready_attack:
		# set target pos to current pos to stop moving
		_creator._navigation_agent.target_position = _creator.global_position
		_creator.state_machine.change_state(Constants.ActorState.CASTING)


## actions on exiting state
func exit_state() -> void:
	pass


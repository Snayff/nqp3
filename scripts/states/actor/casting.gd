extends BaseState


## actions on entering state
func enter_state() -> void:
	_creator.animated_sprite.play("cast")
	_creator._cast_timer.start(_creator.attack_to_cast.cast_time)
	_creator._cast_timer.timeout.connect(_on_cast_timer_timeout)


func physics_process(_delta: float) -> void:
	pass


## take action based on current state
func decide_next_state() -> void:
	if _creator._target == null:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)


## actions on exiting state
func exit_state() -> void:
	_creator._cast_timer.timeout.disconnect(_on_cast_timer_timeout)


func _on_cast_timer_timeout() -> void:
	if _creator._target != null and _creator.has_ready_attack:
		_creator.state_machine.change_state(Constants.ActorState.ATTACKING)
	else:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)

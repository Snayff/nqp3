extends BasePlayerState


## actions on entering state
func enter_state() -> void:
	_player.animated_sprite.play("cast")
	_player._cast_timer.start(_player.attack_to_cast.cast_time)
	_player._cast_timer.timeout.connect(_on_cast_timer_timeout)


func physics_process(_delta: float) -> void:
	pass


## take action based on current state
func update_state() -> void:
	if _get_current_target() == null:
		_player.state_machine.change_state(Constants.ActorState.IDLING)


## actions on exiting state
func exit_state() -> void:
	_player._cast_timer.timeout.disconnect(_on_cast_timer_timeout)


func _on_cast_timer_timeout() -> void:
	if _get_current_target() != null and _player.has_ready_attack:
		_player.state_machine.change_state(Constants.ActorState.ATTACKING)
	else:
		_player.state_machine.change_state(Constants.ActorState.IDLING)

extends MoveableState


## actions on entering state
func enter_state():
	_player.animated_sprite.play("walk")


func unhandled_input(event: InputEvent) -> void:
	super(event)


func physics_process(_delta):
	_move()
	_player._refresh_facing()


## take action based on current state
func update_state():
	super()
	if _player.velocity == Vector2.ZERO:
		_player.state_machine.change_state(Constants.ActorState.IDLING)


## actions on exiting state
func exit_state():
	pass


func _move() -> void:
	if _player.move_direction != Vector2.ZERO:
		_player.velocity = _player.move_direction * _player.stats.move_speed
	else:
		_player.velocity = _player.velocity.move_toward(Vector2.ZERO, _player.stats.move_speed)
	_player.move_and_slide()

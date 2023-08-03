extends BaseState


## actions on entering state
func enter_state():
	_creator.animated_sprite.play("walk")



func physics_process(_delta):
	_move()
	_creator._refresh_facing()


## take action based on current state
func update_state():
	_creator.move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _creator.velocity == Vector2.ZERO:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)


## actions on exiting state
func exit_state():
	pass


func _move() -> void:
	if _creator.move_direction != Vector2.ZERO:
		_creator.velocity = _creator.move_direction * _creator.stats.move_speed
	else:
		_creator.velocity = _creator.velocity.move_toward(Vector2.ZERO, _creator.stats.move_speed)
	_creator.move_and_slide()

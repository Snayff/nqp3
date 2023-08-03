extends BaseState


## actions on entering state
func enter_state():
	_creator.animated_sprite.play("idle")


func physics_process(_delta):
	pass


## take action based on current state
func update_state():
	_creator.move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _creator.move_direction != Vector2.ZERO:
		_creator.state_machine.change_state(Constants.ActorState.MOVING)


## actions on exiting state
func exit_state():
	pass


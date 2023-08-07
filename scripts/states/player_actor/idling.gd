extends MoveableState

## actions on entering state
func enter_state():
	_player.animated_sprite.play("idle")


func unhandled_input(event: InputEvent) -> void:
	super(event)


func physics_process(_delta):
	pass


## take action based on current state
func update_state():
	super()
	if _player.move_direction != Vector2.ZERO:
		_player.state_machine.change_state(Constants.ActorState.MOVING)
		return


## actions on exiting state
func exit_state():
	pass

extends "moveable.gd"

## actions on entering state
func enter_state():
	_player.animated_sprite.play("idle")


func unhandled_input(event: InputEvent) -> void:
	super(event)


func physics_process(delta):
	super(delta)


## take action based on current state
func decide_next_state() -> void:
	if _player.move_direction != Vector2.ZERO:
		_player.state_machine.change_state(Constants.ActorState.PLAYER_MOVING)


## actions on exiting state
func exit_state():
	pass

extends BaseState

const FLEE_DISTANCE = 300.0

## actions on entering state
func enter_state() -> void:
	_creator.animated_sprite.play("walk")
	_creator._navigation_agent.target_position = _get_flee_position()


func unhandled_input(event: InputEvent) -> void:
	_creator.move_towards_target()
	_creator._refresh_facing()


func physics_process(delta: float) -> void:
	pass


## take action based on current state
func update_state() -> void:
	if _creator._target == null or _creator._navigation_agent.is_navigation_finished():
		_creator._navigation_agent.target_position = _creator.global_position
		_creator.state_machine.change_state(Constants.ActorState.IDLING)
		return
	
	var flee_position := _get_flee_position()
	if _creator._navigation_agent.target_position != flee_position:
		_creator._navigation_agent.target_position = flee_position


## actions on exiting state
func exit_state() -> void:
	pass


func _get_flee_position() -> Vector2:
	var target_position = _creator._target.global_position
	var away_angle := target_position.angle_to_point(_creator.global_position)
	var flee_position := _get_position_from_polar_coordinate(
			target_position, away_angle, FLEE_DISTANCE
	)
	return flee_position
	


func _get_position_from_polar_coordinate(
		center_pos: Vector2, 
		angle: float, 
		radius: float
) -> Vector2:
	var value = center_pos + Vector2.from_angle(angle) * FLEE_DISTANCE
	return value

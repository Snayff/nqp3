extends "res://scripts/states/actor/casting.gd"

var attack_range_squared := INF

## actions on entering state
func enter_state() -> void:
	attack_range_squared = pow(_creator.attack_to_cast.range, 2)
	super()


## take action based on current state
func decide_next_state() -> void:
	if _creator.stats.is_low_health():
		if _creator.attack_to_cast.range <= Constants.MELEE_RANGE:
			_creator.state_machine.change_state(Constants.ActorState.FLEEING)
		else:
			if _is_attack_in_range():
				_creator.state_machine.change_state(Constants.ActorState.ATTACKING)
	else:
		super()


func _on_cast_timer_timeout() -> void:
	if _creator._target != null and _creator.has_ready_attack:
		if _is_attack_in_range():
			_creator.state_machine.change_state(Constants.ActorState.ATTACKING)
		else:
			if not _creator.stats.is_low_health():
				_creator.state_machine.change_state(Constants.ActorState.IDLING)
	else:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)


func _is_attack_in_range() -> bool:
	var distance_to_target := \
			_creator.global_position.distance_squared_to(_creator._target.global_position)
	return distance_to_target <= attack_range_squared

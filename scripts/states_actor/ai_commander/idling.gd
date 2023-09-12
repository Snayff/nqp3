extends "../actor/idling.gd"


var highest_range_attack: BaseAction = null

func _ready() -> void:
	var min_range := Constants.MELEE_RANGE
	for action_uid in _creator.actions.attacks:
		var attack := _creator.actions.attacks[action_uid] as BaseAction
		if attack.range > min_range:
			highest_range_attack = attack
			min_range = attack.range


func decide_next_state() -> void:
	if _creator._target != null and _creator.stats.is_low_health():
		var distance_to_target = \
				_creator.global_position.distance_squared_to(_creator._target.global_position)
		if distance_to_target < Constants.MIN_SAFE_DISTANCE_SQUARED:
			_creator.state_machine.change_state(Constants.ActorState.FLEEING)
		else:
			_creator.attack_to_cast = highest_range_attack
			_creator.state_machine.change_state(Constants.ActorState.CASTING)
	else:
		super()


## actions on exiting state
func exit_state() -> void:
	pass

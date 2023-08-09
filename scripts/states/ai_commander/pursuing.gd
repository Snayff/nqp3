extends "res://scripts/states/actor/pursuing.gd"


## take action based on current state
func update_state() -> void:
	if _creator.stats.is_low_health():
		_creator.state_machine.change_state(Constants.ActorState.FLEEING)
		return
	
	super()

extends "res://scripts/states/actor/attacking.gd"



## take action based on current state
func decide_next_state() -> void:
	if _creator._target == null:
		_go_to_next_state()


func _on_animated_sprite_animation_looped() -> void:
	if _creator._target == null:
		_go_to_next_state()
	else:
		_creator.attack()
		_go_to_next_state()


func _go_to_next_state() -> void:
	if _creator.stats.is_low_health():
		_creator.state_machine.change_state(Constants.ActorState.FLEEING)
	else:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)

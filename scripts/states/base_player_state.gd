class_name BasePlayerState 
extends BaseState
## base class for an entities state

var _player : PlayerActor


func _init(creator: Actor) -> void:
	_creator = creator
	_player = creator as PlayerActor


## actions on entering state
## @tag virtual function
func enter_state() -> void:
	pass


## @tag virtual function
func unhandled_input(_event: InputEvent) -> void:
	pass


## @tag virtual function
func physics_process(_delta: float) -> void:
	pass


## take action based on current state
## @tag virtual function
func decide_next_state() -> void:
	pass


## actions on exiting state
## @tag virtual function
func exit_state() -> void:
	pass


func _get_current_target() -> Actor:
	var current_target: Actor = null
	
	if _player.attack_to_cast != null:
		current_target = _player.targets[_player.attack_to_cast.uid] as Actor
	
	return current_target

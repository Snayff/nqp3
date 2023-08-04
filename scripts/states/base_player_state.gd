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
func unhandled_input(event: InputEvent) -> void:
	pass


## @tag virtual function
func physics_process(delta: float) -> void:
	pass


## take action based on current state
## @tag virtual function
func update_state() -> void:
	pass


## actions on exiting state
## @tag virtual function
func exit_state() -> void:
	pass


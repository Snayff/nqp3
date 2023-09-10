class_name BaseStateUnit extends Node
## base class for an entities state

var _creator : Unit


func _init(creator: Unit) -> void:
	_creator = creator


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

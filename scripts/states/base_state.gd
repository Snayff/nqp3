class_name BaseState extends Node
## base class for an entities state


## actions on entering state
## @tag virtual function
func enter_state() -> void:
	pass



## @tag virtual function
func _physics_process(delta: float) -> void:
	pass


## take action based on current state
## @tag virtual function
func update_state() -> void:
	pass


## actions on exiting state
## @tag virtual function
func exit_state() -> void:
	pass

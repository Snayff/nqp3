class_name StateMachine extends Node
## the state machine that controls what state the assigned entity is in

var current_state : BaseState:
	get:
		if _current_state_id:
			if _current_state_id in _states:
				return _states[_current_state_id]
		return null
	set(_value):
		print("Tried to set current state manually. Not allowed.")
var _current_state_id : int
var _states : Dictionary = {}   # {str, BaseState}

func _init(states: Array[Constants.ActorState]) -> void:
	for state in states:
		var uid = Utility.generate_id()
		_states[] Factory._create_state(state)






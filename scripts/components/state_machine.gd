class_name StateMachine extends Node
## the state machine that controls what state the assigned entity is in

signal changed_state(new_state: Constants.ActorState, old_state: Constants.ActorState)

var uid : int
var current_state : BaseState:  ## can return null if no current state
	get:
		if _current_state_name:
			if _current_state_name in _states:
				return _states[_current_state_name]
		return null
	set(_value):
		print("Tried to set current state manually. Not allowed.")
var _current_state_name : Constants.ActorState
var _states : Dictionary = {}   ## {Constants.ActorState, BaseState}

func _init(states: Array[Constants.ActorState]) -> void:
	uid = Utility.generate_id()

	for state_name in states:
		var _state = Factory.add_state(state_name)
		add_child(_state)
		_states[state_name] = _state

		# if we dont have a current state, use this one
		if not _current_state_name:
			_current_state_name = state_name

func change_state(state_name: Constants.ActorState) -> void:
	if state_name in _states:
		current_state.exit_state()

		changed_state.emit(_current_state_name, state_name)

		_current_state_name = state_name
		current_state.enter_state()


func _physics_process(delta: float) -> void:
	current_state._physics_process(delta)


func update_state() -> void:
	current_state.update_state()



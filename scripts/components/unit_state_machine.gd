class_name StateMachineUnit extends Node
## the state machine that controls what state the assigned entity is in

signal changed_state(new_state: Constants.ActorState, old_state: Constants.ActorState)

var uid : int
var current_state : BaseStateUnit:  ## can return null if no current state
	get:
		if _current_state_name in _states:
			return _states[_current_state_name]
		return null
	set(_value):
		push_error("Tried to set current state manually. Not allowed.")

var _current_state_name := Constants.UnitState.SEARCH_DESTROY
var _states : Dictionary = {}   ## {Constants.ActorState, BaseState}


func _init(_unit: Unit = null, _states: Array[Constants.ActorState] = [], _states_base_folder := "actor") -> void:
	uid = Utility.generate_id()
	
#	for state_name in states:
#		var _state = Factory.add_state(actor, state_name, states_base_folder)
#		add_child(_state)
#		_states[state_name] = _state
#
#	if not _current_state_name in states:
#		_current_state_name = states[0]


func _ready() -> void:
	var new_state := load("res://scenes/entities/unit/search_destroy.gd").new(owner) as BaseStateUnit
	add_child(new_state)
	_states[Constants.UnitState.SEARCH_DESTROY] = new_state
	_current_state_name = Constants.UnitState.SEARCH_DESTROY
	change_state(_current_state_name)


func change_state(state_name: Constants.UnitState) -> void:
	if state_name in _states:
		current_state.exit_state()
		
		changed_state.emit(_current_state_name, state_name)
		
		_current_state_name = state_name
		current_state.enter_state()


func _unhandled_input(event: InputEvent) -> void:
	current_state.unhandled_input(event)


func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)
	current_state.decide_next_state()

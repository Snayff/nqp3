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
var _states : Dictionary = {}   ## {Constants.UnitState: BaseStateUnit }


func _init(
		unit: Unit = null, 
		p_states: Array[Constants.UnitState] = [], 
		unit_type: Constants.UnitType = Constants.UnitType.AI_NORMAL
) -> void:
	uid = Utility.generate_id()
	
	for state_name in p_states:
		var state = Factory.add_unit_state(unit, state_name, unit_type)
		add_child(state)
		_states[state_name] = state
#
	if not _current_state_name in _states:
		_current_state_name = _states[0]


func _ready() -> void:
	if get_parent().owner == null:
		owner = get_parent()
	else:
		owner = get_parent().owner


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

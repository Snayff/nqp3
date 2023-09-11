class_name Unit extends Node2D
## A collection of [annotation Actor]s.
##
## Used to create and manage groups of Units.

signal unit_defeated

# defintions
@export var team: String:
	set(value):
		team = value
		
		if not is_inside_tree():
			await ready
		
		if not team.is_empty():
			_debug_visuals.unit_team = team
@export var unit_name: String
@export var unit_type := Constants.UnitType.AI_NORMAL

# Injected by factory
var state_machine : StateMachineUnit = null

# functional

var target_unit: Unit = null

var _actors : Array[Actor] = []

@onready var _debug_visuals := $DebugVisuals as DebugVisualsUnit


func _ready() -> void:
	SignalBus.stage_started.connect(_on_SignalBus_stage_started)

## spawn actors onto the combat map
func spawn_actors():
	var unit_data := RefData.get_unit_data(unit_name, unit_type) as UnitData
	for i in unit_data.num_units:
		var actor := Factory.create_actor(self, unit_name, team) as Actor
		_actors.append(actor)
		actor.parent_unit = self
		actor.died.connect(_on_actor_died)
	
	add_to_group("alive_unit")


func _on_actor_died() -> void:
	var is_unit_alive := _actors.any(_is_actor_alive)
	if not is_unit_alive:
		state_machine.change_state(Constants.UnitState.DEAD)


func _is_actor_alive(actor: Actor) -> bool:
	return actor.is_in_group("alive")


func _on_SignalBus_stage_started() -> void:
	state_machine.change_state(state_machine._current_state_name)

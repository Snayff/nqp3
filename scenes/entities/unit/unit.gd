class_name Unit extends Node2D
## A collection of [annotation combatant]s.
##
## Used to create and manage groups of Units.

# defintions
@export var team: String
@export var unit_name: String

# functional
@onready var target_timer : Timer = $TargetRefresh
var base_target_timer_duration := 3.3

var _actors : Array[Actor] = []


func _ready():
	# init timer
	target_timer.wait_time = base_target_timer_duration

## spawn actors onto the combat map
func spawn_actors():
	var unit_data = RefData.unit_data[unit_name]
	for i in unit_data["num_units"]:
		_actors.append(Factory.create_actor(self, unit_name, team))


## refresh targets and restart timer
func _on_timer_target_refresh_timeout() -> void:
	for actor in _actors:
		actor.refresh_target()

	# restart timer with random offset, so all target refreshes dont happen at once
	target_timer.start(base_target_timer_duration +  randf_range(-0.1, 0.1))

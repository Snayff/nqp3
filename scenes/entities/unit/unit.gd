class_name Unit extends Node2D
## A collection of [annotation Actor]s.
##
## Used to create and manage groups of Units.

# defintions
@export var team: String
@export var unit_name: String

# functional

var _actors : Array[Actor] = []

## spawn actors onto the combat map
func spawn_actors():
	var unit_data = RefData.unit_data[unit_name]
	for i in unit_data["num_units"]:
		_actors.append(Factory.create_actor(self, unit_name, team))

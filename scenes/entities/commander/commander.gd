extends Unit


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_actors()
	pass # Replace with function body.


func spawn_actors():
	var unit_data = RefData.unit_data[unit_name]
	for i in unit_data["num_units"]:
		_actors.append(Factory.create_player_actor(self, unit_name, team))

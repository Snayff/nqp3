extends Unit


func spawn_actors():
	var unit_data = RefData.unit_data[unit_name]
	var actor: Actor = null
	if team == Constants.TEAM_ALLY:
		actor = Factory.create_player_actor(self, unit_name, team)
	else:
		modulate = Color.RED
		actor = Factory.create_actor(self, unit_name, team)
	
	_actors.append(actor)

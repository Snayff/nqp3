extends Unit


func spawn_actors():
	var unit_data := RefData.get_unit_data(unit_name)
	var actor: Actor = null
	if team == Constants.TEAM_ALLY:
		actor = Factory.create_player_actor(self, unit_name, team)
	else:
		actor = Factory.create_actor(self, unit_name, team)
	
	_actors.append(actor)
	actor.died.connect(_on_actor_died)


func _on_actor_died() -> void:
	SignalBus.commander_died.emit(team)

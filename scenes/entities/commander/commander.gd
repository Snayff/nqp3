extends Unit


func spawn_actors():
	var unit_type := Constants.UnitType.AI_COMMANDER
	if team == Constants.TEAM_ALLY:
		unit_type = Constants.UnitType.PLAYER_ACTOR
	var actor: Actor = Factory.create_actor(self, unit_name, team, unit_type)
	
	_actors.append(actor)
	actor.died.connect(_on_actor_died)


func _on_actor_died() -> void:
	SignalBus.commander_died.emit(team)

extends StageCombat

func _ready() -> void:
	super()
	SignalBus.commander_died.connect(_on_SignalBus_commander_died)

## load units from the troupes involved in the combat
func _get_units_from_troupe() -> void:
	# FIXME: when troupes exist update to use troupe. placeholder code for now.
	
	var num_unit_per_team = 1
	var unit_name: String
	var unit_choices : Dictionary = {
		Constants.TEAM_ALLY: ["cavalier"],
		Constants.TEAM_ENEMY: ["knight"]
	}
	
	for key in _units.keys():
		for i in range(num_unit_per_team):
			unit_name = unit_choices[key][0]
			var unit_type := Constants.UnitType.AI_COMMANDER
			if key == Constants.TEAM_ALLY:
				unit_type = Constants.UnitType.PLAYER_ACTOR
			var unit = Factory.create_unit(self, unit_name, key, unit_type)
			unit.set_name(unit_name.to_pascal_case() + "_Unit")
			_units[key].append(unit)


func _on_SignalBus_commander_died(team: String) -> void:
	if team == Constants.TEAM_ALLY:
		print("You Lost, Game Over!")
	elif team == Constants.TEAM_ENEMY:
		print("You Won, Congratulations!")
	get_tree().paused = true

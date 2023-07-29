extends StageCombat

func _ready() -> void:
	super()
	SignalBus.commander_died.connect(_on_SignalBus_commander_died)

## load units from the troupes involved in the combat
func _get_units_from_troupe() -> void:
	# FIXME: when troupes exist update to use troupe. placeholder code for now.

	for key in _units.keys():
		var num_unit_per_team = 1
		var unit_name: String
		unit_name = "commander"
		
		for i in range(num_unit_per_team):
			var unit = Factory.create_unit(self, unit_name, key)
			_units[key].append(unit)


func _on_SignalBus_commander_died(team: String) -> void:
	if team == Constants.TEAM_ALLY:
		print("You Lost, Game Over!")
	elif team == Constants.TEAM_ENEMY:
		print("You Won, Congratulations!")
	get_tree().paused = true

class_name StageCombat extends BaseStage
## Stage where the combat takes place. Handles creation of the map, units etc.

@onready var _ally_spawner_col_shape : CollisionShape2D = $AllySpawner/CollisionShape2D
@onready var _enemy_spawner_col_shape : CollisionShape2D = $EnemySpawner/CollisionShape2D

var _units : Dictionary = {"ally":[], "enemy": []}  ## Dict[String, Array[Unit]]

func _ready() -> void:
	_get_units_from_troupe()
	_place_units()
	_spawn_actors()


## load units from the troupes involved in the combat
func _get_units_from_troupe() -> void:
	# FIXME: when troupes exist update to use troupe. placeholder code for now.

	for key in _units.keys():
		var num_unit_per_team = 5
		var unit_name: String
		if key == "ally":
			unit_name = "conjurer"
		else:
			unit_name = "copper_golem"

		for i in range(num_unit_per_team):
			var unit = Factory.create_unit(self, unit_name, key)
			_units[key].append(unit)


## place units on the map in their spawners
func _place_units() -> void:
	for unit in _get_all_units():
		assert(unit is Unit)

		var spawner : CollisionShape2D
		if unit.team == "ally":
			spawner = _ally_spawner_col_shape
		else:
			spawner = _enemy_spawner_col_shape

		var spawner_width : float = spawner.shape.get_rect().size.x
		var width_margin : float = spawner_width * 0.1
		var spawner_height : float = spawner.shape.get_rect().size.y
		var height_margin : float = spawner_height * 0.1

		# get an offset amount that is within an inner margin of the edges
		var x_offset = randi_range(width_margin, spawner_width - width_margin)
		var y_offset = randi_range(height_margin, spawner_height - height_margin)
		unit.position.x = spawner.position.x + x_offset
		unit.position.y = spawner.position.y + y_offset


## spawn all actors for all units
func _spawn_actors() -> void:
	for unit in _get_all_units():
		unit.spawn_actors()

## returns all units as a single array
##
## Array[Unit]
func _get_all_units() -> Array:  # N.B. adding type hint to the array errors
	var all_units = []

	for team in _units:
		for unit in _units[team]:
			all_units.append(unit)

	return all_units

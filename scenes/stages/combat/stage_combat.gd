class_name StageCombat extends BaseStage
## Stage where the combat takes place. Handles creation of the map, units etc.

@onready var _ally_spawner_col_shape : CollisionShape2D = $AllySpawner/CollisionShape2D
@onready var _enemy_spawner_col_shape : CollisionShape2D = $EnemySpawner/CollisionShape2D

var _units : Dictionary = {Constants.TEAM_ALLY:[], Constants.TEAM_ENEMY: []}  ## Dict[String, Array[Unit]]

func _ready() -> void:
	_get_units_from_troupe()
	_place_units()
	_spawn_actors()


## load units from the troupes involved in the combat
func _get_units_from_troupe() -> void:
	# FIXME: when troupes exist update to use troupe. placeholder code for now.
	
	var unit_choices : Dictionary = {
		Constants.TEAM_ALLY: {"conjurer":3, "poet":2},
		Constants.TEAM_ENEMY: {"copper_golem":5}
	}
	for key in _units.keys():
		for unit_name in unit_choices[key]:
			var amount := unit_choices[key][unit_name] as int
			for _index in amount:
				var unit = Factory.create_unit(self, unit_name, key)
				unit.set_name(unit_name.to_pascal_case() + "_Unit")
				_units[key].append(unit)


## place units on the map in their spawners
func _place_units() -> void:
	for unit in _get_all_units():
		assert(unit is Unit)

		var spawner : CollisionShape2D
		if unit.team == Constants.TEAM_ALLY:
			spawner = _ally_spawner_col_shape
		else:
			spawner = _enemy_spawner_col_shape

		# get area info
		var spawner_rect : Rect2 = spawner.shape.get_rect()
		var spawner_width : float = spawner_rect.size.x
		var width_margin : float = spawner_width * 0.1
		var spawner_height : float = spawner_rect.size.y
		var height_margin : float = spawner_height * 0.1

		# offset by pos relative to parent to get origin
		var spawner_x : float = spawner.global_position.x - abs(spawner_rect.position.x)
		var spawner_y : float = spawner.global_position.y  - abs(spawner_rect.position.y)

		# get an offset amount that is within an inner margin of the edges
		var x_offset = randi_range(int(width_margin), int(spawner_width - width_margin))
		var y_offset = randi_range(int(height_margin), int(spawner_height - height_margin))

		# determine min, max and placement
		var x_pos = spawner_x + x_offset
		var x_min = spawner_x + width_margin
		var x_max = spawner_x + (spawner_width - width_margin)
		var y_pos = spawner_y + y_offset
		var y_min = spawner_y + height_margin
		var y_max = spawner_y + (spawner_height - height_margin)

		# set pos
		unit.global_position.x = clamp(x_pos, x_min, x_max)
		unit.global_position.y = clamp(y_pos, y_min, y_max)


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

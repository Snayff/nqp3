extends BaseStateUnit

const SEARCH_AGAIN_DELAY = 1.0
const MAX_TARGET_RANGE = INF

var _target_group := ""

## actions on entering state
func enter_state() -> void:
	_target_group = "%s_unit"%[Constants.TEAM_ENEMY]
	if _creator.team == Constants.TEAM_ENEMY:
		_target_group = "%s_unit"%[Constants.TEAM_ALLY]
	_select_target_unit()


## actions on exiting state
func exit_state() -> void:
	pass


func _select_target_unit() -> void:
	var enemy_units := get_tree().get_nodes_in_group(_target_group)
	var friendly_units := get_tree().get_nodes_in_group("%s_unit"%[_creator.team])
	var already_targeted: Array[Unit] = _get_units_already_targeted_by(friendly_units)
	
	var free_enemy_units := enemy_units.filter(_get_free_enemy_unit.bind(already_targeted))
	var target_pool: Array[Unit] = _choose_target_pool(free_enemy_units, enemy_units)
	
	_creator.target_unit = _get_closest_unit_from(target_pool)
	if _creator.target_unit != null:
		for actor in _creator._actors:
			actor.targeted_unit = _creator.target_unit
		_creator.target_unit.unit_defeated.connect(_on_target_unit_defeated)
	else:
		get_tree().create_timer(SEARCH_AGAIN_DELAY).timeout.connect(
				_select_target_unit, 
				CONNECT_ONE_SHOT
		)


func _get_units_already_targeted_by(friendly_units: Array) -> Array[Unit]:
	var value: Array[Unit] = []
	for unit in friendly_units:
		unit = unit as Unit
		if is_instance_valid(unit.target_unit) and unit.is_in_group("alive_unit"):
			value.append(unit.target_unit)
	return value


func _get_free_enemy_unit(unit: Unit, already_targeted: Array[Unit]) -> bool:
	return not unit in already_targeted and unit.is_in_group("alive_unit")


func _choose_target_pool(free_enemy_units: Array, all_enemy_units: Array) -> Array[Unit]:
	var value: Array[Unit] = []
	
	if free_enemy_units.is_empty():
		value.assign(all_enemy_units)
	else:
		value.assign(free_enemy_units)
	
	return value


func _get_closest_unit_from(target_pool: Array[Unit]) -> Unit:
	var value: Unit = null
	var min_distance := MAX_TARGET_RANGE
	for unit in target_pool:
		if unit.is_in_group("dead_unit"):
			continue
		
		var new_distance := _creator.global_position.distance_squared_to(unit.global_position)
		if new_distance < min_distance:
			min_distance = new_distance
			value = unit
	return value


func _on_target_unit_defeated() -> void:
	_select_target_unit()

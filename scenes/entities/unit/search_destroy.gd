extends BaseStateUnit

## actions on entering state
func enter_state() -> void:
	await get_tree().create_timer(2).timeout
	var target_group := "%s_unit"%[Constants.TEAM_ENEMY]
	if _creator.team == Constants.TEAM_ENEMY:
		target_group = "%s_unit"%[Constants.TEAM_ALLY]
	
	var enemy_units := get_tree().get_nodes_in_group(target_group)
	var friendly_units := get_tree().get_nodes_in_group("%s_unit"%[_creator.team])
	var already_targeted: Array[Unit] = []
	for unit in friendly_units:
		unit = unit as Unit
		if is_instance_valid(unit.target_unit) and unit.is_in_group("alive_unit"):
			already_targeted.append(unit.target_unit)
	
	var free_enemy_units := enemy_units.filter(_get_free_enemy_unit.bind(already_targeted))
	var target_pool: Array[Unit] = []
	if free_enemy_units.is_empty():
		target_pool.assign(enemy_units)
	else:
		target_pool.assign(free_enemy_units)
	
	_creator.target_unit = _get_closest_unit_from(target_pool)


func physics_process(delta: float) -> void:
	pass


## take action based on current state
func update_state() -> void:
	pass


## actions on exiting state
func exit_state() -> void:
	pass


func _get_free_enemy_unit(unit: Unit, already_targeted: Array[Unit]) -> bool:
	return not unit in already_targeted


func _get_closest_unit_from(target_pool: Array[Unit]) -> Unit:
	var value: Unit = null
	var min_distance := INF
	for unit in target_pool:
		if unit.is_in_group("dead_unit"):
			continue
		
		var new_distance := _creator.global_position.distance_squared_to(unit.global_position)
		if new_distance < min_distance:
			min_distance = new_distance
			value = unit
	return value

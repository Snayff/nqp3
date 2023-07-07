class_name WandBlast extends BaseAction


func _configure() -> void:
	friendly_name = "Wand Blast"
	tags = [Constants.ActionTag.DAMAGE]
	valid_target_types = [Constants.TargetType.ENEMY]
	_base_cooldown = 1
	_base_stamina_cost = 5
	_base_damage = 10
	_base_damage_type = Constants.DamageType.MUNDANE
	_base_cast_time = 1
	_base_range = 300


func use(initial_target: Actor) -> void:
	super(initial_target)

	var apply_damage = true

	if not _creator.is_melee:
		var projectile = _effect_projectile()

		# wait for projectile to hit and then update target to Actor hit
		var result : Array = await projectile.expired
		var hit_target : bool =  result[0]

		if hit_target:
			_target = result[1]
		else:
			apply_damage = false

	if apply_damage:
		_effect_damage(_base_damage + _creator.stats.attack, _base_damage_type)


func get_description() -> String:
	return "Attack with sword, staff or the nearest big rock."  # TODO: add damage

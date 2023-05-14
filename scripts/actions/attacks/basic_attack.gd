class_name BasicAttack extends BaseAction

func _configure() -> void:
	friendly_name = "Attack"
	tags = [Constants.ActionTag.DAMAGE]
	valid_target_types = [Constants.TargetType.ENEMY]
	_base_cooldown = 5

func use(initial_target: Actor) -> void:
	super(initial_target)

	var list = await Utility.get_targets_in_area(initial_target.global_position, 10)

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
		_effect_damage(_creator.stats.attack, _creator.stats.damage_type)

func get_description() -> String:
	return "Attack with sword, staff or the nearest big rock."  # TODO: add damage

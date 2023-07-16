class_name Smash extends BaseAction


func _configure() -> void:
	friendly_name = "smash"
	tags = [Constants.ActionTag.DAMAGE]
	valid_target_types = [Constants.TargetType.ENEMY]
	_base_cooldown = 1
	_base_stamina_cost = 5
	_base_damage = 10
	_base_damage_type = Constants.DamageType.MUNDANE
	_base_cast_time = 1
	_base_range = Constants.MELEE_RANGE


func use(initial_target: Actor) -> void:
	super(initial_target)

	_effect_damage(_base_damage + _creator.stats.attack, _base_damage_type)


func get_description() -> String:
	return "Attack with sword, staff or the nearest big rock."  # TODO: add damage

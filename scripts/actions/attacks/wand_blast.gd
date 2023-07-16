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
	_base_range = 100


func use(initial_target: Actor) -> void:
	super(initial_target)

	if not _creator.is_melee:
		var projectile = _effect_projectile(_get_projectile_data())
		projectile.launch()

	else:
		apply_damage()


func _get_projectile_data() -> ProjectileData:
	var data = ProjectileData.new(_creator)
	data.speed = 50
	data.lifetime = 3.0
	data.target = _target
	data.on_hit_func = apply_damage
	data.sprite_name = "chaos"

	return data


func apply_damage() -> void:
	_effect_damage(_base_damage + _creator.stats.attack, _base_damage_type)

func get_description() -> String:
	return "Attack with sword, staff or the nearest big rock."  # TODO: add damage

class_name WandBlast extends BaseAction


func _configure() -> void:
	friendly_name = "Wand Blast"
	tags = [Constants.ActionTag.DAMAGE]
	target_type = Constants.TargetType.ENEMY
	target_preferences = [Constants.TargetPreference.NEAREST]
	_base_cooldown = 1
	_base_stamina_cost = 5
	_base_damage = 10
	_base_damage_type = Constants.DamageType.MUNDANE
	_base_cast_time = 1
	_base_range = 100


func use(initial_target: Actor, optional_parameters := {}) -> void:
	super(initial_target)

	if not _creator.is_melee:
		var projectile = _effect_projectile(_get_projectile_data())
		projectile.launch()

	else:
		apply_damage()


func _get_projectile_data() -> ProjectileData:
	var data = ProjectileData.new(_creator)
	data.speed = 100
	data.lifetime = 3.0
	data.target = _target
	data.on_hit_func = apply_damage
	data.sprite_name = "chaos"
	data.is_homing = true
	data.has_trail = true
	data.trail_colour = Color(0.67, 0.06, 0.47, 1.0)
	data.trail_lifetime = 0.5

	return data


func apply_damage() -> void:
	_effect_damage(_base_damage + _creator.stats.attack, _base_damage_type)

func get_description() -> String:
	return "Attack with sword, staff or the nearest big rock."  # TODO: add damage

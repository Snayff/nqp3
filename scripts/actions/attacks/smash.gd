class_name Smash extends BaseAction


func _configure() -> void:
	friendly_name = "smash"
	tags = [Constants.ActionTag.DAMAGE]
	target_type = Constants.TargetType.ENEMY
	target_preferences = [Constants.TargetPreference.NEAREST]
	_base_cooldown = 1
	_base_stamina_cost = 5
	_base_damage = 10
	_base_damage_type = Constants.DamageType.MUNDANE
	_base_cast_time = 1
	_base_range = Constants.MELEE_RANGE


func use(initial_target: Actor) -> void:
	super(initial_target)

	var sparkles = Factory.create_sparkles(_get_sparkles_data())
	_creator.add_child(sparkles)

	_effect_damage(_base_damage + _creator.stats.attack, _base_damage_type)

func _get_sparkles_data() -> SparklesData:
	var data = SparklesData.new()
	data.duration = 0.5
	data.sparkle_colour = Color(0.467, 0.373, 0.161)
	data.sparkle_duration = 0.2
	data.sparkle_size = 1
	data.explosiveness = 0.8
	data.radius = 16
	data.is_following_parent = false


	return data


func get_description() -> String:
	return "Attack with sword, staff or the nearest big rock."  # TODO: add damage

class_name Poison extends BaseStatusEffect

func _configure() -> void:
	friendly_name = "Attack"
	tags = [Constants.ActionTag.DAMAGE]
	valid_target_types = [Constants.TargetType.ANY]
	_base_cooldown = 1
	_base_duration = 10
	_base_damage = 1
	_base_damage_type = Constants.DamageType.MUNDANE


func use(initial_target: Actor) -> void:
	super(initial_target)

	_effect_damage(_base_damage, _base_damage_type)


func get_description() -> String:
	return "Blighted to the point of sickness."

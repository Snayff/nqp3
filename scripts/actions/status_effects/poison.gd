class_name Poison extends BaseStatusEffect

func _configure() -> void:
	friendly_name = "Poison"
	tags = [Constants.ActionTag.STATUS_EFFECT, Constants.ActionTag.DAMAGE]
	valid_target_types = [Constants.TargetType.ANY]
	_base_cooldown = 1
	_base_duration = 2
	_base_damage = 1
	_base_damage_type = Constants.DamageType.MUNDANE
	var weaken = StatModifier.new("attack", Constants.StatModType.ADD, -10)
	stat_modifiers.append(weaken)


func use(initial_target: Actor) -> void:
	super(initial_target)

	_effect_damage(_base_damage, _base_damage_type)


func get_description() -> String:
	return "Blighted to the point of sickness. Deals damage over time and reduces attack."

class_name Exhaustion extends BaseStatusEffect

func _configure() -> void:
	friendly_name = "Exhaustion"
	tags = [Constants.ActionTag.STATUS_EFFECT, Constants.ActionTag.STAT_MOD]
	target_type = Constants.TargetType.ANY
	_base_duration = INF

	# significantly reduce stats
	var stat_mod = StatModifier.new("attack", Constants.StatModType.MULTIPLY, -50)
	stat_modifiers.append(stat_mod)

	stat_mod = StatModifier.new("dodge", Constants.StatModType.MULTIPLY, -50)
	stat_modifiers.append(stat_mod)

	stat_mod = StatModifier.new("magic_defence", Constants.StatModType.MULTIPLY, -50)
	stat_modifiers.append(stat_mod)

	stat_mod = StatModifier.new("mundane_defence", Constants.StatModType.MULTIPLY, -50)
	stat_modifiers.append(stat_mod)#

	stat_mod = StatModifier.new("attack_speed", Constants.StatModType.MULTIPLY, -50)
	stat_modifiers.append(stat_mod)

	stat_mod = StatModifier.new("move_speed", Constants.StatModType.MULTIPLY, -50)
	stat_modifiers.append(stat_mod)


func use(initial_target: Actor, optional_parameters := {}) -> void:
	super(initial_target)

	# no further action beyond stat mod


func get_description() -> String:
	return "One can only fight for so long."

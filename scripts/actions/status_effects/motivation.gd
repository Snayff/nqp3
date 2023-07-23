class_name Motivation extends BaseStatusEffect


func _configure() -> void:
	friendly_name = "Motivation"
	action_type = Constants.ActionType.STATUS_EFFECT
	tags = [Constants.ActionTag.STATUS_EFFECT, Constants.ActionTag.STAT_MOD]

	target_type = Constants.TargetType.ANY

	# status effect attrs
	_base_duration = 1.5  # less than cooldown, so only applied once
	stat_modifiers = []

	var move_speed_boost = StatModifier.new("move_speed", Constants.StatModType.ADD, 100)
	stat_modifiers.append(move_speed_boost)


# called everytime duration == 0
func use(initial_target: Actor) -> void:
	super(initial_target)


func get_description() -> String:
	return "So motivated to get to where they're going."


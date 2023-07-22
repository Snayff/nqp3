extends BaseStatusEffect

# meta-name: Status Effect
# meta-description: Special type of action, that applies effect over a duration.
# meta-default: true

func _configure() -> void:
	friendly_name = ""
	action_type = Constants.ActionType.STATUS_EFFECT
	tags = [Constants.ActionTag]

	target_type = Constants.TargetType

	_base_cooldown = 0.0
	_base_damage = 0
	_base_damage_type = Constants.DamageType

	# status effect attrs
	_base_duration = 0
	stat_modifiers = []


# called everytime cooldown == 0
func use(initial_target: Actor) -> void:
	super(initial_target)


func get_description() -> String:
	return ""

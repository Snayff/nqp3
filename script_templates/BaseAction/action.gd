extends BaseAction

# meta-name: Action
# meta-description: Actor's action, such as an attack or reaction.
# meta-default: true

func _configure() -> void:
	friendly_name = ""
	trigger = Constants.ActionTrigger.ATTACK
	action_type = Constants.ActionType.ATTACK
	tags = [Constants.ActionTag]

	target_selection  = Constants.ActionTargetSelection.ACTOR
	target_type = Constants.TargetType
	target_preferences = [Constants.TargetPreference]

	_base_cooldown = 0.0
	_base_stamina_cost = 0
	_base_damage = 0
	_base_damage_type = Constants.DamageType
	_base_cast_time = 0
	_base_range = 0.0 # or Constants.MELEE_RANGE


func use(initial_target: Actor) -> void:
	super(initial_target)


func get_description() -> String:
	return ""

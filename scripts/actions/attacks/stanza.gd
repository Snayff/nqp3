class_name Stanza extends BaseAction


func _configure() -> void:
	friendly_name = "Stanza"
	trigger = Constants.ActionTrigger.ATTACK
	action_type = Constants.ActionType.ATTACK
	tags = [Constants.ActionTag.STATUS_EFFECT]

	target_selection  = Constants.ActionTargetSelection.GROUND
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

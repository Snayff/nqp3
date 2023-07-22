class_name Stanza extends BaseAction


func _configure() -> void:
	friendly_name = "Stanza"
	trigger = Constants.ActionTrigger.ATTACK
	action_type = Constants.ActionType.ATTACK
	tags = [Constants.ActionTag.STATUS_EFFECT]

	target_selection  = Constants.ActionTargetSelection.GROUND
	target_type = Constants.TargetType
	target_preferences = [Constants.TargetPreference]

	_base_cooldown = 4.0
	_base_stamina_cost = 20
	_base_damage = 0
	_base_damage_type = Constants.DamageType.MAGIC
	_base_cast_time = 0.5
	_base_range = 40.0


func use(initial_target: Actor) -> void:
	super(initial_target)

	var target_finder = Factory.create_target_finder(true, Color(0.51, 0.094, 0))



func get_description() -> String:
	return ""

class_name Stanza extends BaseAction


func _configure() -> void:
	friendly_name = "Stanza"
	trigger = Constants.ActionTrigger.ATTACK
	action_type = Constants.ActionType.ATTACK
	tags = [Constants.ActionTag.STATUS_EFFECT]

	target_selection  = Constants.ActionTargetSelection.SELF
	target_type = Constants.TargetType.ALLY
	target_preferences = [Constants.TargetPreference.ANY]

	_base_cooldown = 4.0
	_base_stamina_cost = 20
	_base_damage = 0
	_base_damage_type = Constants.DamageType.MAGIC
	_base_cast_time = 0.5
	_base_range = 400.0


func use(initial_target: Actor) -> void:
	super(initial_target)

	# get all targets in range

	var target_finder = Factory.add_target_finder(_creator, range, true, Color(0.51, 0.094, 0))
	#_creator.add_child(target_finder)
	var targets : Array = await target_finder.get_actors_in_range(true)

#
#	var targets : Array[Actor] = Utility.get_actors_in_area(_creator.global_position, range)
#	var c = Node2D.new()
#	_creator.add_child(c)
#	c.draw_arc(Vector2.ZERO, range, 0, 360, 32, Color(0.51, 0.094, 0))

	# find allies
	var target_group : String = Utility.get_target_group(_creator, target_type)
	for target_ in targets:
		if target_.is_in_group(target_group):

			# apply status effect
			_effect_status("motivation")







func get_description() -> String:
	return "Even but a stanza can encourage a mountain to move."

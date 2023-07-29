class_name Heal extends BaseAction
## restore health

func _configure() -> void:
	friendly_name = "Heal"
	tags = [Constants.ActionTag.HEAL]
	target_type = Constants.TargetType.ALLY
	target_preferences = [Constants.TargetPreference.DAMAGED, Constants.TargetPreference.LOWEST_HEALTH]
	_base_cooldown = 2
	_base_stamina_cost = 50
	_base_cast_time = 2
	_base_range = 100


func use(initial_target: Actor) -> void:
	super(initial_target)

	var visual = Factory.create_simple_animation("heal")
	visual.animation_finished.connect(visual.queue_free)
	initial_target.add_child(visual)

	_effect_heal(_base_damage + _creator.stats.attack)


func get_description() -> String:
	return "Restore health to lowest health, damaged ally."  # TODO: add amount

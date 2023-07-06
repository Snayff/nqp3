class_name SpikyShell extends BaseAction

func _configure() -> void:
	friendly_name = "Spiky Shell"
	tags = [Constants.ActionTag.DAMAGE]
	valid_target_types = [Constants.TargetType.ATTACKER]
	_base_cooldown = 0
	_base_damage = 5
	_base_stamina_cost = 0


func use(initial_target: Actor) -> void:
	super(initial_target)

	_effect_damage(_base_damage + (_creator.stats.mundane_defence * 0.1) , Constants.DamageType.MUNDANE)


func get_description() -> String:
	return "So unfriendly that engaging with them genuinely hurts."


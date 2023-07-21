extends Node
## Combat functionality.

## allocate damage and signal interactions
func deal_damage(attacker: Actor, defender: Actor, damage: int, damage_type: Constants.DamageType) -> void:
	attacker.emit_signal("dealt_damage", [damage, damage_type])

	defender.stats.health -= damage
	defender.emit_signal("took_damage", [damage, damage_type])
	defender.emit_signal("hit_received", attacker)

	# debug gubbins
	var team : String = ""
	if attacker.is_in_group("team1"):
		team = "team1"
	else:
		team = "team2"

	var team2 : String = ""
	if defender.is_in_group("team1"):
		team2 = "team1"
	else:
		team2 = "team2"

	print(attacker.debug_name + " dealt " + str(damage) + " to " + defender.debug_name + ". Remaining health is " + str(defender.stats.health) + ".")


## work out damage of an attack on a defender
func calculate_damage(attacker: Actor, defender: Actor, damage: int, damage_type: Constants.DamageType) -> int:
	# polynomial / exponential example:  ax^2 + bx + c, with a, b, and c being constants.
	# e.g. (((strength) ^ 3 ÷ 32) + 32) x damage_multiplier
	# damage multiplier would be set by the attack in question
	#
	# linear example: (a + b - c) * e
	# e.g. (attacker_attack * damage_multiplier - defender_defence) * weakness_multiplier

	var reduced_damage = _reduce_damage_by_defence(damage, defender, damage_type)

	return reduced_damage


## offset base damage by defence stats
## min 1
func _reduce_damage_by_defence(base_damage: int, defender: Actor, damage_type: Constants.DamageType) -> int:
	var defence : int = 0
	if damage_type == Constants.DamageType.MUNDANE:
		defence = defender.stats.mundane_defence
	else:
		defence = defender.stats.magic_defence

	return max(base_damage - defence, 1)


## reduce an actor's stamina
func reduce_stamina(target: Actor, amount: int) -> void:
	target.stats.stamina -= min(amount, 0)


## instantly kill actor
func kill(attacker: Actor, target: Actor) -> void:
	print(attacker.debug_name + " instantly killed " + target.debug_name )
	target.die()


## restore health and signal interactions
func heal(healer: Actor, target: Actor, heal_amount: int) -> void:
	healer.emit_signal("healed_someone", heal_amount)

	var max_heal = 0
	if target.stats.max_health - target.stats.health > heal_amount:
		max_heal = heal_amount
	else:
		max_heal = max(0, target.stats.max_health - target.stats.health)

	target.stats.health += max_heal
	target.emit_signal("was_healed", heal_amount)

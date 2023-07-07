extends Node
## Combat functionality.

## calculate and resolve damage allocation
func deal_damage(attacker: Actor, defender: Actor, initial_damage: int, damage_type: Constants.DamageType) -> void:
	# polynomial / exponential example:  ax^2 + bx + c, with a, b, and c being constants.
	# e.g. (((strength) ^ 3 ÷ 32) + 32) x damage_multiplier
	# damage multiplier would be set by the attack in question
	#
	# linear example: (a + b - c) * e
	# e.g. (attacker_attack * damage_multiplier - defender_defence) * weakness_multiplier

	var damage = calculate_damage(attacker, defender, initial_damage, damage_type)
	attacker.emit_signal("dealt_damage", [damage, damage_type])

	defender.stats.health -= damage
	defender.emit_signal("took_damage", [damage, damage_type])
	defender.emit_signal("hit_received", attacker)

	# debug gubbins
	var team : String = ""
	if attacker.is_in_group("ally"):
		team = "ally"
	else:
		team = "enemy"

	var team2 : String = ""
	if defender.is_in_group("ally"):
		team2 = "ally"
	else:
		team2 = "enemy"

	#print(attacker.name + "(" + team  + ") dealt " + str(damage) + " to " + defender.name + "(" + team2 + ").")


## work out damage of an attack on a defender
func calculate_damage(attacker: Actor, defender: Actor, damage: int, damage_type: Constants.DamageType) -> int:
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

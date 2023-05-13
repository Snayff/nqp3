class_name ActorStats extends Resource

# signals
## Emitted when a character has no `health` left.
signal health_depleted
## Emitted every time the value of `health` changes.
signal health_changed(old_value, new_value)

var _modifiers := {}

# defence stats
@export_group("Defence")
@export var max_health: int
@export var health: int:
	set(value):
		var previous_health := health
		health = clamp(value, 0, max_health)
		emit_signal("health_changed", previous_health, health)

		# inform of death
		if health == 0:
			emit_signal("health_depleted")
@export var base_regen: int:
	set(value):
		base_regen = value
		_recalculate("regen")
@export var regen: int
@export var base_dodge: int:
	set(value):
		base_dodge = value
		_recalculate("dodge")
@export var dodge: int
@export var base_magic_defence: int:
	set(value):
		base_magic_defence = value
		_recalculate("magic_defence")
@export var magic_defence: int
@export var base_mundane_defence: int:
	set(value):
		base_mundane_defence = value
		_recalculate("mundane_defense")
@export var mundane_defence: int

# attack stats
@export_group("Offence")
@export var base_attack: int:
	set(value):
		base_attack = value
		_recalculate("attack")
@export var attack: int
@export var base_attack_speed: float:
	set(value):
		base_attack_speed = value
		_recalculate("attack_speed")
@export var attack_speed: float
@export var base_crit_chance: int:
	set(value):
		base_crit_chance = value
		_recalculate("crit_chance")
@export var crit_chance: int
@export var damage_type: Constants.DamageType
@export var base_penetration: int:
	set(value):
		base_penetration = value
		_recalculate("penetration")
@export var penetration: int

# misc stats
@export_group("Misc Combat")
@export var base_attack_range: int:
	set(value):
		base_attack_range = value
		_recalculate("attack_range")
@export var attack_range: int
@export var base_move_speed: int:
	set(value):
		base_move_speed = value
		_recalculate("move_speed")
@export var move_speed: int
@export var base_count: int:
	set(value):
		base_count = value
		_recalculate("num_units")
@export var num_units: int

# non-combat
@export_group("Non Combat")
@export var base_gold_cost: int:
	set(value):
		base_gold_cost = value
		_recalculate("gold_cost")
@export var gold_cost: int
@export var tier: int
@export var faction: String


const MODIFIABLE_STATS = [
	"max_health",
	"regen",
	"dodge",
	"magic_defence",
	"mundane_defence",
	"attack",
	"crit_chance",
	"attack_speed",
	"penetration",
	"attack_range",
	"move_speed",
	"count"

]

func _init() -> void:
	# create dict for each state to hold stat modifiers
	for stat in MODIFIABLE_STATS:
		_modifiers[stat] = {}

## rerun _init() and reset to base values
func reinit() -> void:
	_init()
	health = max_health

## recalculate a given stat, using the base value and any modifiers
func _recalculate(stat_name: String) -> void:
	var value: float = get("base_" + stat_name)

	# get the array of modifiers corresponding to a stat.
	var modifiers: Array = _modifiers[stat_name].values()
	var mod_multiplier : float = 1.0
	for modifier in modifiers:
		if modifier["type"] == Constants.StatModType.ADD:
			value += modifier["value"]
		elif modifier["type"] == Constants.StatModType.MULTIPLY:
			mod_multiplier += modifier["value"]

	# apply multiplier
	value *= mod_multiplier

	# prevent negative values
	value = max(value, 0.0)

	set(stat_name, value)

## Adds a modifier to a stat and returns id.
func add_modifier(stat_name: String, mod_type: Constants.StatModType, value: float) -> int:
	assert(stat_name in MODIFIABLE_STATS, "Trying to add a modifier to a nonexistent stat.")

	var id := Utility.generate_id()
	_modifiers[stat_name][id] = {"type": mod_type, "value": value}

	_recalculate(stat_name)

	return id

## Removes a modifier from stat.
func remove_modifier(stat_name: String, id: int) -> void:
	assert(id in _modifiers[stat_name], "Id " + str(id) + " not found in " + str(_modifiers[stat_name]))

	_modifiers[stat_name].erase(id)
	_recalculate(stat_name)

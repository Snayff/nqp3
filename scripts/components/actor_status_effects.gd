class_name ActorStatusEffects extends Node
## data and functionality for status effects for a single actor

## status effect logged on actor
signal status_effect_added
## status effect affected actor
signal status_effect_applied
## status effect removed
signal status_effect_removed
## an actors stat is to be modified
signal stat_modifier_added(stat_modifier: StatModifier)
## a stat modifier is to be removed
signal stat_modifier_removed(uid)

var _effects : Dictionary = {}  ## Dict[int, BaseStatusEffect]   {uid, BaseStatusEffect}

## add status effect to actor
func add_status_effect(status_effect: BaseStatusEffect) -> void:
	# dont add more than 1 of same status effect
	if _has_effect_already(status_effect):
		return

	_effects[status_effect.uid] = status_effect

	# signal for  all stat mods, to be picked up in Actor
	for stat_mod in status_effect.stat_modifiers:
		emit_signal("stat_modifier_added", stat_mod)

	# inform of addition
	emit_signal("status_effect_added")


## remove a status effect by its uid
func remove_status_effect(uid: int) -> void:
	if not uid in _effects:
		push_warning("Tried to remove status effect (" + str(uid) + ") that doesnt exist.")

	# signal for any stat mods to remove, picked up in actor
	for stat_mod in _effects[uid].stats_modified:
		emit_signal("stat_modifier_removed", stat_mod.stat_name, stat_mod.uid)

	# del status effect
	_effects.erase(uid)

	# inform of removal
	emit_signal("status_effect_removed")


## confirm if a status effect of same type already exists on actor
func _has_effect_already(status_effect: BaseStatusEffect) -> bool:
	for effect in _effects.values():
		if status_effect.friendly_name == effect.friendly_name:
			return true
	return false

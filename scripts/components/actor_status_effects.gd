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
		status_effect.destroy()
		return
	
	_effects[status_effect.uid] = status_effect
	print(status_effect.friendly_name + " added to " + get_parent().debug_name + ".")
	
	# signal for  all stat mods, to be picked up in Actor
	for stat_mod in status_effect.stat_modifiers:
		emit_signal("stat_modifier_added", stat_mod)
	
	status_effect.expired.connect(remove_status_effect.bind(status_effect.uid))
	
	# inform of addition
	emit_signal("status_effect_added")


## remove a status effect by its uid
func remove_status_effect(uid: int) -> void:
	if not uid in _effects:
		push_warning("Tried to remove status effect (" + str(uid) + ") that doesnt exist.")
	
	_trigger_stat_mod_removal(uid)
	
	var status_effect := _effects[uid] as BaseStatusEffect
	# del status effect
	_effects.erase(uid)
	
	status_effect.destroy()
	
	# inform of removal
	emit_signal("status_effect_removed")


## remove status effect by type
func remove_status_effect_by_type(status_effect: BaseStatusEffect) -> void:
	# loop all effects to find match
	# dont bother looking for match with has_effect as this is just doing the same thing
	for uid in _effects:
		if _effects[uid].friendly_name == status_effect.friendly_name:
			_trigger_stat_mod_removal(uid)

			# del status effect
			_effects.erase(uid)

			# inform of removal
			emit_signal("status_effect_removed")

			# break early as only 1 of each status can exist on actor
			return


func clear_all_status_effects() -> void:
	var uid_list := _effects.keys()
	for uid in uid_list:
		remove_status_effect(uid)


## confirm if a status effect of same type already exists on actor
func _has_effect_already(status_effect: BaseStatusEffect) -> bool:
	for effect in _effects.values():
		if status_effect.friendly_name == effect.friendly_name:
			return true
	return false


# signal for any stat mods in an effect to be removed
##
## picked up in actor
func _trigger_stat_mod_removal(uid: int) -> void:
	for stat_mod in _effects[uid].stat_modifiers:
		emit_signal("stat_modifier_removed", stat_mod.stat_name, stat_mod.uid)

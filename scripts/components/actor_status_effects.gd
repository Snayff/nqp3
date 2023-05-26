class_name ActorStatusEffects extends Node
## data and functionality for status effects for a single actor

## status effect logged on actor
signal status_effect_added
## status effect affected actor
signal status_effect_applied
## status effect removed
signal status_effect_removed

var _effects : Dictionary = {}  ## {uid, BaseStatusEffect}

## add status effect to actor
func add_status_effect(status_effect: BaseStatusEffect) -> void:
	_effects[status_effect.uid] = status_effect

	emit_signal("status_effect_added")


## remove a status effect by its uid
func remove_status_effect(uid: int) -> void:
	if not uid in _effects:
		push_warning("Tried to remove status effect (" + str(uid) + ") that doesnt exist.")

	_effects.erase(uid)

	emit_signal("status_effect_removed")

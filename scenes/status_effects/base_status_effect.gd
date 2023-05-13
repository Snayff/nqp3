class_name BaseStatusEffect extends Node
## ABC for status effects

# Emitted when the effect expires.
signal expired

var duration : float = 4.0
var _target : Actor

func _init(target: Actor) -> void:
	_target = target


func _ready() -> void:
	_post_ready()

## Add the node to the tree, apply the bonu, start the effect's countdown using a timer.
##
## called in post_ready to make it overridable
func _post_ready() -> void:
	# example:
	# var id: int = _target.stats.add_modifier("attack", attack_bonus)
	# var timer := get_tree().create_timer(duration)
	# we bind the `id` to the signal's callback to later remove the stat boost.
	# timer.connect("timeout", self, "_on_Timer_timeout", [id])

	assert(false, "_post_ready not overriden.")

	pass

# When the timer ends, we remove the modifier.
func _on_Timer_timeout(id: int) -> void:
	# example:
	# _target.stats.remove_modifier("attack", id)
	# emit_signal("expired")
	# queue_free()

	assert(false, "_on_Timer_timeout not overriden.")

	pass

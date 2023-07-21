extends Label

func _process(delta: float) -> void:
	var parent = get_parent()
	var state = Constants.ActorState.keys()[parent._state]
	var anim = parent.animated_sprite.animation
	var target = ""
	if parent._target:
		target = parent._target
	set_text("State: " + str(state) + "\n Anim: " + anim + "\n Target: "  + str(target.uid))

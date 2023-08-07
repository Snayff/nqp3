extends Label

func _process(_delta: float) -> void:
	var parent = get_parent()
	var state = Constants.ActorState.keys()[parent._state]
	var anim = parent.animated_sprite.animation
	var target = parent._target
	if target == null:
		set_text("State: " + str(state) + "\n Anim: " + anim + "\n Target: ")
	else:
		set_text("State: " + str(state) + "\n Anim: " + anim + "\n Target: "  + str(target.uid))

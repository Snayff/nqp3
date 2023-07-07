extends Label

func _process(delta: float) -> void:
	var parent = get_parent()
	var state = Constants.ActorState.keys()[parent._state]
	var anim = parent.animated_sprite.animation
	set_text("State: " + str(state) + "\n Anim: " + anim)

extends BaseState


## actions on entering state
func enter_state():
	_creator.animated_sprite.play("idle")



func physics_process(_delta):
	pass


## take action based on current state
func update_state():
	pass


## actions on exiting state
func exit_state():
	pass


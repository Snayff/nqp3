extends BaseState


## actions on entering state
func enter_state() -> void:
	if _creator._target == null:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)
		return
	
	_creator.animated_sprite.animation_looped.connect(_on_animated_sprite_animation_looped)
	_creator.animated_sprite.play("attack")


func physics_process(delta: float) -> void:
	pass


## take action based on current state
func update_state() -> void:
	if _creator._target == null:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)


## actions on exiting state
func exit_state() -> void:
	_creator.animated_sprite.animation_looped.disconnect(_on_animated_sprite_animation_looped)


func _on_animated_sprite_animation_looped() -> void:
	if _creator._target == null:
		_creator.state_machine.change_state(Constants.ActorState.IDLING)
		return
	
	_creator.attack()
	_creator.state_machine.change_state(Constants.ActorState.IDLING)

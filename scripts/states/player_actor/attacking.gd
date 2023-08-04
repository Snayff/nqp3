extends BasePlayerState


## actions on entering state
func enter_state() -> void:
	if _get_current_target() == null:
		_player.state_machine.change_state(Constants.ActorState.IDLING)
		return
	
	_player.animated_sprite.animation_looped.connect(_on_animated_sprite_animation_looped)
	_player.animated_sprite.play("attack")


func physics_process(_delta: float) -> void:
	pass


## take action based on current state
func update_state() -> void:
	if _get_current_target() == null:
		_player.state_machine.change_state(Constants.ActorState.IDLING)


## actions on exiting state
func exit_state() -> void:
	_player.animated_sprite.animation_looped.disconnect(_on_animated_sprite_animation_looped)


func _on_animated_sprite_animation_looped() -> void:
	if _get_current_target() == null or not _is_current_target_in_range():
		print("Target (%s) either is null or not in range anymore"%[_get_current_target()])
		_player.state_machine.change_state(Constants.ActorState.IDLING)
		return
	
	_player.attack()
	_player.state_machine.change_state(Constants.ActorState.IDLING)


func _is_current_target_in_range() -> bool:
	var value = false
	
	var current_target := _get_current_target()
	if current_target != null:
		var distance_to_target := _player.global_position.distance_to(current_target.global_position)
		value =  distance_to_target <= _player.attack_to_cast.range
	
	return value

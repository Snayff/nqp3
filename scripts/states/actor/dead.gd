extends BaseState


## actions on entering state
func enter_state() -> void:
	_creator.add_to_group("dead")
	_creator.remove_from_group("alive")
	_creator.stats.health = 0
	
	if not _creator.animated_sprite.animation_looped.is_connected(
			_on_animated_sprite_animation_looped
	):
		_creator.animated_sprite.animation_looped.connect(_on_animated_sprite_animation_looped)
	
	_creator.animated_sprite.play("death")


func physics_process(_delta: float) -> void:
	pass


## take action based on current state
func decide_next_state() -> void:
	pass


## actions on exiting state
func exit_state() -> void:
	pass


func _on_animated_sprite_animation_looped() -> void:
	_creator.die()

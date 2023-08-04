extends BasePlayerState


## actions on entering state
func enter_state() -> void:
	if not _creator.animated_sprite.animation_looped.is_connected(
			_on_animated_sprite_animation_looped
	):
		_creator.animated_sprite.animation_looped.connect(_on_animated_sprite_animation_looped)
	_creator.animated_sprite.play("death")


func physics_process(_delta: float) -> void:
	pass


## take action based on current state
func update_state() -> void:
	pass


## actions on exiting state
func exit_state() -> void:
	pass


func _on_animated_sprite_animation_looped() -> void:
	_creator.die()

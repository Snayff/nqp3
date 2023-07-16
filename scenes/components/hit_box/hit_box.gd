class_name HitBox extends Area2D
## To allow a Node with a CollisionShape to be identified by a [annotation HurtBox].
##
## Must have Collision Layer active and set to HitBox.
## Used in conjunction with an ImpactDetector, to determine hitting world objects. The ImpactDetector is
## a copy of the HitBox, but has no Collision Layer active and has Collision Masks active for World and actor.
## The ImpactDetector should occupy the same space as the HitBox.

@onready var _collision_shape := $CollisionShape2D

func _init() -> void:
	pass

func set_disabled(is_disabled: bool) -> void:
	_collision_shape.set_deferred("disabled", is_disabled)

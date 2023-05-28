class_name HurtBox extends Area2D
## To allow a Node with a CollisionShape to identify a [annotation HitBox].
##
## Must have a Collision Mask active and set to HurtBox.

func _init() -> void:
	pass

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: HitBox) -> void:
	pass

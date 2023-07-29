class_name SimpleAnimation extends AnimatedSprite2D
## a simple effect that is given an set of sprites and disappears after looping

func _ready() -> void:
	animation_looped.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	queue_free()

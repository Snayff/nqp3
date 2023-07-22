class_name TargetFinder extends Area2D
## area2d complete with collision shape used to find actors within a radius from centre

@onready var col_shape : CollisionShape2D = $CollisionShape2D

var is_visible : bool = false:
	set(value):
		is_visible = value
		if is_visible == true:
			queue_redraw()
var shape_colour : Color
var radius : int = 20:
	set(value):
		col_shape.shape.radius = value
		radius = value
		queue_redraw()

func _draw() -> void:
	if is_visible:
		draw_arc(position, col_shape.shape.radius, 0, 360, 32, shape_colour)

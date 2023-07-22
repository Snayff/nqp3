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


func _ready() -> void:
	await get_tree().physics_frame
	print("=============> " + get_parent().debug_name + "'s target finder synced with physics frame. " )

func _draw() -> void:
	if is_visible:
		draw_arc(position, col_shape.shape.radius, 0, 360, 32, shape_colour)

## get all actors colliding with the shape
##
## helper function that uses get_overlapping_bodies but recasts to correct type and
## also allows for a delay to wait for the next physics frame
func get_actors_in_range(wait_frame: bool = false) -> Array[Actor]:
	if wait_frame:
		await get_tree().physics_frame

	var overlapping : Array[Actor]
	overlapping.assign(get_overlapping_bodies())
	assert(overlapping is Array[Actor])
	return overlapping

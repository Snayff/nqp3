class_name TargetFinder extends Area2D
## area2d complete with collision shape used to find actors within a radius from centre

@onready var col_shape : CollisionShape2D = $CollisionShape2D
@onready var visibility_timer : Timer = $VisibilityTimer

var is_visible : bool = false:
	set(value):
		is_visible = value
		queue_redraw()
var shape_colour : Color
var radius : int = 20:
	set(value):
		col_shape.shape.radius = value
		radius = value
		queue_redraw()


func _ready() -> void:
	await get_tree().physics_frame
	#print("=============> " + get_parent().debug_name + "'s target finder synced with physics frame. " )

func _draw() -> void:
	if is_visible:
		draw_arc(position, col_shape.shape.radius, 0, 360, 32, shape_colour)

## get all actors colliding with the shape
##
## helper function that uses get_overlapping_bodies but recasts to correct type and
func get_actors_in_range() -> Array[Actor]:
	var overlapping : Array[Actor] = []
	overlapping.assign(get_overlapping_bodies())
	return overlapping


func set_visibility(visible: bool, duration: float = 0) -> void:
	var original_state : bool = is_visible

	if is_visible != visible:
		is_visible = visible

	# set timer to revert to previous visibility
	if duration != 0:
		visibility_timer.start(duration)
		visibility_timer.timeout.connect(set_visibility.bind(original_state), CONNECT_ONE_SHOT)


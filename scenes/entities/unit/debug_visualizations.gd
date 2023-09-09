@static_unload
class_name DebugVisualsUnit
extends Node2D

static var team_count = {
	Constants.TEAM_ALLY: 0,
	Constants.TEAM_ENEMY: 0,
}

@export var colors_ally: Array[Color] = [
	Color.BLUE,
	Color.SKY_BLUE,
	Color.DEEP_SKY_BLUE,
	Color.CORNFLOWER_BLUE
] 
@export var colors_enemy: Array[Color] = [
	Color.RED,
	Color.FIREBRICK,
	Color.CRIMSON,
	Color.DARK_RED
]

@export var marker_radius := 5.0:
	set(value):
		marker_radius = value
		
		if is_inside_tree():
			_marker_radius_squared = pow(marker_radius*2, 2.0)

var color = Color.WHITE
var unit_team := "":
	set(value):
		unit_team = value
		
		if unit_team == Constants.TEAM_ALLY or unit_team == Constants.TEAM_ENEMY:
			if unit_team == Constants.TEAM_ALLY:
				_color_index = posmod(team_count[unit_team], colors_ally.size())
				color = colors_ally[_color_index]
			else:
				_color_index = posmod(team_count[unit_team], colors_enemy.size())
				color = colors_enemy[_color_index]
			
			team_count[unit_team] += 1
			print("team count: %s team: %s"%[team_count, unit_team])
			_color_index = team_count[unit_team]
		elif not unit_team.is_empty():
			assert(not unit_team.is_empty(), "unimplemented team type: %s"%[unit_team])

var _color_index := 0
var _marker_radius_squared := 0.0

@onready var _unit := owner as Unit

func _ready() -> void:
	_marker_radius_squared = pow(marker_radius * 2, 2)
	if not OS.has_feature("debug"):
		hide()
		queue_free()


func _draw() -> void:
	var radius_squared = _unit._actors.reduce(get_farthest_actor, 0.0)
	var radius = sqrt(radius_squared)
	draw_circle(Vector2.ZERO, marker_radius, color)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 16, color)
	
	if is_instance_valid(_unit.target_unit) and _unit.target_unit.is_in_group("alive_unit"):
		var target_position = to_local(_unit.target_unit.global_position)
		draw_line(Vector2.ZERO, target_position, color)


func _process(delta: float) -> void:
	_unit.global_position = _unit._actors.reduce(calculate_average_position, Vector2.ZERO)
	queue_redraw()
	if _unit.is_in_group("dead_unit"):
		hide()
		set_process(false)


func calculate_average_position(average_position: Vector2, actor: Actor) -> Vector2:
	if actor.is_in_group("alive"):
		if average_position == Vector2.ZERO:
			average_position = actor.global_position
		else:
			average_position += actor.global_position
			average_position /= 2.0
	
	return average_position


func get_farthest_actor(distance: float, actor: Actor) -> float:
	if actor.is_in_group("alive"):
		if distance == 0.0:
			distance = global_position.distance_squared_to(actor.global_position)
		else:
			var new_distance := global_position.distance_squared_to(actor.global_position)
			distance = max(new_distance, distance)
	return max(distance, _marker_radius_squared)

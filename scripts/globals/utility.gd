extends Node
## Misc. utility functions.

const _HitBox : PackedScene = preload("res://scenes/components/hit_box/hit_box.tscn")

var _last_id : int = 0

## get the normalised direction to target
func get_direction_to_target(start: Node2D, target: Node2D) -> Vector2:
	return start.global_position.direction_to(target.global_position)

## add collection of sprites from a folder to a SpriteFrames
## overwrites existing animation of same name if one exists.
func add_animation_to_sprite_frames(
	sprite_frames: SpriteFrames,
	sprite_folder_path: String,
	animation_name: String
) -> SpriteFrames:

	# clear existing anim if it exists
	if animation_name in sprite_frames.get_animation_names():
		sprite_frames.clear(animation_name)

	# add new anim
	sprite_frames.add_animation(animation_name)

	# loop files in folder and gather sprites
	var dir = DirAccess.open(sprite_folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# ensure we dont have a folder
			if not dir.current_is_dir():
				if not ".import" in file_name:
					sprite_frames.add_frame(animation_name, load(sprite_folder_path + file_name))
			file_name = dir.get_next()

	return sprite_frames

## generate a unique id
func generate_id() -> int:
	_last_id += 1
	return _last_id

func get_action_type_script_path(action_type: Constants.ActionType) -> String:
	var path : String

	match action_type:
		Constants.ActionType.ATTACK:
			path = Constants.PATH_ATTACKS
		Constants.ActionType.STATUS_EFFECT:
			path = Constants.PATH_STATUS_EFFECTS
		_:
			path = Constants.PATH_REACTIONS

	return path

## find all actors in area
func get_actors_in_area(pos: Vector2, radius: int) -> Array[Actor]:
	var actors: Array[Actor] = []

	# configure shape cast
	var shape_cast = ShapeCast2D.new()
	add_child(shape_cast)
	shape_cast.collision_mask = 2  # entity mask
	shape_cast.max_results = 100
	shape_cast.target_position = Vector2.ZERO
	shape_cast.global_position = pos

	# configure shape
	shape_cast.shape = CircleShape2D.new()
	shape_cast.shape.radius = radius

	# get info right away
	shape_cast.force_shapecast_update()

	# filter results
	if shape_cast.is_colliding():
		for result in shape_cast.collision_result:
			actors.append(result["collider"])

	# clean up
	shape_cast.queue_free()

	return actors

## get nearest actor from position. Can return null.
func get_nearest_actor(pos: Vector2, actors: Array[Actor]) -> Actor:
	# check there are any actors at all
	if actors.size() ==  0:
		return null

	# assume the first node is closest
	var nearest = actors[0]
	var current_closest = nearest.global_position.distance_to(pos)

	# look through nodes to see if any are closer
	for actor in actors:
		var distance = actor.global_position.distance_to(pos)
		var is_alive = actor.is_in_group("alive")

		if distance < current_closest and is_alive:
			nearest = actor
			current_closest = nearest.global_position.distance_to(pos)

	return nearest

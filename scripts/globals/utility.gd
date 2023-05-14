extends Node
## Misc. utility functions.

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
		_:
			path = Constants.PATH_REACTIONS

	return path

## find all targets in area
func get_targets_in_area(pos: Vector2, radius: int) -> Array[Actor]:
	# create hitbox
	var area : HitBox = HitBox.new()
	area._collision_shape.radius = radius
	# FIXME: coll shape doesnt exist:  Invalid set index 'radius' (on base: 'Nil') with value of type 'int'.
	#  should we create an area checker scene and "explode" after a frame, returning results via signal?
	area.global_position = pos
	add_child(area)

	# wait 1 frame to give physics chance to update
	await get_tree().physics_frame

	# find actors in area
	var poss_targets : Array = area.get_overlapping_bodies()
	var valid_targets: Array[Actor] = []
	for poss_target in poss_targets:
		if poss_target is Actor:
			valid_targets.append(poss_target)

	# del area
	area.queue_free()

	return valid_targets

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

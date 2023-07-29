extends Node
## Misc. utility functions.

var _last_id : int = 0

## generate a unique id
func generate_id() -> int:
	_last_id += 1
	return _last_id

######### BUILDERS #########

## add collection of sprites from a folder to a SpriteFrames
##
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


######### CONVERSION / NAMING HELPERS ############

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


########## ACTOR quries #################

## get the relevant group based on target type
##
## can return empty string
func get_target_group(caller: Actor, target_type: Constants.TargetType) -> String:
	var group_to_target: String = ""

	match target_type:
		Constants.TargetType.SELF:
			push_warning("_get_target_group: Shouldnt be asking for self.")
			group_to_target =  ""

		Constants.TargetType.ALLY:
			if caller.is_in_group(Constants.TEAM_ALLY):
				group_to_target = Constants.TEAM_ALLY
			else:
				group_to_target = Constants.TEAM_ENEMY

		Constants.TargetType.ENEMY:
			if caller.is_in_group(Constants.TEAM_ALLY):
				group_to_target = Constants.TEAM_ENEMY
			else:
				group_to_target = Constants.TEAM_ALLY

		Constants.TargetType.ATTACKER:
			push_error("_get_target_group: not able to process ATTACKER.")
			group_to_target = ""

		Constants.TargetType.DEFENDER:
			push_error("_get_target_group: not able to process DEFENDER.")
			group_to_target = ""

		Constants.TargetType.ANY:
			push_error("_get_target_group: not able to process ANY.")
			group_to_target = ""

		_:
			push_error("_get_target_group: target type (" + Constants.TargetType.keys()[target_type] + ") not found.")
			group_to_target = ""

	return group_to_target


## filter an array of Actors so that only those in the preference list are returned.
##
## processed in the order given, so if a superlative is first the list becomes length 1 for further filtering.
func filter_for_preferences(caller: Actor, preferences: Array[Constants.TargetPreference], poss_targets: Array[Actor]) -> Array[Actor]:
	var ok_targets = poss_targets.duplicate()
	for pref in preferences:
		match pref:
			Constants.TargetPreference.ANY:
				# everyone is ok, dont change list
				pass

			Constants.TargetPreference.LOWEST_HEALTH:
				var lowest_health : Actor = get_lowest_health(ok_targets)
				# this filters down to a single actor, so clear array before adding
				ok_targets.clear()
				ok_targets.append(lowest_health)

			Constants.TargetPreference.HIGHEST_HEALTH:
				push_error("_filter_for_preferences: not able to process HIGHEST_HEALTH.")

			Constants.TargetPreference.WEAK_TO_MUNDANE:
				push_error("_filter_for_preferences: not able to process WEAK_TO_MUNDANE.")

			Constants.TargetPreference.DAMAGED:
				ok_targets = get_damaged_actors(ok_targets)

			Constants.TargetPreference.NEAREST:
				var nearest : Actor = get_nearest(caller, ok_targets)
				# this filters down to a single actor, so clear array before adding
				ok_targets.clear()
				ok_targets.append(nearest)

			Constants.TargetPreference.FURTHEST:
				push_error("_filter_for_preferences: not able to process FURTHEST.")

	return ok_targets


## return the actor with the lowest health
func get_lowest_health(actors: Array[Actor]) -> Actor:
	var new_actors : Array[Actor] = actors.duplicate()
	new_actors.sort_custom(func(a, b): return a.stats.health < b.stats.health)
	return new_actors.pop_front()


## return all actors that are not at full health
func get_damaged_actors(actors: Array[Actor]) -> Array[Actor]:
	var new_actors : Array[Actor] = actors.duplicate()
	var filtered_actors : Array[Actor] = new_actors.filter(func(a): return a.stats.health < a.stats.max_health)

	return filtered_actors


## return the actor that is nearest the ai's creator
func get_nearest(caller: Actor, actors: Array[Actor]) -> Actor:
	var poss_targets : Array[Actor] = actors.duplicate()

	var creator_pos : Vector2 = caller.global_position
	var nearest_target : Actor = null
	var nearest_distance = 9999

	# look through nodes to see which is closest
	for _target in poss_targets:
		var distance = _target.global_position.distance_to(creator_pos)

		## if we have a nearest target, check their distance
		if nearest_target != null:
			nearest_distance = nearest_target.global_position.distance_to(creator_pos)

		# if new target closer than current target, update target
		if distance < nearest_distance:
			nearest_target = _target

	return nearest_target


## find all actors in area
func get_actors_in_area(pos: Vector2, radius: int) -> Array[Actor]:
	# FIXME: this doesnt ever return actors. When this works it might be better than target_finder for use when casting

	var actors: Array[Actor] = []
	# configure shape cast
	var shape_cast = ShapeCast2D.new()
	add_child(shape_cast)
	shape_cast.collide_with_bodies = true
	shape_cast.collision_mask = 2  # entity mask
	shape_cast.max_results = 50
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


	# rather than using a shape cast we could query the phys engine like the following, but needs to be called from _physics_process:
#	var space := get_world_2d().direct_space_state
#	var parameters := PhysicsShapeQueryParameters2D.new()
#	var rect_shape = RectangleShape2D.new()
#	rect_shape.size = Vector2(50,50)
#	parameters.shape = rect_shape
#	var hits = space.intersect_shape(parameters)

	return actors


######## MATHS ##########

## convert a polar coord to a cartesian one
func convert_polar_to_cartesian(radius: float, theta: float) -> Vector2:
	var x = radius * cos(theta)
	var y = radius * sin(theta)
	return Vector2(x, y)

class_name ActorAI extends Node

var _creator : Actor
var target : Actor

func _init(creator: Actor) -> void:
	_creator = creator

func _ready() -> void:
	pass

func is_enemy(target : Actor) -> bool:
	if _creator.is_in_group("team1"):
		if target.is_in_group("team2"):
			return true
	if _creator.is_in_group("team2"):
		if target.is_in_group("team1"):
			return true
	return false

## get a new target on the opposing team.
##
## Can return null
func get_target(target_type: Constants.TargetType, preferences: Array[Constants.TargetPreference] = [Constants.TargetPreference.ANY]) -> Actor:

	# ignore prefs and return seld if targeting self
	if target_type == Constants.TargetType.SELF:
		return _creator

	# get all targets in range
	var poss_targets = _creator._target_finder.get_overlapping_bodies()

	# check we found any possible target
	if poss_targets.size() ==  0:
		# debug couldnt find anyone
		print(
			_creator.debug_name + " couldnt find any targets in range (" +
			str(_creator._target_finder.get_node("CollisionShape2D").shape.radius) + ")."
		)
		return null

	# parse which group to look for
	var group_to_target : String = _get_target_group(target_type)

	# run initial checks to filter out ineligible targets
	var valid_targets : Array[Actor] = []
	for target_ in poss_targets:
		var is_alive = target_.is_in_group("alive")
		var is_correct_type = target_.is_in_group(group_to_target)
		if is_alive and is_correct_type:
			valid_targets.append(target_)
		else:
			# debug couldnt find anyone
			print(
				_creator.debug_name + " couldnt find target of type " + group_to_target + " in range (" +
				str(_creator._target_finder.get_node("CollisionShape2D").shape.radius) + ")."
			)

	# filter by preferences
	var pref_targets: Array[Actor] = []
	pref_targets = _filter_for_preferences(preferences, valid_targets)

	# return first actor in list
	var new_target : Actor = pref_targets.pop_front()

	# check we have a target
	if new_target != null:
		print(
			_creator.debug_name + "'s selected target in " + group_to_target +
			 " is " + new_target.debug_name +  " at " + str(new_target.global_position) + "."
		)
		return new_target
	else:
		# debug couldnt find anyone
			print(
				_creator.debug_name + " couldnt find target with preferences " + str(preferences) + " in range (" +
				str(_creator._target_finder.get_node("CollisionShape2D").shape.radius) + ")."
			)
			return null


## get the relevant group based on target type
##
## can return empty string
func _get_target_group(target_type: Constants.TargetType) -> String:
	var group_to_target: String = ""

	match target_type:
		Constants.TargetType.SELF:
			push_warning("_get_target_group: Shouldnt be asking for self.")
			group_to_target =  ""

		Constants.TargetType.ALLY:
			if _creator.is_in_group("team1"):
				group_to_target = "team1"
			else:
				group_to_target = "team2"

		Constants.TargetType.ENEMY:
			if _creator.is_in_group("team1"):
				group_to_target = "team2"
			else:
				group_to_target = "team1"

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
func _filter_for_preferences(preferences: Array[Constants.TargetPreference], poss_targets: Array[Actor]) -> Array[Actor]:
	var ok_targets = poss_targets.duplicate()
	for pref in preferences:
		match pref:
			Constants.TargetPreference.ANY:
				# everyone is ok, dont change list
				pass

			Constants.TargetPreference.LOWEST_HEALTH:
				var lowest_health : Actor = _get_lowest_health(ok_targets)
				# this filters down to a single actor, so clear array before adding
				ok_targets.clear()
				ok_targets.append(lowest_health)

			Constants.TargetPreference.HIGHEST_HEALTH:
				push_error("_filter_for_preferences: not able to process HIGHEST_HEALTH.")

			Constants.TargetPreference.WEAK_TO_MUNDANE:
				push_error("_filter_for_preferences: not able to process WEAK_TO_MUNDANE.")

			Constants.TargetPreference.DAMAGED:
				ok_targets = _get_damaged_actors(ok_targets)

			Constants.TargetPreference.NEAREST:
				var nearest : Actor = _get_nearest(ok_targets)
				# this filters down to a single actor, so clear array before adding
				ok_targets.clear()
				ok_targets.append(nearest)

			Constants.TargetPreference.FURTHEST:
				push_error("_filter_for_preferences: not able to process FURTHEST.")

	return ok_targets


## return the actor with the lowest health
func _get_lowest_health(actors: Array[Actor]) -> Actor:
	var new_actors : Array[Actor] = actors.duplicate()
	new_actors.sort_custom(func(a, b): return a.stats.health < b.stats.health)
	return new_actors.pop_front()


## return all actors that are not at full health
func _get_damaged_actors(actors: Array[Actor]) -> Array[Actor]:
	var new_actors : Array[Actor] = actors.duplicate()
	var filtered_actors : Array[Actor] = new_actors.filter(func(a): return a.stats.health < a.stats.max_health)

	return filtered_actors


## return the actor that is nearest the ai's creator
func _get_nearest(actors: Array[Actor]) -> Actor:
	var poss_targets : Array[Actor] = actors.duplicate()

	var creator_pos : Vector2 = _creator.global_position
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

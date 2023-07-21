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
## Can return null
func get_target(target_type: Constants.TargetType, preference: Constants.TargetPreference = Constants.TargetPreference.ANY) -> Actor:
	# TODO: Use target preference

	if target_type == Constants.TargetType.SELF:
		return _creator

	var group_to_target : String = _get_target_group(target_type)

	var poss_targets = _creator._target_finder.get_overlapping_bodies()

	# check we found any possible target
	if poss_targets.size() ==  0:
		return null

	# look through nodes to see if any are closer
	var nearest_target = null
	var creator_pos : Vector2 = _creator.global_position
	for _target in poss_targets:
		var distance = _target.global_position.distance_to(creator_pos)

		# get a closest distance from target, if we have 1
		var nearest_distance = 9999
		if nearest_target != null:
			nearest_distance = nearest_target.global_position.distance_to(creator_pos)

		var is_alive = _target.is_in_group("alive")
		var is_correct_type = _target.is_in_group(group_to_target)
		if distance < nearest_distance and is_alive and is_correct_type:
			nearest_target = _target

	# debug helper
	if nearest_target == null:
		print(
			_creator.debug_name + " couldnt find target of type " + group_to_target + " in range (" +
			str(_creator._target_finder.get_node("CollisionShape2D").shape.radius) + ")."
		)
	else:
		print(_creator.debug_name + "'s nearest target in " + group_to_target + " is at " + str(nearest_target.global_position))

	return nearest_target


## get the relevant group based on target type
## can return empty string
func _get_target_group(target_type: Constants.TargetType) -> String:
	var group_to_target: String = ""

	match target_type:
		Constants.TargetType.SELF:
			push_error("_get_target_group: Shouldnt be asking for self.")
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

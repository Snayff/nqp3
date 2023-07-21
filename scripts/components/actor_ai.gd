class_name ActorAI extends Node

var _creator : Actor
var target : Actor

func _init(creator: Actor) -> void:
	_creator = creator

func _ready() -> void:
	pass

func is_enemy(target : Actor) -> bool:
	if _creator.is_in_group("ally"):
		if target.is_in_group("enemy"):
			return true
	if _creator.is_in_group("enemy"):
		if target.is_in_group("ally"):
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
		var is_enemy = _target.is_in_group(group_to_target)
		if distance < nearest_distance and is_alive and is_enemy:
			nearest_target = _target

	# debug helper
	if nearest_target == null:
		print(
			str(_creator.uid) + " couldnt find target of type " + group_to_target + " in range (" +
			str(_creator._target_finder.get_node("CollisionShape2D").shape.radius) + ")."
		)
	else:
		print(str(_creator.uid) + "'s nearest target in " + group_to_target + " is at " + str(nearest_target.global_position))

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
			if _creator.is_in_group("ally"):
				group_to_target = "ally"
			else:
				group_to_target = "enemy"

		Constants.TargetType.ENEMY:
			if _creator.is_in_group("ally"):
				group_to_target = "enemy"
			else:
				group_to_target = "ally"

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

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
func get_target(preference: Constants.TargetPreference = Constants.TargetPreference.ANY) -> Actor:
	# TODO: Use target preference

	var group_to_target : String
	if _creator.is_in_group("ally"):
		group_to_target = "enemy"
	else:
		group_to_target = "ally"

	#var poss_targets := get_tree().get_nodes_in_group(group_to_target)
	var poss_targets = _creator._target_finder.get_overlapping_bodies()

	# check we found any possible target
	if poss_targets.size() ==  0:
		return null

	# assume the first node is closest
	var nearest_target = null

	# look through nodes to see if any are closer
	var _creator_pos : Vector2 = _creator.global_position
	for _target in poss_targets:
		var distance = _target.global_position.distance_to(_creator_pos)

		# get a closest distance from target, if we have 1
		var nearest_distance = 9999
		if nearest_target != null:
			nearest_distance = nearest_target.global_position.distance_to(_creator_pos)


		var is_alive = _target.is_in_group("alive")
		var is_enemy = _target.is_in_group(group_to_target)
		if distance < nearest_distance and is_alive and is_enemy:
			nearest_target = _target
	# print("combatant nearest target in " + group_to_target + " is at " + str(nearest_target.global_position))
	return nearest_target

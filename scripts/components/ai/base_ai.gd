class_name BaseAI extends Node

var target : Actor

func _ready() -> void:
	owner = get_parent()
	assert(owner is Actor)


## get a new target on the opposing team.
## Can return null
func get_target(preference: Constants.TargetPreference = Constants.TargetPreference.ANY) -> Actor:
	# TODO: Use target preference

	var owner_pos : Vector2 = owner.global_position

	var group_to_target : String
	if owner.is_in_group("ally"):
		group_to_target = "enemy"
	else:
		group_to_target = "ally"

	var poss_targets := get_tree().get_nodes_in_group(group_to_target)

	# assume the first node is closest
	if poss_targets.size() ==  0:
		return null
	var nearest_target = poss_targets[0]

	# look through nodes to see if any are closer
	for _target in poss_targets:
		var distance = _target.global_position.distance_to(owner_pos)
		var current_closest = nearest_target.global_position.distance_to(owner_pos)
		var is_alive = _target.is_in_group("alive")
		if distance < current_closest and is_alive:
			nearest_target = _target
	# print("combatant nearest target in " + group_to_target + " is at " + str(nearest_target.global_position))
	return nearest_target

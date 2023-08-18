class_name ActorAI extends Node

var _creator : Actor

func _init(creator: Actor) -> void:
	_creator = creator

func _ready() -> void:
	pass

func is_enemy(p_target : Actor) -> bool:
	if _creator.is_in_group(Constants.TEAM_ALLY):
		if p_target.is_in_group(Constants.TEAM_ENEMY):
			return true
	if _creator.is_in_group(Constants.TEAM_ENEMY):
		if p_target.is_in_group(Constants.TEAM_ALLY):
			return true
	return false

## get a new target on the opposing team.
##
## Can return null
func get_target(p_action: BaseAction) -> Actor:
	var msg := ""
	var new_target: Actor = null
	var group_to_target : String = Utility.get_target_group(_creator, p_action.target_type)
	
	# ignore prefs and return seld if targeting self
	if p_action.target_type == Constants.TargetType.SELF:
		return _creator
	
	# get all targets in range
	var poss_targets: Array[Actor] = []
	poss_targets.assign(_creator._target_finder.get_overlapping_bodies())
	
	# check we found any possible target
	if poss_targets.size() > 0:
		# parse which group to look for
		# run initial checks to filter out ineligible targets
		var valid_targets : Array[Actor] = poss_targets.filter(_is_valid_target.bind(group_to_target))
		if valid_targets.size() > 0:
			# filter by preferences
			var pref_targets: Array[Actor] = []
			pref_targets = Utility.filter_for_preferences(
					_creator, p_action.target_preferences, valid_targets
			)
			new_target = pref_targets.pop_front() as Actor
			
			# check we have a target
			if new_target != null:
				msg = "%s's selected target in %s is %s at %s."%[
					_creator.debug_name, group_to_target, 
					new_target.debug_name, new_target.global_position
				]
			else:
				# debug couldnt find anyone
				msg = "%s couldnt find target with preferences %s in range (%s)."%[
					_creator.debug_name, p_action.target_preferences, _creator._target_finder.radius
				]
		else:
			# debug couldnt find anyone of the right type
			msg = "%s couldnt find target of type %s in range (%s)."%[
					_creator.debug_name, group_to_target, _creator._target_finder.radius
			]
	else:
		# debug couldnt find anyone in range
		msg = "%s couldnt find any targets in range (%s)."%[
				_creator.debug_name, _creator._target_finder.radius
		]
	
	if new_target == null:
		var existing_targets := get_tree().get_nodes_in_group(group_to_target)
		existing_targets = existing_targets.filter(_is_valid_target.bind(group_to_target))
		if not existing_targets.is_empty():
			# just pick the first enemy node and move towards them, eventually will be in range
			new_target = existing_targets.pop_front() as Actor
			msg = "%s randomly picked %s to run towards."%[_creator.debug_name, new_target.debug_name]
		else:
			msg = "No remaining valid target in scene."
	
	print(msg)
	return new_target


func get_steered_velocity(
		velocity: Vector2, 
		target_pos: Vector2
) -> Vector2:
	# determine route
	var direction : Vector2 = _creator.global_position.direction_to(target_pos)
	var desired_velocity : Vector2 = direction * _creator.stats.move_speed
	var steering : Vector2 = (desired_velocity - velocity)
	
	# update velocity
	velocity += steering
	return velocity


func _is_valid_target(candidate: Actor, group_to_target: String) -> bool:
	var is_alive = candidate.is_in_group("alive")
	var is_correct_type = candidate.is_in_group(group_to_target)
	return is_alive and is_correct_type

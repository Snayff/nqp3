class_name ActorAI extends Node

var _creator : Actor
var target : Actor

func _init(creator: Actor) -> void:
	_creator = creator

func _ready() -> void:
	pass

func is_enemy(target : Actor) -> bool:
	if _creator.is_in_group(Constants.TEAM_ALLY):
		if target.is_in_group(Constants.TEAM_ENEMY):
			return true
	if _creator.is_in_group(Constants.TEAM_ENEMY):
		if target.is_in_group(Constants.TEAM_ALLY):
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
			str(_creator._target_finder.radius) + ")."
		)
		return null

	# parse which group to look for
	var group_to_target : String = Utility.get_target_group(_creator, target_type)

	# run initial checks to filter out ineligible targets
	var valid_targets : Array[Actor] = []
	for target_ in poss_targets:
		var is_alive = target_.is_in_group("alive")
		var is_correct_type = target_.is_in_group(group_to_target)
		if is_alive and is_correct_type:
			valid_targets.append(target_)

	if valid_targets.size() == 0:
		# debug couldnt find anyone
		print(
			_creator.debug_name + " couldnt find target of type " + group_to_target + " in range (" +
			str(_creator._target_finder.radius) + ")."
		)
		return null


	# filter by preferences
	var pref_targets: Array[Actor] = []
	pref_targets = Utility.filter_for_preferences(_creator, preferences, valid_targets)

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
				str(_creator._target_finder.radius) + ")."
			)
			return null

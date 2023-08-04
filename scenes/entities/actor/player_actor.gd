class_name PlayerActor
extends Actor

var move_direction := Vector2.ZERO

# key is attack uids, value is target Actor
var targets := {}


func actor_setup() -> void:
	for uid in actions.attacks:
		targets[uid] = null
	
	super()


## execute actor's attack.
## this is a random attack if attack_to_cast is null.
func attack() -> void:
	assert(attack_to_cast != null, "PlayerActor can't attack without an attack_to_cast")
	if attack_to_cast == null:
		push_error("PlayerActor can't attack without an attack_to_cast")
		return
	
	actions.use_attack(attack_to_cast.uid, targets[attack_to_cast.uid])
	
	attack_to_cast = null


func _attempt_all_target_refresh() -> void:
	if _target_refresh_timer.is_stopped():
		_target_refresh_timer.start(1)
		
		for uid in actions.attacks:
			var attack := actions.attacks[uid] as BaseAction
			var current_target := targets[uid] as Actor
			if not attack.is_ready:
				continue
			
			_update_target_finder_range(attack.range)
			await get_tree().process_frame
			
			targets[uid] = get_target(current_target, attack.target_type, attack.target_preferences)


## get new target and update ai and nav's target
func get_target(
		current_target: Actor,
		target_type: Constants.TargetType = Constants.TargetType.ENEMY,
		preferences: Array[Constants.TargetPreference] = [Constants.TargetPreference.ANY]
) -> Actor:
	# disconnect from current signals on target
	if current_target:
		if current_target.no_longer_targetable.is_connected(refresh_target):
			current_target.no_longer_targetable.disconnect(refresh_target)
	
	# get new target
	var new_target := ai.get_target(target_type, preferences)
	
	if new_target != null:
		# relisten to target changes
		if not new_target.is_connected("no_longer_targetable", refresh_target):
			new_target.no_longer_targetable.connect(refresh_target)
		
		# update nav agent's target
		_navigation_agent.set_target_position(new_target.global_position)
	
	return new_target

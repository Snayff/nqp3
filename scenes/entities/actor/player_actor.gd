class_name PlayerActor
extends Actor

var move_direction := Vector2.ZERO

# key is attack uids, value is target Actor
var targets := {}


func actor_setup() -> void:
	for action_uid in actions.attacks:
		targets[action_uid] = null
	
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
		
		for action_uid in actions.attacks:
			var current_attack := actions.attacks[action_uid] as BaseAction
			var current_target := targets[action_uid] as Actor
			if not current_attack.is_ready:
				continue
			
			_update_target_finder_range(int(current_attack.range))
			await get_tree().process_frame
			
			targets[action_uid] = get_target(current_target, current_attack)


## get new target and update ai and nav's target
func get_target(current_target: Actor, p_action: BaseAction) -> Actor:
	# disconnect from current signals on target
	if current_target:
		if current_target.no_longer_targetable.is_connected(_attempt_all_target_refresh):
			current_target.no_longer_targetable.disconnect(_attempt_all_target_refresh)
	
	# get new target
	var new_target := ai.get_target(p_action, targeted_unit, parent_unit)
	
	if new_target != null:
		# relisten to target changes
		if not new_target.is_connected("no_longer_targetable", _attempt_all_target_refresh):
			new_target.no_longer_targetable.connect(_attempt_all_target_refresh)
	
	return new_target

extends BasePlayerState

const EVENTS_ACTIONS = [
	"action_0", 
	"action_1", 
	"action_2", 
	"action_3", 
]

func unhandled_input(event: InputEvent) -> void:
	for action_name in EVENTS_ACTIONS:
		if event.is_action(action_name):
			var index := (action_name as String).replace("action_", "").to_int()
			if index < _player.targets.size():
				var action_uid := _player.targets.keys()[index] as int
				var current_attack := _player.actions.attacks[action_uid] as BaseAction
				if current_attack.is_ready:
					_player.attack_to_cast = _player.actions.attacks[action_uid]
					_player.state_machine.change_state(Constants.ActorState.CASTING)
				else:
					print_debug("%s is not ready to use"%[current_attack])
				return
			else:
				print_debug("%s has no attack for input event %s"%[_player.debug_name, action_name])


func physics_process(_delta):
	_player.move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_player._attempt_all_target_refresh()

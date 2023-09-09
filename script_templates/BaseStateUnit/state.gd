extends BaseStateUnit

# meta-name: State
# meta-description: An Entity's state, processing their actions
# meta-default: true

## actions on entering state
func enter_state() -> void:
	pass


func unhandled_input(event: InputEvent) -> void:
	pass


func physics_process(delta: float) -> void:
	pass


## take action based on current state
func update_state() -> void:
	pass


## actions on exiting state
func exit_state() -> void:
	pass

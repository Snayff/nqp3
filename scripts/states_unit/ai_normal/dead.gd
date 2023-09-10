extends BaseStateUnit


## actions on entering state
func enter_state() -> void:
	_creator.add_to_group("dead_unit")
	_creator.remove_from_group("alive_unit")
	_creator.target_unit = null
	_creator.unit_defeated.emit()

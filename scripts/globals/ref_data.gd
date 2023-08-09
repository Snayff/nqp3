extends Node
## A store for all reference data.
##
## Read Only.

func get_unit_data(unit_name: String) -> UnitData:
	var value: UnitData = null
	
	match unit_name:
		"copper_golem":
			var actions = {  ## must use {Action Type, script name} (NOT class name)
				Constants.ActionType.ATTACK : [
					"smash",
				],
				Constants.ActionType.REACTION : {
					Constants.ActionTrigger.ON_DEAL_DAMAGE : [
						"spiky_shell",
					]
				}
			}
			value = UnitData.new({
				"actions": actions,
			})
		"conjurer":
			var actions := {  ## must use Action Type, script name (NOT class name)
				Constants.ActionType.ATTACK : [
					"wand_blast",
					"heal",
				],
				Constants.ActionType.REACTION : { }
			}
			value = UnitData.new({
				"max_health": 70,
				"magic_defence": 2,
				"mundane_defence": 3,
				"attack": 33,
				"move_speed": 200,
				"num_units": 3,
				"actions": actions,
			})
		"poet":
			var actions := {  ## must use Action Type, script name (NOT class name)
				Constants.ActionType.ATTACK : [
					"stanza",
				],
				Constants.ActionType.REACTION : { }
			}
			value = UnitData.new({
				"max_health": 70,
				"magic_defence": 2,
				"mundane_defence": 3,
				"attack": 33,
				"move_speed": 200,
				"num_units": 2,
				"actions": actions,
			})
		"cavalier":
			var actions := {  ## must use {Action Type, script name} (NOT class name)
				Constants.ActionType.ATTACK : [
					"smash",
					"wand_blast",
				],
				Constants.ActionType.REACTION : { },
			}
			value = UnitData.new({
				"max_health": 500,
				"attack": 25,
				"num_units": 1,
				"actions": actions,
				"path_base_sprites": Constants.PATH_SPRITES_COMMANDERS
			})
		"knight":
			var actions := {  ## must use {Action Type, script name} (NOT class name)
				Constants.ActionType.ATTACK : [
					"smash",
					"wand_blast",
				],
				Constants.ActionType.REACTION : { },
			}
			value = UnitData.new({
				"max_health": 100,
				"attack": 25,
				"num_units": 1,
				"actions": actions,
				"path_base_sprites": Constants.PATH_SPRITES_COMMANDERS
			})
	
	return value

extends Node
## A store for all reference data.
##
## Read Only.

func get_unit_data(unit_name: String, unit_type := Constants.UnitType.AI_NORMAL) -> UnitData:
	var value: UnitData = null
	
	var states := _get_states_for(unit_type)
	
	match unit_name:
		"copper_golem":
			var actions = {  ## must use {Action Type, script name} (NOT class name)
				Constants.ActionType.ATTACK : [
					"smash",
				],
				Constants.ActionType.REACTION : {
					Constants.ActionTrigger.ON_RECEIVE_DAMAGE : [
						"spiky_shell",
					]
				}
			}
			value = UnitData.new({
				"actions": actions,
				"states": states,
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
				"states": states,
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
				"states": states,
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
				"path_base_sprites": Constants.PATH_SPRITES_COMMANDERS,
				"states": states,
				"states_base_folder": "player_actor",
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
				"path_base_sprites": Constants.PATH_SPRITES_COMMANDERS,
				"states": states,
				"states_base_folder": "ai_commander",
			})
	
	return value


func _get_states_for(unit_type: Constants.UnitType) -> Array[Constants.ActorState]:
	var states : Array[Constants.ActorState] = []
	
	match unit_type:
		Constants.UnitType.AI_NORMAL:
			states = [
				Constants.ActorState.IDLING,
				Constants.ActorState.CASTING,
				Constants.ActorState.ATTACKING,
				Constants.ActorState.PURSUING,
				Constants.ActorState.DEAD,
			]
		Constants.UnitType.PLAYER_ACTOR:
			states = [
				Constants.ActorState.IDLING,
				Constants.ActorState.CASTING,
				Constants.ActorState.ATTACKING,
				Constants.ActorState.PLAYER_MOVING,
				Constants.ActorState.DEAD,
			]
		Constants.UnitType.AI_COMMANDER:
			states = [
				Constants.ActorState.IDLING,
				Constants.ActorState.CASTING,
				Constants.ActorState.ATTACKING,
				Constants.ActorState.PURSUING,
				Constants.ActorState.FLEEING,
				Constants.ActorState.DEAD,
			]
		_:
			push_error("Undefined unit_type: %s"%[Constants.UnitType.keys()[unit_type]])
	
	return states

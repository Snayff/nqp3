extends Node
## A store for all reference data.
##
## Read Only.

const unit_data: Dictionary = {
	"copper_golem": {
		"max_health": 100,
		"regen": 100,
		"dodge": 100,
		"magic_defence": 100,
		"mundane_defence": 100,
		"attack": 50,
		"attack_speed": 100,
		"damage_type": Constants.DamageType.MUNDANE,
		"penetration": 100,
		"crit_chance": 100,
		"attack_range": Constants.MELEE_RANGE,
		"move_speed": 150,
		"stamina": 10,
		"num_units": 10,
		"faction": "faction1",
		"gold_cost": 100,
		"tier": 1,
		"actions": {  ## must use {Action Type, script name} (NOT class name)
			Constants.ActionType.ATTACK : [
				"basic_attack"
			]
		}
	},
	"conjurer": {
		"max_health": 40,
		"regen": 100,
		"dodge": 100,
		"magic_defence": 100,
		"mundane_defence": 100,
		"attack": 33,
		"attack_speed": 100,
		"damage_type": Constants.DamageType.MUNDANE,
		"penetration": 100,
		"crit_chance": 100,
		"attack_range": 70,
		"move_speed": 200,
		"stamina": 10,
		"num_units": 6,
		"faction": "faction1",
		"gold_cost": 100,
		"tier": 1,
		"actions": {  ## must use Action Type, script name (NOT class name)
			Constants.ActionType.ATTACK : [
				"basic_attack"
			],
			Constants.ActionType.REACTION : {
				Constants.ActionTriggerType.ON_DEAL_DAMAGE : [
					"spiky_shell"
				]
			}
		}
	},

}

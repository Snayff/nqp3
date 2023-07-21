extends Node
## A store for all reference data.
##
## Read Only.

const unit_data: Dictionary = {
	"copper_golem": {
		"max_health": 100,
		"max_stamina": 100,
		"regen": 100,
		"dodge": 100,
		"magic_defence": 10,
		"mundane_defence": 10,
		"attack": 50,
		"attack_speed": 100,
		"penetration": 100,
		"crit_chance": 100,
		"move_speed": 150,
		"stamina": 10,
		"num_units": 6,
		"faction": "faction1",
		"gold_cost": 100,
		"tier": 1,
		"actions": {  ## must use {Action Type, script name} (NOT class name)
			Constants.ActionType.ATTACK : [
				"smash"
			],
			Constants.ActionType.REACTION : { },
		}
	},
	"conjurer": {
		"max_health": 70,
		"max_stamina": 100,
		"regen": 100,
		"dodge": 100,
		"magic_defence": 2,
		"mundane_defence": 3,
		"attack": 33,
		"attack_speed": 100,
		"penetration": 100,
		"crit_chance": 100,
		"move_speed": 200,
		"stamina": 10,
		"num_units": 10,
		"faction": "faction1",
		"gold_cost": 100,
		"tier": 1,
		"actions": {  ## must use Action Type, script name (NOT class name)
			Constants.ActionType.ATTACK : [
				"wand_blast",
				"heal"
			],
			Constants.ActionType.REACTION : {
				Constants.ActionTrigger.ON_DEAL_DAMAGE : [
					"spiky_shell"
				]
			}
		}
	},

}

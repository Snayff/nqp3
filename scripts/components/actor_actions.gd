class_name ActorActions extends Node
## data and functionality for an actors actions

signal attacked  ## emitted when completed attack

var attacks : Dictionary = {}  ## {uid, BaseAction}
var reactions: Dictionary = {}  ## {ReactionTriggerType, {uid, BaseAction}}
var has_ready_attack: bool:
	get:
		for action in attacks.values():
			if action.is_ready:
				return true
		return false
	set(value):
		push_warning("Tried to set has_ready_attack directly. Not allowed.")

func _ready() -> void:
	pass
	# N.B. _ready called too late to init triggers

func add_attack(attack: BaseAction) -> void:
	attacks[attack.uid] = attack


func remove_attack(uid: int) -> void:
	attacks.erase(uid)


func add_reaction(reaction: BaseAction, trigger: Constants.ActionTriggerType) -> void:
	if not trigger in reactions:
		reactions[trigger] = {}

	reactions[trigger][reaction.uid] = reaction


func remove_reaction(trigger: Constants.ActionTriggerType, uid: int) -> void:
	reactions[trigger].erase(uid)


## use all actions of given type, reset cooldown after use
func trigger_reactions(trigger: Constants.ActionTriggerType, target: Actor) -> void:
	if not trigger in reactions:
		return

	for reaction in reactions[trigger].values():
		if reaction.is_ready():
			print(name + " used " + reaction.friendly_name + ".")
			reaction.use(target)
			reaction.reset_cooldown()


## use a specific attack and reset cooldown
func use_attack(uid: int, target: Actor) -> void:
	if not uid in attacks:
		push_warning("Tried to use attack that doesnt exist.")

	var attack = attacks[uid]
	if not attack.is_ready():
		push_warning("Tried to use attack, (" + attack.friendly_name + ") that isnt.")

	attack.use(target)
	attack.reset_cooldown()

	emit_signal("attacked")

## use a random, ready attack. resets cooldown.
##
## preference given to non basic attacks
func use_random_attack(target: Actor) -> void:
	var attack_to_use : BaseAction
	for action in attacks.values():
		if action.is_ready:
			# we want to use other attacks before basic attack, if we have found one, use it.
			if not action is BasicAttack:
				attack_to_use = action
				break
			else:
				attack_to_use = action

	# check we have an attack
	if attack_to_use == null:
		push_warning("Tried to use attack, but no attack ready.")
	else:
		print(name + " used " + attack_to_use.friendly_name + ".")
		attack_to_use.use(target)
		attack_to_use.reset_cooldown()

		emit_signal("attacked")


## put all actions on cooldown
func reset_actions() -> void:
	for attack in attacks.values():
		attack.reset_cooldown()

	for trigger in reactions.keys():
		for reaction in reactions[trigger].values():
			reaction.reset_cooldown()
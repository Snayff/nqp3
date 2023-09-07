class_name ActorActions extends Node
## data and functionality for an actors actions

signal attacked  ## emitted when completed an attack
signal attack_range_updated(new_range: int)  ## emitted when attack range recalculated

var attacks : Dictionary = {}  ## {uid, BaseAction}
var reactions : Dictionary = {}  ## {ReactionTriggerType, {uid, BaseAction}}
var _lowest_attack_range : int = 9999  ## holds last caclulated value for lowest range of all attacks
var lowest_attack_range : int :  ## public interface for lowest attack range
	## FIXME: never go below lowest attack range; current when all atatcks on cd we run at enemy
	get:
		# return the calculated value. assumes recalculated elsewhere when dirty
		return _lowest_attack_range
	set(_value):
		push_warning("Tried to set lowest_attack_range directly. Not allowed.")
var has_ready_attack : bool:
	get:
		for action in attacks.values():
			if action.is_ready:
				return true
		return false
	set(_value):
		push_warning("Tried to set has_ready_attack directly. Not allowed.")


func _ready() -> void:
	# N.B. _ready called too late to init triggers
	pass


######## ATTACKS #############

func add_attack(attack: BaseAction) -> void:
	attacks[attack.uid] = attack
	_recalculate_attack_range()


func remove_attack(uid: int) -> void:
	attacks.erase(uid)
	_recalculate_attack_range()

## use a specific attack and reset cooldown
func use_attack(uid: int, target: Actor) -> void:
	if not uid in attacks:
		push_warning("Tried to use attack that doesnt exist.")

	var attack = attacks[uid]
	if not attack.is_ready:
		push_warning("Tried to use attack (" + attack.friendly_name + ") that isnt ready.")

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
			attack_to_use = action

	# check we have an attack
	if attack_to_use == null:
		push_warning("Tried to use attack, but no attack ready.")
	else:
		attack_to_use.use(target)
		attack_to_use.reset_cooldown()

		emit_signal("attacked")


## get a random attack, from those available. Can return null
func get_random_attack() -> BaseAction:
	var attack_to_use : BaseAction
	for action in attacks.values():
		if action.is_ready:
			attack_to_use = action

	return attack_to_use


########### REACTIONS #############

func add_reaction(reaction: BaseAction, trigger: Constants.ActionTrigger) -> void:
	if not trigger in reactions:
		reactions[trigger] = {}

	reactions[trigger][reaction.uid] = reaction


func remove_reaction(trigger: Constants.ActionTrigger, uid: int) -> void:
	reactions[trigger].erase(uid)


## use all actions of given type, reset cooldown after use
func trigger_reactions(trigger: Constants.ActionTrigger, target: Actor) -> void:
	if not trigger in reactions:
		return
	
	for reaction in reactions[trigger].values():
		if reaction.is_ready:
			print(name +  " used " + reaction.friendly_name + ".")
			reaction.use(target)
			reaction.reset_cooldown()


######### STATE MANAGEMENT ###########

## put all actions on cooldown
func reset_actions() -> void:
	for attack in attacks.values():
		attack.reset_cooldown()

	for trigger in reactions.keys():
		for reaction in reactions[trigger].values():
			reaction.reset_cooldown()


## updates lowest attack range
func _recalculate_attack_range() -> void:
	_lowest_attack_range = 9999
	for attack in attacks.values():
		if attack.range < _lowest_attack_range:
			_lowest_attack_range = attack.range

	emit_signal("attack_range_updated", lowest_attack_range)

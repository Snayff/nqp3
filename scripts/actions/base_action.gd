class_name BaseAction extends Node
## base class for a combat action for actors


########### CONFIG #############

@export_group("config")
@export var friendly_name : String = ""
@export var tags : Array[Constants.ActionTag] = []
@export var valid_target_types : Array[Constants.TargetType] = []
@export var trigger : Constants.ActionTriggerType = Constants.ActionTriggerType.ATTACK
@export var action_type : Constants.ActionType = Constants.ActionType.ATTACK
@export var _base_stamina_cost : int = 0
@export var _base_cooldown : float = 0.0
@export var _base_damage : int = 0
@export var _base_damage_type : Constants.DamageType = Constants.DamageType.MUNDANE

@export_group("", "")  # end grouping

######### ATTRIBUTES ##########

var uid : int
var _creator : Actor
var _target : Actor
var _cooldown_timer : Timer
## length of cooldown of action
var cooldown : float:
	get:
		# TODO: mod by creator stats
		return _base_cooldown
	set(value):
		push_warning("Tried to set cooldown directly. Not allowed.")
## amount of time left on cooldown
var cooldown_remaining : float:
	get:
		return _cooldown_timer.time_left
	set(value):
		push_warning("Tried to set cooldown_remaining directly. Not allowed.")
## check if action is ready to use
var is_ready : bool = true:
	get:
		return _cooldown_timer.is_stopped()
	set(value):
		push_warning("Tried to set is_ready directly. Not allowed.")
var is_targeting_self : bool = false
var is_targeting_all : bool = false

######### UI ##############

var icon : Texture

########### SETUP  ###########

func _init(creator: Actor) -> void:
	_creator = creator

	uid = Utility.generate_id()

	_cooldown_timer = Timer.new()
	_cooldown_timer.set_one_shot(true)

	_configure()
	_setup()


## configure the action's base data
func _configure() -> void:
	assert(false, "Virtual method not overriden.")


## last step of setup, post config
func _setup() -> void:
	set_cooldown(cooldown)


########### FUNCTIONALITY ###########

## use action on a target
##
## must call super in subclass; this updates _target and charges stamina cost
func use(initial_target: Actor) -> void:
	_target = initial_target
	Combat.reduce_stamina(_creator, _base_stamina_cost)


func set_cooldown(cooldown_time: float) -> void:
	# ignore if wait time == 0
	if cooldown_time > 0:
		_cooldown_timer.wait_time = cooldown_time
		_cooldown_timer.start()


func reset_cooldown() -> void:
	set_cooldown(cooldown)

########### ATTIBUTE GETTERS ###############

## @tag: virtual method
func get_description() -> String:
	assert(false, "Virtual method not overriden.")
	return "No description set"


########## EFFECTS ##############

## get new target
func _effect_new_target(preference: Constants.TargetPreference = Constants.TargetPreference.ANY) -> void:
	push_warning("new target: effect not created")


## apply amount of damage to current target
func _effect_damage(amount: int, damage_type: Constants.DamageType) -> void:
	Combat.deal_damage(_creator, _target, amount, damage_type)


## apply amount of damage to current target
func _effect_heal(amount: int) -> void:
	push_warning("heal: effect not created")


## apply a status effect to current target
func _effect_status(status_effect_name: String) -> void:
	var action_type = Constants.ActionType.STATUS_EFFECT
	var script_path : String = Utility.get_action_type_script_path(action_type) + status_effect_name + ".gd"
	var status_effect = load(script_path).new(_target)


## create a projectile. returns created projectile
func _effect_projectile() -> NonCollidingProjectile:
	return Factory.create_projectile(_creator, _target)


## create a summon
func _effect_summon(summon) -> void:
	push_warning("summon: effect not created")


## create terrain
func _effect_terrain(terrain) -> void:
	push_warning("terrain: effect not created")


## visual, such as animation
func _effect_visual(visual) -> void:
	push_warning("visual: effect not created")


## apply force as a vector
func _effect_apply_force(velocity) -> void:
	push_warning("apply_force: effect not created")


## teleport to new location
func _effect_teleport(direction, distance) -> void:
	push_warning("teleport: effect not created")

class_name Actor extends CharacterBody2D
## An individual combatant.

########## SIGNALS ##################

## emitted when unit selected
signal selected_unit(actor: Actor)  # FIXME: I dont think this is right, we select unit but get actor?
## emitted when is_targetable changed to false
signal no_longer_targetable
## emitted when successfully dealt damage
signal dealt_damage(amount: int, damage_type: Constants.DamageType)
## emitted when received damage
signal took_damage(amount: int, damage_type: Constants.DamageType)
## took a hit, includes the actor attacking us
signal hit_received(attacker: Actor)
## emitted when died
signal died


############## NODES ##################

@onready var _navigation_agent : NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var _collision_shape : CollisionShape2D = $CollisionShape2D

############ COMPONENTS ###############
# these are initialised on creation by Factory

## resource that manages both the base and final stats for the actor.
##
## added to combatant on init by Unit
var stats : ActorStats  # cant be private due to needing access to all its attributes
## decision making
var _ai : BaseAI
## Each action's data stored in this array represents an action the actor can perform.
##
## Dict of Array of Actions; Dictionary[ActionType, Array[BaseAction]]
var _actions : ActorActions
var _status_effects : ActorStatusEffects

######### FUNCTIONAL ATTRIBUTES ###############

var uid : int
var _previous_state : Constants.ActorState = Constants.ActorState.IDLE
var _state : Constants.ActorState = Constants.ActorState.IDLE
var _target : Actor
var _facing : Constants.Direction = Constants.Direction.LEFT
var is_active : bool:
	get:
		return is_active
	set(value):
		is_active = value
		set_process(is_active)
var is_targetable : bool:
	get:
		return is_targetable
	set(value):
		is_targetable = value
		if not value:
			no_longer_targetable.emit()
var has_ready_attack : bool:
	get:
		return _actions.has_ready_attack
	set(_value):
		push_warning("Tried to set has_ready_attack directly. Not allowed.")
var is_melee : bool:
	get:
		if stats.attack_range == Constants.MELEE_RANGE:
			return true
		return false
	set(_value):
		push_warning("Tried to set is_melee directly. Not allowed.")

######### UI ATTRIBUTES ###############

var is_selected : bool = false:
	get:
		return is_selected
	set(value):
		if value and is_selectable:
			is_selected = value
			emit_signal("selected_unit", self)
var is_selectable : bool = true:
	get:
		return is_selectable
	set(value):
		is_selectable = value
		if not is_selectable:
			is_selected = false

var neighbours : Array

######### SETUP #############

func _ready() -> void:
	uid = Utility.generate_id()

	_ai = BaseAI.new()  # TODO: should be added in factory based on unit data
	add_child(_ai)


## post _ready setup
func actor_setup() -> void:

	_connect_signals()

	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	refresh_target()


## connect up all relevant signals for actor
##
## must be called after ready due to being created in Factory and components not being available
func _connect_signals() -> void:
	# conect to signals
	died.connect(_on_death)
	hit_received.connect(_on_hit_received)

	# connect to component signals
	stats.health_depleted.connect(_on_health_depleted)
	stats.stamina_depleted.connect(_on_stamina_depleted)

	# link component signals
	_status_effects.stat_modifier_added.connect(stats.add_modifier)
	_status_effects.stat_modifier_removed.connect(stats.remove_modifier)

	_actions.attacked.connect(_on_attack)

########## MAIN LOOP ##########

func _physics_process(delta) -> void:

	if is_in_group("alive"):
		update_state()
		process_current_state()

########## STATE #############

## update the current state
func update_state() -> void:
	# if we have target, move towards them, else get new
	if _target != null:
		# attack if in range, else move closer
		_navigation_agent.target_position = _target.global_position
		var in_attack_range : bool = _navigation_agent.distance_to_target() <= stats.attack_range
		if in_attack_range and has_ready_attack:
			_navigation_agent.target_position = global_position
			if _state != Constants.ActorState.ATTACKING:
				change_state(Constants.ActorState.ATTACKING)

		# has target but not in range, move towards target
		else:
			if _state != Constants.ActorState.MOVING:
				change_state(Constants.ActorState.MOVING)

	# has no target, go idle
	else:
		if _state != Constants.ActorState.MOVING:
			change_state(Constants.ActorState.IDLE)


## change to new state, trigger transition action
## actions will trigger after animation
func change_state(new_state: Constants.ActorState) -> void:
	_previous_state = _state
	_state = new_state

	match _state:
		Constants.ActorState.IDLE:
			animated_sprite.play("idle")

		Constants.ActorState.ATTACKING:
			animated_sprite.play("attack")

		Constants.ActorState.MOVING:
			animated_sprite.play("walk")

		Constants.ActorState.DEAD:
			animated_sprite.play("death")


## process the current state, e.g. moving if in MOVING
func process_current_state() -> void:
	match _state:
		Constants.ActorState.IDLE:
			refresh_target()

		Constants.ActorState.ATTACKING:
			pass

		Constants.ActorState.MOVING:
			move_towards_target()
			_refresh_facing()

		Constants.ActorState.DEAD:
			pass

######### ACTIONS ############


## move towards next target using the nav path
func move_towards_target() -> void:
	# get next destination
	var target_pos : Vector2 = _navigation_agent.get_next_path_position()

	var social_distancing_force : Vector2

	var social_loop_limit : int = 7
	var distance_to_target : float = _target.global_position.distance_to(self.global_position)

	for i in mini(neighbours.size(), social_loop_limit):
		var neighbour = neighbours[i]
		var p1 : Vector2 = self.global_position
		var p2 : Vector2 = neighbour.global_position
		var distance : float = p1.distance_to(p2)
		if distance < distance_to_target and _ai.is_enemy(neighbour):
			_target = neighbour
			distance_to_target = distance
		var p3 : Vector2 = p1.direction_to(p2) * maxf((100 - distance * 2), 0)
		social_distancing_force -= p3

	if neighbours.size() > social_loop_limit:
		# Approximate the remaining social distancing force that we didn't
		# bother calculating
		social_distancing_force *= neighbours.size() / float(social_loop_limit)

	# determine route
	var direction : Vector2 = global_position.direction_to(target_pos)
	var desired_velocity : Vector2 = direction * stats.move_speed
	var steering : Vector2 = (desired_velocity - velocity)

	# update velocity
	velocity += steering + social_distancing_force

	move_and_slide()


## enact actor's death
func die() -> void:
	add_to_group("dead")
	remove_from_group("alive")

	_collision_shape.call_deferred("set_disabled", true)  # need to call deferred as otherwise locked

	animated_sprite.stop()  # its already looped back to 0 so pause == stop
	animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("death")

	emit_signal("died")

	print(name + " died.")


## execute actor's attack
func attack() -> void:
	_actions.use_random_attack(_target)


## add status effect to actor
func add_status_effect(status_effect: BaseStatusEffect) -> void:
	_status_effects.add_status_effect(status_effect)


## remove a status effect by its uid
func remove_status_effect(uid_: int) -> void:
	_status_effects.remove_status_effect(uid_)

############ REACTIONS ###########

## act out result of animations completion
func process_animation_completion() -> void:
	match _state:
		Constants.ActorState.IDLE:
			# just keep idling
			pass

		Constants.ActorState.ATTACKING:
			attack()

		Constants.ActorState.MOVING:
			# walking not dependant on anim completion
			pass

		Constants.ActorState.DEAD:
			die()


## trigger death
## signal emitted by stats
func _on_health_depleted() -> void:
	# immediately remove targetable, dont wait for animation to finish
	is_active = false
	is_targetable = false
	change_state(Constants.ActorState.DEAD)


func _on_hit_received(attacker: Actor) -> void:
	# flash damage indicator
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 1)

	_actions.trigger_reactions(Constants.ActionTrigger.ON_RECEIVE_DAMAGE, attacker)


func _on_death() -> void:
	_actions.trigger_reactions(Constants.ActionTrigger.ON_DEATH, self)


func _on_attack() -> void:
	_actions.trigger_reactions(Constants.ActionTrigger.ON_ATTACK, self)


func _on_stamina_depleted() -> void:
	# TODO: apply exhausted status effect
	pass

########### REFRESHES #############

## get new target and update _ai and nav's target
func refresh_target() -> void:
	# disconnect from current signals on target
	if _target:
		_target.no_longer_targetable.disconnect(refresh_target)

	# get new target
	_target = _ai.get_target()

	# relisten to target changes
	_target.no_longer_targetable.connect(refresh_target)

	# update nav agent's target
	_navigation_agent.set_target_position(_target.global_position)

func _refresh_facing() -> void:
	if velocity.x < 0:
		self._facing = Constants.Direction.LEFT
		animated_sprite.flip_h = true
	else:
		self._facing = Constants.Direction.RIGHT
		animated_sprite.flip_h = false

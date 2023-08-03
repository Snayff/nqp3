class_name Actor extends CharacterBody2D
## An individual combatant.
##
## Acts as an interface for inner components, such as [ActorActions].

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
## emitted when health restored
signal was_healed(amount: int)
## emitted when heal someone
signal healed_someone(amount: int)
## emitted when new attack chosen
signal chose_attack_to_cast(attack: BaseAction)


############## NODES ##################

@onready var _navigation_agent : NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D  # TODO: can we make this private?
@onready var _collision_shape : CollisionShape2D = $CollisionShape2D
@onready var _target_finder : Area2D = $TargetFinder
@onready var _target_refresh_timer : Timer = $TargetRefreshTimer
@onready var _cast_timer : Timer = $CastTimer

############ COMPONENTS ###############
# these are initialised on creation by Factory

## resource that manages both the base and final stats for the actor.
##
## added to actor on init by Unit
var stats : ActorStats  # cant be private due to needing access to all its attributes
## decision making
var ai : ActorAI
## all of an actor's actions
var actions : ActorActions
## active status effects
var status_effects : ActorStatusEffects
## state machine that controls current state
var state_machine : StateMachine

######### FUNCTIONAL ATTRIBUTES ###############

var uid : int
## unit name. recalcs debug name on set.
var unit_name: String:
	set(value):
		unit_name = value
		debug_name = unit_name + "(" + str(uid) + ")"
var debug_name : String = unit_name + "(" + str(uid) + ")"
var _previous_state : Constants.ActorState = Constants.ActorState.IDLING
var _state : Constants.ActorState = Constants.ActorState.IDLING
var _target : Actor
var _facing : Constants.Direction = Constants.Direction.LEFT
var is_active : bool:
	set(value):
		is_active = value
		set_process(is_active)
var is_targetable : bool:
	set(value):
		is_targetable = value
		if not value:
			no_longer_targetable.emit()
var has_ready_attack : bool:
	get:
		return actions.has_ready_attack
	set(_value):
		push_warning("Tried to set has_ready_attack directly. Not allowed.")
var is_melee : bool:
	get:
		if attack_to_cast:
			if attack_to_cast.range <= Constants.MELEE_RANGE:
				return true
		return false
	set(_value):
		push_warning("Tried to set is_melee directly. Not allowed.")
var attack_to_cast : BaseAction = null:
	set(value):
		attack_to_cast = value
		if attack_to_cast != null:
			_update_target_finder_range(attack_to_cast.range)
			print(debug_name + " chose to use " + attack_to_cast.friendly_name + ".")
var neighbours : Array

######### UI ATTRIBUTES ###############

var is_selected : bool = false:
	set(value):
		if value and is_selectable:
			is_selected = value
			emit_signal("selected_unit", self)
var is_selectable : bool = true:
	set(value):
		is_selectable = value
		if not is_selectable:
			is_selected = false


######### SETUP #############

func _ready() -> void:
	pass


## post _ready setup
func actor_setup() -> void:
	_connect_signals()
	
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	# Trigger enter function on initial state
	state_machine.change_state(state_machine._current_state_name)
	
	# with actions fully initialised lets force the attack_range_updated signal to fire
	actions._recalculate_attack_range()
	
	# Now that the navigation map is no longer empty, set the movement target.
	_attempt_target_refresh()


## connect up all relevant signals for actor
##
## must be called after ready due to being created in Factory and components not being available
func _connect_signals() -> void:
	# conect to own signals
	died.connect(_on_death)
	hit_received.connect(_on_hit_received)

	# connect to (script) component signals
	stats.health_depleted.connect(_on_health_depleted)
	stats.stamina_depleted.connect(_on_stamina_depleted)

	actions.attacked.connect(_on_attack)

	# link component signals
	status_effects.stat_modifier_added.connect(stats.add_modifier)
	status_effects.stat_modifier_removed.connect(stats.remove_modifier)

########## MAIN LOOP ##########

func _physics_process(delta) -> void:
	if is_in_group("alive"):
		state_machine.update_state()

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
		if distance < distance_to_target and ai.is_enemy(neighbour):
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

	stats.health = 0

	_collision_shape.call_deferred("set_disabled", true)  # need to call deferred as otherwise locked

	animated_sprite.stop()  # its already looped back to 0 so pause == stop
	animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("death")

	died.emit()

	print(debug_name + " died.")


## execute actor's attack.
## this is a random attack if attack_to_cast is null.
func attack() -> void:
	if attack_to_cast == null:
		actions.use_random_attack(_target)
	else:
		actions.use_attack(attack_to_cast.uid, _target)
	
	attack_to_cast = null


############ REACTIONS ###########

## on health <= 0; trigger death
##
## signal emitted by stats
func _on_health_depleted() -> void:
	# immediately remove targetable, dont wait for animation to finish
	is_active = false
	is_targetable = false
	state_machine.change_state(Constants.ActorState.DEAD)


func _on_hit_received(attacker: Actor) -> void:
	# flash damage indicator
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)  # FIXME: never goes back to normal colour

	actions.trigger_reactions(Constants.ActionTrigger.ON_RECEIVE_DAMAGE, attacker)


func _on_death() -> void:
	actions.trigger_reactions(Constants.ActionTrigger.ON_DEATH, self)


func _on_attack() -> void:
	actions.trigger_reactions(Constants.ActionTrigger.ON_ATTACK, self)


## on stamina <= 0; apply Exhaustion status effect
##
## signal emitted by stats
func _on_stamina_depleted() -> void:
	var exhaustion = Exhaustion.new(self)
	status_effects.add_status_effect(exhaustion)


########### REFRESHES #############

## checks conditions for refresh and if they pass will refresh target
func _attempt_target_refresh(
	target_type: Constants.TargetType = Constants.TargetType.ENEMY,
	preferences: Array[Constants.TargetPreference] = [Constants.TargetPreference.ANY]
	) -> void:
	if _target_refresh_timer.is_stopped():
		refresh_target(target_type, preferences)
		_target_refresh_timer.start(1)


## get new target and update ai and nav's target
func refresh_target(
	target_type: Constants.TargetType = Constants.TargetType.ENEMY,
	preferences: Array[Constants.TargetPreference] = [Constants.TargetPreference.ANY]
	) -> void:
	# disconnect from current signals on target
	if _target:
		if _target.no_longer_targetable.is_connected(refresh_target):
			_target.no_longer_targetable.disconnect(refresh_target)

	# get new target
	_target = ai.get_target(target_type, preferences)

	# FIXME: placeholder until Unit AI added
	if _target == null:
		var group_to_target : String = Utility.get_target_group(self, Constants.TargetType.ENEMY)
		_target = get_tree().get_nodes_in_group(group_to_target)[0]   # just pick the first enemy node and move towards them, eventually will be in range
		print(debug_name + " randomly picked " + _target.debug_name + " to run towards.")

	# relisten to target changes
	if not _target.is_connected("no_longer_targetable", refresh_target):
		_target.no_longer_targetable.connect(refresh_target)

	# update nav agent's target
	_navigation_agent.set_target_position(_target.global_position)

	var timer_min : float = 0.9
	var timer_max : float = 1.1
	_target_refresh_timer.start(randf_range(timer_min, timer_max))


func _refresh_facing() -> void:
	if velocity.x < 0:
		self._facing = Constants.Direction.LEFT
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		self._facing = Constants.Direction.RIGHT
		animated_sprite.flip_h = false

## update the size of the target finder
func _update_target_finder_range(new_range: int) -> void:
	_target_finder.radius =  new_range
	print(debug_name + " set target finder's range to " + str(_target_finder.radius) + ".")

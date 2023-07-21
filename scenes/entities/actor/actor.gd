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
var _ai : ActorAI
## all of an actor's actions
var _actions : ActorActions
## active status effects
var _status_effects : ActorStatusEffects

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
		return _actions.has_ready_attack
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
			print(debug_name + "chose to use " + attack_to_cast.friendly_name)
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

	# with _actions fully initialised lets force the attack_range_updated signal to fire
	_actions._recalculate_attack_range()

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

	_actions.attacked.connect(_on_attack)

	_cast_timer.timeout.connect(_on_cast_completed)

	# link component signals
	_status_effects.stat_modifier_added.connect(stats.add_modifier)
	_status_effects.stat_modifier_removed.connect(stats.remove_modifier)

	# connect to node signals
	animated_sprite.animation_finished.connect(_on_animation_completed)
	animated_sprite.animation_looped.connect(_on_animation_completed)

########## MAIN LOOP ##########

func _physics_process(delta) -> void:

	if is_in_group("alive"):
		update_state()
		process_current_state()

########## STATE #############

## update the current state
func update_state() -> void:
	# dont change state if dead
	if _state == Constants.ActorState.DEAD:
		return

	## if we have no attack primed then get one
	if attack_to_cast == null:
		attack_to_cast = _actions.get_random_attack()

		# get new target
		if attack_to_cast != null:
			_attempt_target_refresh(attack_to_cast.target_type)
		else:
			_attempt_target_refresh()

	# has no target, go idle
	if _target == null:
		if _state != Constants.ActorState.MOVING:
			change_state(Constants.ActorState.IDLING)
		return

	# we have target, but do we have an attack
	if attack_to_cast == null:
		if _state != Constants.ActorState.MOVING:
			change_state(Constants.ActorState.IDLING)
		return

	# we have target and attack so cast if in range, else move closer
	_navigation_agent.target_position = _target.global_position
	var in_attack_range : bool = _navigation_agent.distance_to_target() <= attack_to_cast.range
	if in_attack_range and has_ready_attack:
		# set target pos to current pos to stop moving
		_navigation_agent.target_position = global_position

		# if not yet attacking or casting, cast
		if _state != Constants.ActorState.ATTACKING and _state != Constants.ActorState.CASTING:
			change_state(Constants.ActorState.CASTING)  #  attack is triggered after cast

	# has target but not in range, move towards target
	elif not in_attack_range and has_ready_attack:
		if _state != Constants.ActorState.MOVING:
			change_state(Constants.ActorState.MOVING)

	else:
		change_state(Constants.ActorState.IDLING)


## change to new state, trigger transition action
## actions will trigger after animation
func change_state(new_state: Constants.ActorState) -> void:
	_previous_state = _state
	_state = new_state

	match _state:
		Constants.ActorState.IDLING:
			animated_sprite.play("idle")

		Constants.ActorState.CASTING:
			animated_sprite.play("cast")

			# trigger cast timer
			_cast_timer.start(attack_to_cast.cast_time)

		Constants.ActorState.ATTACKING:
			animated_sprite.play("attack")

		Constants.ActorState.MOVING:
			animated_sprite.play("walk")

		Constants.ActorState.DEAD:
			animated_sprite.play("death")

	# print(debug_name + " currently playing " + animated_sprite.animation + " animation.")


## process the current state, e.g. moving if in MOVING
func process_current_state() -> void:
	match _state:
		Constants.ActorState.IDLING:
			pass

		Constants.ActorState.CASTING:
			pass

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

	stats.health = 0

	_collision_shape.call_deferred("set_disabled", true)  # need to call deferred as otherwise locked

	animated_sprite.stop()  # its already looped back to 0 so pause == stop
	animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("death")

	emit_signal("died")

	print(debug_name + " died.")


## execute actor's attack.
## this is a random attack if attack_to_cast is null.
func attack() -> void:
	if attack_to_cast == null:
		_actions.use_random_attack(_target)
	else:
		_actions.use_attack(attack_to_cast.uid, _target)

	attack_to_cast = null


## add status effect to actor
func add_status_effect(status_effect: BaseStatusEffect) -> void:
	_status_effects.add_status_effect(status_effect)


## remove a status effect by its uid
func remove_status_effect(uid_: int) -> void:
	_status_effects.remove_status_effect(uid_)


## remove all status effects by type
func remove_status_effect_by_type(status_effect: BaseStatusEffect) -> void:
	_status_effects.remove_status_effect_by_type(status_effect)


############ REACTIONS ###########

## act out result of animations completion
func _on_animation_completed() -> void:
	match _state:
		Constants.ActorState.IDLING:
			# just keep idling
			pass

		Constants.ActorState.CASTING:
			# casting will time out and move to next state
			pass

		Constants.ActorState.ATTACKING:
			attack()

		Constants.ActorState.MOVING:
			# walking not dependant on anim completion
			pass

		Constants.ActorState.DEAD:
			# FIXME: we're never hitting this. dont seem to ever enter death anim
			die()


## on health <= 0; trigger death
##
## signal emitted by stats
func _on_health_depleted() -> void:
	# immediately remove targetable, dont wait for animation to finish
	is_active = false
	is_targetable = false
	change_state(Constants.ActorState.DEAD)


func _on_hit_received(attacker: Actor) -> void:
	# flash damage indicator
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)  # FIXME: never goes back to normal colour

	_actions.trigger_reactions(Constants.ActionTrigger.ON_RECEIVE_DAMAGE, attacker)


func _on_death() -> void:
	_actions.trigger_reactions(Constants.ActionTrigger.ON_DEATH, self)


func _on_attack() -> void:
	_actions.trigger_reactions(Constants.ActionTrigger.ON_ATTACK, self)

	# clear attack to cast
	attack_to_cast = null


## on stamina <= 0; apply exhausted status effect
##
## signal emitted by stats
func _on_stamina_depleted() -> void:
	var exhausted = Exhausted.new(self)
	add_status_effect(exhausted)


# on _cast_timer reaching 0; transition to attack
func _on_cast_completed() -> void:
	change_state(Constants.ActorState.ATTACKING)

########### REFRESHES #############

## checks conditions for refresh and if they pass will refresh target
func _attempt_target_refresh(target_type: Constants.TargetType = Constants.TargetType.ENEMY) -> void:
	if _target_refresh_timer.is_stopped():
		refresh_target(target_type)


## get new target and update _ai and nav's target
func refresh_target(target_type: Constants.TargetType = Constants.TargetType.ENEMY) -> void:
	# disconnect from current signals on target
	if _target:
		if _target.is_connected("no_longer_targetable", refresh_target):
			_target.no_longer_targetable.disconnect(refresh_target)

	# get new target
	_target = _ai.get_target(target_type)

	# FIXME: placeholder until Unit AI added
	if _target == null:
		var group_to_target : String
		if is_in_group("team1"):
			group_to_target = "team2"
		else:
			group_to_target = "team1"
		_target = get_tree().get_nodes_in_group(group_to_target)[0]   # just pick the first enemy node and move towards them, eventually will be in range

	# relisten to target changes
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
	else:
		self._facing = Constants.Direction.RIGHT
		animated_sprite.flip_h = false

## update the size of the target finder
func _update_target_finder_range(new_range: int) -> void:
	_target_finder.get_node("CollisionShape2D").shape.radius =  new_range
	print(debug_name + " set target finder's range to " + str(_target_finder.get_node("CollisionShape2D").shape.radius))

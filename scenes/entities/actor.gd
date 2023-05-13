class_name Actor extends CharacterBody2D
## An individual combatant.

########## SIGNALS ##################

## emitted when unit selected
signal selected_unit(actor: Actor)  # TODO: I dont think this is right, we select unit but get actor?
## emitted when is_targetable changed to false
signal no_longer_targetable
## emitted when successfully dealt damage
signal dealt_damage(amount: int, damage_type: Constants.DamageType)
## emitted when received damage
signal took_damage(amount: int, damage_type: Constants.DamageType)
## emitted when completed attack
signal attacked
## took a hit, includes actor attacking us
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
var stats : ActorStats

## decision making
var _ai: BaseAI

## Each action's data stored in this array represents an action the actor can perform.
##
## Dict of Array of Actions; Dictionary[ActionType, Array[BaseAction]]
var actions : Dictionary

######### FUNCTIONAL ATTRIBUTES ###############

var _previous_state := Constants.EntityState.IDLE
var _state := Constants.EntityState.IDLE
var _target : Actor
var _facing := Constants.Direction.LEFT
var is_active: bool:
	get:
		return is_active
	set(value):
		is_active = value
		set_process(is_active)
var is_targetable: bool:
	get:
		return is_targetable
	set(value):
		is_targetable = value
		if not value:
			no_longer_targetable.emit()
var has_ready_attack: bool:
	get:
		for action in actions[Constants.ActionType.ATTACK]:
			if action.is_ready:
				return true
		return false
	set(value):
		push_warning("Tried to set has_ready_attack directly. Not allowed.")
var is_melee : bool:
	get:
		if stats.attack_range == Constants.MELEE_RANGE:
			return true
		return false
	set(value):
		push_warning("Tried to set is_melee directly. Not allowed.")

######### UI ATTRIBUTES ###############

var is_selected: bool = false:
	get:
		return is_selected
	set(value):
		if value and is_selectable:
			is_selected = value
			emit_signal("selected_unit", self)
var is_selectable: bool = true:
	get:
		return is_selectable
	set(value):
		is_selectable = value
		if not is_selectable:
			is_selected = false

######### SETUP #############

func _ready() -> void:
	pass

## post _ready setup
func actor_setup() -> void:
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	_ai = BaseAI.new()
	add_child(_ai)

	# Now that the navigation map is no longer empty, set the movement target.
	refresh_target()

	# conect to signals
	stats.health_depleted.connect(_on_health_depleted)
	died.connect(_on_death)
	attacked.connect(_on_attack)
	hit_received.connect(_on_hit_received)

########## MAIN LOOP ##########

func _physics_process(delta) -> void:

	if is_in_group("alive"):

		# if we have reached the destination get a new target
		if _navigation_agent.is_navigation_finished():
				refresh_target()

		update_state()
		process_current_state()

########## STATE #############

## update the current state
func update_state() -> void:
	# if we have target, move towards them, else get new
	if _target != null:
		# attack if in range, else move closer
		var in_attack_range : bool = _navigation_agent.distance_to_target() <= stats.attack_range
		if in_attack_range and has_ready_attack:
			_navigation_agent.target_position = global_position
			if _state != Constants.EntityState.ATTACKING:
				change_state(Constants.EntityState.ATTACKING)

		# has target but not in range, move towards target
		else:
			if _state != Constants.EntityState.MOVING:
				change_state(Constants.EntityState.MOVING)

	# has no target, go idle
	else:
		if _state != Constants.EntityState.MOVING:
			change_state(Constants.EntityState.IDLE)

## change to new state, trigger transition action
## actions will trigger after animation
func change_state(new_state: Constants.EntityState) -> void:
	_previous_state = _state
	_state = new_state

	match _state:
		Constants.EntityState.IDLE:
			animated_sprite.play("idle")

		Constants.EntityState.ATTACKING:
			animated_sprite.play("attack")

		Constants.EntityState.MOVING:
			animated_sprite.play("walk")

		Constants.EntityState.DEAD:
			animated_sprite.play("death")

## process the current state, e.g. moving if in MOVING
func process_current_state() -> void:
	match _state:
		Constants.EntityState.IDLE:
			refresh_target()

		Constants.EntityState.ATTACKING:
			pass

		Constants.EntityState.MOVING:
			move_towards_target()
			_refresh_facing()

		Constants.EntityState.DEAD:
			pass

######### ACTIONS ############

## put all actions on cooldown
func _reset_actions() -> void:
	# loop dict then array
	for action_array in actions.values():
		for action in action_array:
			action.reset_cooldown()

## move towards next target using the nav path
func move_towards_target() -> void:
	# get next destination
	var target_pos : Vector2 = _navigation_agent.get_next_path_position()

	# determine route
	var direction : Vector2 = global_position.direction_to(target_pos)
	var desired_velocity : Vector2 = direction * stats.move_speed
	var steering := (desired_velocity - velocity)

	# update velocity
	velocity += steering
	_navigation_agent.set_velocity(velocity)

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
	var attack_to_use : BaseAction
	for action in actions[Constants.ActionType.ATTACK]:
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
		attack_to_use.use(_target)
		emit_signal("attacked")

############ REACTIONS ###########

## act out result of animations completion
func process_animation_completion() -> void:
	match _state:
		Constants.EntityState.IDLE:
			# just keep idling
			pass

		Constants.EntityState.ATTACKING:
			attack()

		Constants.EntityState.MOVING:
			# walking not dependant on anim completion
			pass

		Constants.EntityState.DEAD:
			die()

## trigger death
## signal emitted by stats
func _on_health_depleted() -> void:
	# immediately remove targetable, dont wait for animation to finish
	is_active = false
	is_targetable = false
	change_state(Constants.EntityState.DEAD)

func _on_hit_received(attacker: Actor) -> void:
	# flash damage indicator
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 1)

	_use_actions(Constants.ActionType.ON_HIT, attacker)

func _on_death() -> void:
	_use_actions(Constants.ActionType.ON_DEATH, self)

func _on_attack() -> void:
	_use_actions(Constants.ActionType.ON_ATTACK, self)

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

## use all actions of given type, reset cooldown after use
func _use_actions(action_type: Constants.ActionType, target_: Actor) -> void:
	for action in actions[action_type]:
		if action.is_ready:
			print(name + " used " + action.friendly_name + ".")
			action.use(target_)
			action.reset_cooldown()


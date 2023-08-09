extends Node
## A factory for object creation.
##
## "create" scripts build an object and return it. "add" scripts add the object to the specified object, i.e. handles add_child etc.

############ SCENES #########

# N.B. can't preload with variable, so all hardcoded
const _Actor : PackedScene = preload("res://scenes/entities/actor/actor.tscn")
const _Projectile: PackedScene = preload("res://scenes/entities/projectile/projectile.tscn")
const _Unit : PackedScene = preload("res://scenes/entities/unit/unit.tscn")
const _TargetFinder : PackedScene = preload("res://scenes/components/target_finder/target_finder.tscn")
const _VisualSparkles : PackedScene = preload("res://scenes/visual_effects/sparkles/sparkles.tscn")
const _VisualSimple : PackedScene = preload("res://scenes/visual_effects/simple_animation/simple_animation.tscn")



########### UNIT ###############

## create unit, pulling base data from RefData
func create_unit(creator, unit_name: String, team_name: String) -> Unit:
	var unit = _Unit.instantiate()
	if unit_name in ["knight", "cavalier"]:
		var script := load(Constants.PATH_COMMANDER)
		unit.set_script(script)

	unit.name = "%s_%s"%[unit_name, "unit"]
	creator.add_child(unit, true)

	unit.unit_name = unit_name
	unit.team = team_name

	return unit

############ ACTOR ##############

## create actor, pulling base data from RefData
func create_actor(creator: Unit, name_: String, team: String) -> Actor:
	var instance := _get_base_actor_instance(creator, name_, team)
	
	instance.state_machine = _create_actor_state_machine(instance)
	instance.state_machine.set_name("StateMachine")
	instance.add_child(instance.state_machine)
	
	instance.actor_setup()
	
	# now we're ready to react to the world
	instance.set_physics_process(true)
	
	return instance


## create actor, pulling base data from RefData
func create_player_actor(creator: Unit, name_: String, team: String) -> Actor:
	const PLAYER_ACTOR := preload("res://scenes/entities/actor/player_actor.gd")
	var instance := _get_base_actor_instance(creator, name_, team, PLAYER_ACTOR)
	
	instance.state_machine = _create_player_actor_state_machine(instance)
	instance.state_machine.set_name("StateMachine")
	instance.add_child(instance.state_machine)
	
	instance.actor_setup()
	
	# now we're ready to react to the world
	instance.set_physics_process(true)
	
	return instance


## create actor, pulling base data from RefData
func create_ai_commander(creator: Unit, name_: String, team: String) -> Actor:
	var instance := _get_base_actor_instance(creator, name_, team)
	
	instance.state_machine = _create_ai_commander_state_machine(instance)
	instance.state_machine.set_name("StateMachine")
	instance.add_child(instance.state_machine)
	
	instance.actor_setup()
	
	# now we're ready to react to the world
	instance.set_physics_process(true)
	
	return instance


func _get_base_actor_instance(
		creator: Unit, 
		name_ : String, 
		team : String,
		custom_script: Script = null
) -> Actor:
	var instance = _Actor.instantiate()
	if custom_script:
		instance.set_script(custom_script)
	instance.name = name_
	creator.add_child(instance, true)
	
	# dont do anything until we're ready
	instance.set_physics_process(false)

	var unit_data := RefData.get_unit_data(name_) as UnitData

	instance.uid = Utility.generate_id()
	instance.unit_name = name_
	instance.set_name(instance.debug_name.to_pascal_case())
	
	instance.ai = ActorAI.new(instance)
	instance.ai.set_name("AI")
	instance.add_child(instance.ai)
	
	instance.stats = _create_actor_stats(unit_data)
	instance.stats.set_name("Stats")
	instance.add_child(instance.stats)
	
	instance.animated_sprite.sprite_frames = _create_actor_sprite_frame(
			name_, unit_data.path_base_sprites
	)
	
	instance.status_effects = _create_actor_status_effects()
	instance.status_effects.set_name("StatusEffects")
	instance.add_child(instance.status_effects)
	
	instance = _add_actor_actions(instance, unit_data)
	
	# shuffle starting pos so they dont start on top of one another
	var pos_offset := Vector2(randf_range(-5, 5), randf_range(-5, 5))
	var pos := Vector2(creator.global_position.x + pos_offset.x, creator.global_position.y + pos_offset.y)
	instance.global_position = pos
	# TODO: ensure shuffling to empty spot
	
	instance = _add_actor_groups(instance, team)
	
	return instance


func _create_actor_stats(unit_data: UnitData) -> ActorStats:
	var stats = ActorStats.new()
	
	stats.max_health = unit_data.max_health
	stats.health = unit_data.max_health
	stats.max_stamina = unit_data.max_stamina
	stats.stamina = unit_data.max_stamina
	
	stats.base_regen = unit_data.regen
	stats.base_dodge = unit_data.dodge
	stats.base_magic_defence = unit_data.magic_defence
	stats.base_mundane_defence = unit_data.mundane_defence
	stats.base_attack = unit_data.attack
	stats.base_attack_speed = unit_data.attack_speed
	stats.base_crit_chance = unit_data.crit_chance
	stats.base_penetration = unit_data.penetration
	stats.base_move_speed = unit_data.move_speed
	
	stats.num_units = unit_data.num_units
	stats.faction = unit_data.faction
	stats.gold_cost = unit_data.gold_cost
	stats.tier = unit_data.tier
	
	return stats


func _create_actor_sprite_frame(unit_name: String, base_path: String) -> SpriteFrames:
	var anim_names : Array = Constants.ActorAnimationType.keys()
	var sprite_frames : SpriteFrames = SpriteFrames.new()
	
	for anim_name in anim_names:
		var path: String = base_path.path_join(unit_name).path_join(anim_name.to_lower())
		sprite_frames = Utility.add_animation_to_sprite_frames(
				sprite_frames, path, anim_name.to_lower()
		)
	
	return sprite_frames


func _create_actor_status_effects() -> ActorStatusEffects:
	var status_effects = ActorStatusEffects.new()
	return status_effects


func _add_actor_groups(instance: Actor, team: String) -> Actor:
	instance.add_to_group(team)
	instance.add_to_group("actor")
	instance.add_to_group("alive")

	return instance


func _add_actor_actions(instance: Actor, unit_data: UnitData) -> Actor:
	if unit_data.actions.is_empty():
		return instance
	
	var actions : ActorActions = ActorActions.new()
	
	for action_type in Constants.ActionType.values():
		
		# attacks are Dictionary[ActionType, Array[String]]
		if action_type == Constants.ActionType.ATTACK:
			for action_name in unit_data.actions[action_type]:
				var script := _get_action(instance, action_type, action_name)
				actions.add_attack(script)
				script.set_name(script.friendly_name)
				actions.add_child(script)
			
		# reactions are Dictionary[ActionType, Dictionary[ActionTrigger, Array[String]]
		elif action_type == Constants.ActionType.REACTION:
			for trigger in unit_data.actions[action_type]:
				for action_name in unit_data["actions"][action_type][trigger]:
					var script := _get_action(instance, action_type, action_name)
					actions.add_reaction(script, trigger)
					script.set_name(script.friendly_name)
					actions.add_child(script)
			
		else:
			# we only add attacks and reactions, ignore everything else
			continue
	
	# add actions to instance
	instance.actions = actions
	actions.set_name("Actions")
	instance.add_child(actions)
	
	return instance


func _get_action(
		instance: Actor, action_type: Constants.ActionType, action_name: String
) -> BaseAction:
	var script_path : String = \
			Utility.get_action_type_script_path(action_type).path_join(action_name + ".gd")
	var script : BaseAction = load(script_path).new(instance)
	return script


func _add_cast_timer(instance: Actor) -> Timer:
	# create timer to track cast time
	var cast_timer = Timer.new()
	cast_timer.name = "Cast"
	instance.add_child(cast_timer, true)
	cast_timer.set_one_shot(true)
	return cast_timer


func _create_actor_state_machine(actor: Actor) -> StateMachine:
	var states : Array[Constants.ActorState] = [
		Constants.ActorState.IDLING,
		Constants.ActorState.CASTING,
		Constants.ActorState.ATTACKING,
		Constants.ActorState.PURSUING,
		Constants.ActorState.DEAD,
	]
	
	var state_machine : StateMachine = StateMachine.new(actor, states)
	
	return state_machine


func _create_ai_commander_state_machine(actor: Actor) -> StateMachine:
	var states : Array[Constants.ActorState] = [
		Constants.ActorState.IDLING,
		Constants.ActorState.CASTING,
		Constants.ActorState.ATTACKING,
		Constants.ActorState.PURSUING,
		Constants.ActorState.FLEEING,
		Constants.ActorState.DEAD,
	]
	
	var state_machine : StateMachine = StateMachine.new(actor, states, "ai_commander")
	
	return state_machine


func _create_player_actor_state_machine(actor: Actor) -> StateMachine:
	var states : Array[Constants.ActorState] = [
		Constants.ActorState.IDLING,
		Constants.ActorState.CASTING,
		Constants.ActorState.ATTACKING,
		Constants.ActorState.PLAYER_MOVING,
		Constants.ActorState.DEAD,
	]
	
	var state_machine : StateMachine = StateMachine.new(actor, states, "player_actor")
	return state_machine

############ PROJECTILES ################

## create projectile
func create_projectile(data: ProjectileData) -> Projectile:
	var projectile = _Projectile.instantiate()
	projectile.creator = data.creator
	data.creator.add_child(projectile)
	projectile.uid = Utility.generate_id()
	projectile.global_position = projectile.creator.global_position

	projectile = _add_projectile_target(projectile, data)
	projectile = _add_projectile_funcs(projectile, data)
	projectile = _add_projectile_sprite(projectile, data)

	projectile = _configure_trail(projectile, data)

	projectile.speed = data.speed

	if data.has_physicality:
		projectile.has_physicality = data.has_physicality
	if data.is_homing:
		projectile.is_homing = data.is_homing
	if data.hits_before_expiry:
		projectile.hits_before_expiry = data.hits_before_expiry


	return projectile


func _add_projectile_target(projectile: Projectile, data: ProjectileData) -> Projectile:
	if not data.target and not data.target_pos:
		push_error("Neither target nor target_pos given to projectile. Projectile wont go anywhere.")
		return projectile

	if data.target:
		projectile.target = data.target
	if data.target_pos:
		projectile.target_pos = data.target_pos

	return projectile


func _add_projectile_funcs(projectile: Projectile, data: ProjectileData) -> Projectile:
	if not data.on_hit_func and not data.on_expiry_func:
		push_warning("Neither on_hit_func nor on_expiry_func given to projectile. Projectile wont do anything.")
		return projectile

	if data.on_hit_func:
		projectile.on_hit_func = data.on_hit_func
	if data.on_expiry_func:
		projectile.on_expiry_func = data.on_expiry_func

	return projectile


func _add_projectile_sprite(projectile: Projectile, data: ProjectileData) -> Projectile:

	if not data.sprite_name:
		push_warning("No sprite set for projectile.")
	else:
		var texture : Texture2D = load(Constants.PATH_SPRITES_PROJECTILES + "/" + data.sprite_name.to_lower() + ".png")
		projectile.sprite.set_texture(texture)

	return projectile


func _configure_trail(projectile: Projectile, data: ProjectileData) -> Projectile:
	if data.has_trail:
		projectile.trail.is_emitting = true
		projectile.trail.trail_colour = data.trail_colour
		projectile.trail.lifetime = data.trail_lifetime

	return projectile


############## VISUAL EFFECTS #############

func create_sparkles(data: SparklesData) -> Sparkles:
	var sparkles = _VisualSparkles.instantiate()

	if data.duration:
		sparkles.duration = data.duration
	if data.sparkle_duration:
		sparkles.sparkle_duration = data.sparkle_duration
	if data.num_sparkles:
		sparkles.num_sparkles = data.num_sparkles
	if data.sparkle_size:
		sparkles.sparkle_size = data.sparkle_size
	if data.sparkle_colour:
		sparkles.sparkle_colour = data.sparkle_colour
	if data.explosiveness:
		sparkles.explosiveness = data.explosiveness
	if data.radius:
		sparkles.radius = data.radius
	if data.is_following_parent:
		sparkles.is_following_parent = data.is_following_parent

	return sparkles


func create_simple_animation(animation_name: String) -> SimpleAnimation:
	var animated_sprite : SimpleAnimation = _VisualSimple.instantiate()
	var sprite_frames : SpriteFrames = SpriteFrames.new()

	var path : String = Constants.PATH_SPRITES_EFFECTS + animation_name + "/"
	sprite_frames = Utility.add_animation_to_sprite_frames(sprite_frames, path, animation_name)
	animated_sprite.sprite_frames = sprite_frames

	animated_sprite.play(animation_name)

	return animated_sprite


############# SHARED COMPONENTS ##########

func add_target_finder(creator: Actor, radius: int, is_visible: bool = false, colour: Color = Color(0, 0, 0, 0)) -> TargetFinder:
	#print("Creating new target finder for " + creator.debug_name + " ===========>")
	var target_finder : TargetFinder = _TargetFinder.instantiate()
	creator.add_child(target_finder)  # need to add child to trigger the onready stuff
	target_finder.radius = radius
	target_finder.is_visible = is_visible
	target_finder.global_position = creator.global_position
	if not colour.is_equal_approx(Color(0, 0, 0, 0)):  # if colour isnt default value
		target_finder.shape_colour = colour

	#remove_child(target_finder)  # unparent so that it can be added to caller as required
	return target_finder


func add_state(creator: Actor, state: Constants.ActorState, base_folder: String) -> BaseState:
	# assumes constant name matches state scripts name
	var state_name : String = Constants.ActorState.keys()[state]
	
	var path : String = Constants.PATH_STATES\
			.path_join(base_folder)\
			.path_join("%s.gd"%[state_name.to_lower()])
	var state_: BaseState = load(path).new(creator)
	state_.set_name(state_name.to_pascal_case())
	return state_


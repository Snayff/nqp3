extends Node
## A factory for object creation.

############ SCENES #########

const _Actor : PackedScene = preload("res://scenes/entities/actor/actor.tscn")
const _Projectile: PackedScene = preload("res://scenes/entities/projectile/projectile.tscn")
const _Unit : PackedScene = preload("res://scenes/entities/unit/unit.tscn")


########### UNIT ###############

## create unit, pulling base data from RefData
func create_unit(creator, unit_name: String, team_name: String) -> Unit:
	var unit = _Unit.instantiate()
	creator.add_child(unit)

	unit.unit_name = unit_name
	unit.team = team_name

	return unit

############ ACTOR ##############

## create actor, pulling base data from RefData
func create_actor(creator: Unit, name_: String, team: String) -> Actor:

	var instance = _Actor.instantiate()
	creator.add_child(instance)

	# dont do anything until we're ready
	instance.set_physics_process(false)

	var unit_data = RefData.unit_data[name_]

	instance.uid = Utility.generate_id()

	instance._ai = ActorAI.new(instance)
	creator.add_child(instance._ai)

	instance.stats = _build_actor_stats(unit_data)
	creator.add_child(instance.stats)

	instance.animated_sprite.sprite_frames = _build_actor_sprite_frame(name_)

	instance._status_effects = _build_actor_status_effects()
	creator.add_child(instance._status_effects)

	instance = _add_actor_actions(instance, unit_data)
	creator.add_child(instance._actions)

	instance._cast_timer = _add_actor_cast_timer(instance)

	# shuffle starting pos so they dont start on top of one another
	var pos_offset := Vector2(randf_range(-5, 5), randf_range(-5, 5))
	var pos := Vector2(creator.global_position.x + pos_offset.x, creator.global_position.y + pos_offset.y)
	instance.global_position = pos
	# TODO: ensure shuffling to empty spot

	instance.actor_setup()

	instance = _add_actor_groups(instance, team)

	# now we're ready to react to the world
	instance.set_physics_process(true)

	return instance


func _build_actor_stats(unit_data: Dictionary) -> ActorStats:
	var stats = ActorStats.new()

	stats.max_health = unit_data["max_health"]
	stats.health = unit_data["max_health"]
	stats.max_stamina = unit_data["max_stamina"]
	stats.stamina = unit_data["max_stamina"]

	stats.base_regen = unit_data["regen"]
	stats.base_dodge = unit_data["dodge"]
	stats.base_magic_defence = unit_data["magic_defence"]
	stats.base_mundane_defence = unit_data["mundane_defence"]
	stats.base_attack = unit_data["attack"]
	stats.base_attack_speed = unit_data["attack_speed"]
	stats.base_crit_chance = unit_data["crit_chance"]
	stats.base_penetration = unit_data["penetration"]
	stats.base_move_speed = unit_data["move_speed"]

	stats.num_units = unit_data["num_units"]
	stats.faction = unit_data["faction"]
	stats.gold_cost = unit_data["gold_cost"]
	stats.tier = unit_data["tier"]

	return stats


func _build_actor_sprite_frame(unit_name: String) -> SpriteFrames:
	var anim_names : Array = Constants.ActorAnimationType.keys()
	var path_prefix : String = "res://sprites/units/"

	var sprite_frames = SpriteFrames.new()

	for anim_name in anim_names:
		var path : String = path_prefix + unit_name + "/" + anim_name.to_lower() + "/"
		Utility.add_animation_to_sprite_frames(sprite_frames, path, anim_name.to_lower())

	return sprite_frames


func _build_actor_status_effects() -> ActorStatusEffects:
	var status_effects = ActorStatusEffects.new()
	return status_effects


func _add_actor_groups(instance: Actor, team: String) -> Actor:
	instance.add_to_group(team)
	instance.add_to_group("actor")
	instance.add_to_group("alive")

	return instance


func _add_actor_actions(instance: Actor, unit_data: Dictionary) -> Actor:
	var actions : ActorActions = ActorActions.new()

	for action_type in Constants.ActionType.values():

		# attacks are Dictionary[ActionType, Array[String]]
		if action_type == Constants.ActionType.ATTACK:
			for action_name in unit_data["actions"][action_type]:
				var script_path : String = Utility.get_action_type_script_path(action_type) + action_name + ".gd"
				var script : BaseAction = load(script_path).new(instance)
				actions.add_attack(script)

		# reactions are Dictionary[ActionType, Dictionary[ActionTrigger, Array[String]]
		elif action_type == Constants.ActionType.REACTION:
			for trigger in unit_data["actions"][action_type]:
				for action_name in unit_data["actions"][action_type][trigger]:
					var script_path : String = Utility.get_action_type_script_path(action_type) + action_name + ".gd"
					var script : BaseAction = load(script_path).new(instance)
					actions.add_reaction(script, trigger)

		else:
			# we only add attacks and reactions, ignore everything else
			continue

	# add actions to instance
	instance._actions = actions

	return instance


func _add_actor_cast_timer(instance: Actor) -> Timer:
	# create timer to track cast time
	var cast_timer = Timer.new()
	instance.add_child(cast_timer)
	cast_timer.set_one_shot(true)

	return cast_timer

############ PROJECTILES ################

## create projectile and fire towards target
func create_projectile(proj_data: ProjectileData) -> Projectile:
	var projectile = _Projectile.new(proj_data.creator)
	proj_data.creator.add_child(projectile)
	projectile.uid = Utility.generate_id()

	projectile = _add_projectile_target(projectile, proj_data)
	projectile = _add_projectile_funcs(projectile, proj_data)

	projectile.speed = proj_data.speed

	if proj_data.has_physicality:
		projectile.has_physicality = proj_data.has_physicality
	if proj_data.is_homing:
		projectile.is_homing = proj_data.is_homing
	if proj_data.hits_before_expiry:
		projectile.hits_before_expiry = proj_data.hits_before_expiry


	return projectile


func _add_projectile_target(projectile: Projectile, proj_data: ProjectileData) -> Projectile:
	if not proj_data.target or not proj_data.target_pos:
		push_warning("Neither target nor target_pos given to projectile. Projectile wont go anywhere.")

	if proj_data.target:
		projectile.target = proj_data.target
	if proj_data.target_pos:
		projectile.target_pos = proj_data.target_pos

	return projectile


func _add_projectile_funcs(projectile: Projectile, proj_data: ProjectileData) -> Projectile:
	if not proj_data.on_hit_func or not proj_data.on_expiry_func:
		push_warning("Neither on_hit_func nor on_expiry_func given to projectile. Projectile wont do anything.")

	if proj_data.on_hit_func:
		projectile.on_hit_func = proj_data.on_hit_func
	if proj_data.on_expiry_func:
		projectile.on_expiry_func = proj_data.on_expiry_func

	return projectile

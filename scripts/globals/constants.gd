extends Node
## Global constants.

################ ENUMS ##################

## different states an actor can be in
enum ActorState {
	IDLING,
	CASTING,
	ATTACKING,
	MOVING,
	DEAD
}

enum Direction {
	LEFT = -1,
	RIGHT = 1
}

## different animation types for an actor
enum ActorAnimationType {
	CAST,
	ATTACK,
	DEATH,
	HIT,
	IDLE,
	WALK
}

## different actor stat modifiers
enum StatModType {
	MULTIPLY,
	ADD
}

## different types of damage
enum DamageType {
	MUNDANE,
	MAGIC
}

## defined types of target preference
enum TargetPreference {
	ANY, ## anyone
	LOWEST_HEALTH, ## actor with lowest health
	HIGHEST_HEALTH,  ## actor with highest health
	WEAK_TO_MUNDANE,  ## actor with weakness to mundane damage type
	DAMAGED,  ## actor that isnt full health
	NEAREST,  ## actor nearest caller
	FURTHEST,  ## actor furthest from caller, but still in range
}

## different types of target
enum TargetType {
	SELF,  ## actor using the skill
	ALLY,  ## actor on same team
	ENEMY,  ## actor on other team
	ATTACKER,  ## actor attacking person asking
	DEFENDER,  ## actor being attacked by person asking
	ANY,  ## anyone, we dont care
}

## what needs to be selected as the target for an action
enum ActionTargetSelection {
	GLOBAL,  ##  affects all valid units
	UNIT,  ## specific Unit is chosen
	ACTOR,  ## specific actor is chosen. Used by Actors.
	GROUND,  ## position on the ground is chosen.
	SELF,  ## targets self
}

## different properties of an action
enum ActionTag {
	DAMAGE,
	HEAL,
	SUMMON,
	TERRAIN,
	STATUS_EFFECT,
	STAT_MOD,
}

## different action types
enum ActionType {
	ATTACK,
	STATUS_EFFECT,
	REACTION,
}

## different ways an action can be triggered
enum ActionTrigger {
	ATTACK,  ## the trigger is choosing to use the attack
	ON_DEATH,
	ON_ATTACK,
	ON_HEAL,
	ON_SUMMON,
	ON_KILL,
	ON_MOVE,
	ON_DEAL_DAMAGE,
	ON_RECEIVE_DAMAGE
}


############# PATHS ##############

const PATH_ENTITIES : String = "res://scenes/entities/"
const PATH_COMMANDER := "res://scenes/entities/commander/commander.gd"
const PATH_COMPONENTS : String = "res://scenes/components/"
const PATH_VISUAL_EFFECTS : String = "res://scenes/visual_effects/"
const PATH_ATTACKS : String = "res://scripts/actions/attacks/"  ## the path attack scripts are stored in
const PATH_REACTIONS : String = "res://scripts/actions/reactions/"  ## the path reaction scripts are stored in
const PATH_STATUS_EFFECTS : String = "res://scripts/actions/status_effects/" ## the path reaction scripts are stored in
const PATH_SPRITES_ACTORS : String = "res://sprites/units/"  ## the path unit's actor sprites are held
const PATH_SPRITES_PROJECTILES : String = "res://sprites/projectiles/"
const PATH_SPRITES_EFFECTS : String = "res://sprites/effects/"


############ VALUES ############

const MELEE_RANGE : int = 20  ## the range at which a unit is determined to be melee.

############# TEAMS ##############

const TEAM_ALLY = "ally"
const TEAM_ENEMY = "enemy"

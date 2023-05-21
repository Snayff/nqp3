extends Node
## Global constants.

################ ENUMS ##################

## different states an actor can be in
enum ActorState {
	IDLE,
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
	ANY,
	LOWEST_HEALTH,
	WEAK_TO_MUNDANE,
	HIGHEST_HEALTH
}

## different types of target
enum TargetType {
	SELF,  ## actor using the skill
	ALLY,  ## actor on same team
	ENEMY,  ## actor on other team
	ATTACKER,  ## actor attacking self
	DEFENDER,  ## actor being attacked by self
	ANY,  ## anyone, we dont care

}

## different properties of an action
enum ActionTag {
	DAMAGE,
	SUMMON,
	TERRAIN,
	STATUS_EFFECT,
	STAT_MOD
}

## different action types
enum ActionType {
	ATTACK,
	ON_HIT,
	ON_DEATH,
	ON_ATTACK,
	STATUS_EFFECT,
}

############# PATHS ##############

const PATH_ATTACKS : String = "res://scripts/actions/attacks/"  ## the path attack scripts are stored in
const PATH_REACTIONS : String = "res://scripts/actions/reactions/" ## the path reaction scripts are stored in
const PATH_STATUS_EFFECTS : String = "res://scripts/actions/status_effects/" ## the path reaction scripts are stored in

############ VALUES ############

const MELEE_RANGE : int = 10  ## the range at which a unit is determined to be melee.

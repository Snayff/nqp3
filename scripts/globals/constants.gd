extends Node
## Global constants.

################ ENUMS ##################

enum EntityState {
	IDLE,
	ATTACKING,
	MOVING,
	DEAD
}

enum Direction {
	LEFT = -1,
	RIGHT = 1
}

enum AnimationType {
	ATTACK,
	DEATH,
	HIT,
	IDLE,
	WALK
}

enum StatModType {
	MULTIPLY,
	ADD
}

enum DamageType {
	MUNDANE,
	MAGIC
}

enum TargetPreference {
	ANY,
	LOWEST_HEALTH,
	WEAK_TO_MUNDANE,
	HIGHEST_HEALTH
}

enum TargetType {
	SELF,
	ALLY,  ## actor on same team
	ENEMY,  ## actor on other team
	ATTACKER,  ## actor attacking self
	DEFENDER,  ## actor being attacked by self

}

enum ActionTag {
	DAMAGE,
	SUMMON,
	TERRAIN,
	STATUS_EFFECT,
}

enum ActionType {
	ATTACK,
	ON_HIT,
	ON_DEATH,
	ON_ATTACK
}

############# PATHS ##############

const PATH_ATTACKS : String = "res://scripts/actions/attacks/"
const PATH_REACTIONS : String = "res://scripts/actions/reactions/"

############ VALUES ############

const MELEE_RANGE : int = 10

class_name ProjectileData extends Node
## data for creation of projectiles

########## BASIC INFO ############

var creator : Actor
var target : Actor  ## actor to target. takes precedence over target_pos
var target_pos : Vector2  ## target position. ignored if there is a target actor.
var speed : float = 200.0  ## how fast projectile moves
var lifetime : float = 2.0  ## how long  the projectile exists without contact before expiring
var has_physicality : bool = false  ## applies physics, e.g. knockback
var is_homing : bool = false  ## whether projectile alters direction to track target. does nothing if moving to target_pos.
var hits_before_expiry : int = 1  ## expires after this many hits. INF to never expire from hits.
var on_hit_func : Callable  ## function to trigger on hit
var on_expiry_func : Callable  ## function to trigger on expiry
var sprite_name : String  ## the name of the sprite held in PATH_SPRITES_PROJECTILES

######## TRAIL INFO  #############

var has_trail : bool = false
var trail_colour : Color
var trail_lifetime : float


func _init(creator_: Actor) -> void:
	## required info
	creator = creator_


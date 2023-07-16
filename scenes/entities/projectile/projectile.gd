class_name Projectile extends Node2D
## A projectile to move towards a target, delivering effects to a target or location
##
## Signals on expiry, allowing a process to carry on from there

######### SIGNALS #########

signal expired(hit_target: bool, actor_hit: Actor)

######## OTHER NODES ###########

@onready var timer : Timer = $Lifetime
@onready var impact_detector : Area2D = $ImpactDetector
@onready var sprite : Sprite2D = $Sprite

######## ATTRIBUTES #########

var speed : float = 200.0  ## how fast projectile moves
var lifetime : float = 2.0  ## how long  the projectile exists without contact before expiring
var creator : Actor
var target : Actor  ## actor to target. takes precedence over target_pos
var target_pos : Vector2  ## target position. ignored if there is a target actor.
var has_physicality : bool = false  ## applies physics, e.g. knockback
var is_homing : bool = false  ## whether projectile alters direction to track target. does nothing if moving to target_pos.
var hits_before_expiry : int = 1  ## expires after this many hits. INF to never expire from hits.
var on_hit_func : Callable  ## function to trigger on hit
var on_expiry_func : Callable  ## function to trigger on expiry


####### FUNCTIONALITY ############

var direction := Vector2.ZERO  # set on launch
var has_hit_target : bool = false


func _ready() -> void:
	timer.connect("timeout", _on_timeout)
	impact_detector.connect("body_entered", _on_impact)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_impact(_body: Node) -> void:
	# did we hit the target?
	if _body == target:
		has_hit_target = true

		# we hit target, pretend time ended
		timer.stop()
		timer.timeout.emit()  # this will trigger _disable()


## launch the projectile towards the target
func launch(creator_: Actor, target_: Actor) -> void:
	creator = creator_
	target = target_
	position = creator_.global_position
	direction = global_position.direction_to(target.global_position)

	timer.start(lifetime)


func _on_timeout() -> void:
	# N.B. dont queue_free() as used in pool

	emit_signal("expired", [has_hit_target, target])
	_disable()


func _disable() -> void:
		hide()
		visible = false
		set_process(false)

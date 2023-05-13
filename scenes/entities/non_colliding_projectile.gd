class_name NonCollidingProjectile extends Node2D
## A projectile to move towards a target without colliding on the way.
##
## Signals on expiry, allowing a process to carry on from there

######### SIGNALS #########

signal expired(hit_target: bool, actor_hit: Actor)

######## OTHER NODES ###########

@onready var timer : Timer = $Lifetime
@onready var impact_detector : Area2D = $ImpactDetector
@onready var sprite : Sprite2D = $Sprite

######## ATTRIBUTES #########
var speed : float = 1000.0  # FIXME: only works at high speeds
var lifetime : float = 2.0
var creator: Actor
var target: Actor
var has_hit_target : bool = false

# functional
var direction := Vector2.ZERO  # set by creator

func _ready() -> void:
	top_level = true
	timer.connect("timeout", _on_timeout)
	timer.start(lifetime)
	impact_detector.connect("body_entered", _on_impact)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_impact(_body: Node) -> void:
	if _body == target:
		# hide straight away to avoid delays
		sprite.visible = false

		has_hit_target = true

		# we hit target, pretend time ended
		timer.stop()
		timer.timeout.emit()


## launch the projectile towards the target
func launch(creator_: Actor, target_: Actor) -> void:
	creator = creator_
	target = target_
	position = creator_.global_position
	direction = global_position.direction_to(target.global_position)

func _on_timeout() -> void:
	emit_signal("expired", [has_hit_target, target])
	queue_free()

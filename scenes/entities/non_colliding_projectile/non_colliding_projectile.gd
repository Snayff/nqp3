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
var speed : float = 200.0  # FIXME: only works at high speeds
var lifetime : float = 2.0
var creator: Actor
var target: Actor
var has_hit_target : bool = false

####### FUNCTIONALITY ############
var direction := Vector2.ZERO  # set on launch


func _ready() -> void:
	timer.connect("timeout", _on_timeout)
	impact_detector.connect("body_entered", _on_impact)

	reset()


## reset for use in the object pool
##
## assumes assigned to new creator before being called
func reset() -> void:
	# move back to the top of the tree, to avoid being impacted by parent's movement
	top_level = true

	# get ready for processing
	set_process(true)
	show()
	visible = true

	has_hit_target = false


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

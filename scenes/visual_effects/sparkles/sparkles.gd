class_name Sparkles extends GPUParticles2D
## sparkles visual effects. shows lots of coloured circles around target

# there is an animation player with a sort of "charging up" effect. This isnt used, but could be added.

@onready var timer : Timer = $Timer

########## GENERAL ATTRIBUTES ##########

var is_emitting : bool = false
var duration : float = 0.0

########### INDIVIDUAL SPARKLE ATTRIBUTES #########

var num_sparkles : int = 16:
	set(value):
		num_sparkles = value
		amount = num_sparkles
var sparkle_size : int = 60:
	set(value):
		sparkle_size = value
		process_material.emission_sphere_radius = sparkle_size
var sparkle_duration : float = 1:
	set(value):
		sparkle_duration = value
		lifetime = sparkle_duration
var sparkle_colour : Color:
	set(value):
		sparkle_colour = value
		process_material.color = sparkle_colour


func _ready() -> void:
	timer.timeout.connect(_on_timeout)
	timer.start(duration)


func _on_timeout() -> void:
	queue_free()

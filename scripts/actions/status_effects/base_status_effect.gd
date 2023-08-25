class_name BaseStatusEffect extends BaseAction
## ABC for status effects
## status effects are tailored actions that work on time


############ SIGNALS #############

# Emitted when the effect expires.
signal expired

############ ATTRIBUTES ##########

var _base_duration : float
var _duration_timer : Timer
## how long until expiry
var duration : float:
	get:
		# TODO: mod by creator stats
		return _base_duration
	set(_value):
		push_warning("Tried to set duration directly. Not allowed.")
## amount of time left on cooldown
var duration_remaining : float:
	get:
		return _duration_timer.time_left
	set(_value):
		push_warning("Tried to set duration_remaining directly. Not allowed.")
## array of [StatModifier]s. Used if self modified a stat. Applied during application of self to Actor.
var stat_modifiers: Array[StatModifier] = []

func _init(creator: Actor) -> void:
	super(creator)


func setup(p_target: Actor) -> void:
	super(p_target)
	
	# setup new timer for duration
	_duration_timer = Timer.new()
	_duration_timer.set_name("DurationTimer_%s"%[friendly_name])
	_duration_timer.timeout.connect(on_duration_expiry)
	_creator.add_child(_duration_timer, true)
	set_duration(_base_duration)

	# override core functionality to make the action work as a recurring effect
	_cooldown_timer.set_one_shot(false)

	# trigger action on cooldown
	_cooldown_timer.timeout.connect(apply_status_effect)


func destroy() -> void:
	print("destroying %s from %s %s"%[friendly_name, _target, uid])
	_duration_timer.stop()
	_duration_timer.queue_free()
	_cooldown_timer.stop()
	_cooldown_timer.queue_free()
	target_finder.queue_free()


## wrapper for use()
##
## allows connecting builtin signal directly
func apply_status_effect() -> void:
	use(_target)


func set_duration(duration_time: float) -> void:
	# ignore if wait time == 0
	if duration_time > 0:
		_duration_timer.wait_time = duration_time
		_duration_timer.start()


func on_duration_expiry() -> void:
	expired.emit()

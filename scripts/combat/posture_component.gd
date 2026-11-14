class_name PostureComponent
extends Node
## Enemy posture (GDD §6.4). Fills with posture damage, drains when left alone, and when
## full stays broken for a while (stun and execution window), then resets to empty.

signal posture_changed(current: float, maximum: float)
signal posture_broken
signal posture_recovered

@export var tuning: PostureTuning

var current: float = 0.0
var _idle_time: float = 0.0
var _broken_left: float = 0.0


func _ready() -> void:
	assert(tuning != null, "PostureComponent needs a PostureTuning resource.")


func _physics_process(delta: float) -> void:
	tick(delta)


## Adds posture damage. Ignored while broken.
func apply(amount: float) -> void:
	if is_broken() or amount <= 0.0:
		return
	_idle_time = 0.0
	_set_current(minf(current + amount, tuning.max_posture))
	if PostureRules.breaks(current, tuning):
		_broken_left = tuning.broken_duration
		posture_broken.emit()


## Advances decay and the broken window. Public so tests can drive time.
func tick(delta: float) -> void:
	if is_broken():
		_broken_left -= delta
		if _broken_left <= 0.0:
			_broken_left = 0.0
			_set_current(0.0)
			posture_recovered.emit()
		return
	_idle_time += delta
	var next: float = PostureRules.decay(current, _idle_time, delta, tuning)
	if not is_equal_approx(next, current):
		_set_current(next)


func is_broken() -> bool:
	return _broken_left > 0.0


func get_maximum() -> float:
	return tuning.max_posture


func reset() -> void:
	_broken_left = 0.0
	_idle_time = 0.0
	_set_current(0.0)


func _set_current(value: float) -> void:
	current = value
	posture_changed.emit(current, tuning.max_posture)

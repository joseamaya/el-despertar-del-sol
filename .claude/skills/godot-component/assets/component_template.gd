class_name ExampleComponent
extends Node
## Thin node: keeps state, delegates rules to ExampleMath, reports through signals.
## Dependencies are injected with @export; it never looks other systems up by path.

signal value_changed(current: float, maximum: float)
signal depleted

@export var tuning: ExampleTuning

var current: float = 0.0
var _idle_time: float = 0.0


func _ready() -> void:
	assert(tuning != null, "ExampleComponent needs an ExampleTuning resource.")
	current = tuning.max_value
	_idle_time = tuning.regen_delay


func _physics_process(delta: float) -> void:
	tick(delta)


## Advances time. Public so tests can drive it deterministically
## (call set_physics_process(false) in the test first).
func tick(delta: float) -> void:
	_idle_time += delta
	var next: float = ExampleMath.regenerate(current, _idle_time, delta, tuning)
	if not is_equal_approx(next, current):
		_set_current(next)


## Optional spend: returns false and changes nothing if `cost` is not affordable.
func try_spend(cost: float) -> bool:
	if not ExampleMath.can_spend(current, cost):
		return false
	_idle_time = 0.0
	_set_current(current - cost)
	return true


## Mandatory drain: always applies, clamped at zero. Returns false if it was not covered.
func drain(cost: float) -> bool:
	var covered: bool = ExampleMath.can_spend(current, cost)
	_idle_time = 0.0
	_set_current(ExampleMath.drain(current, cost))
	return covered


func _set_current(value: float) -> void:
	var was_positive: bool = current > 0.0
	current = value
	value_changed.emit(current, tuning.max_value)
	if was_positive and current <= 0.0:
		depleted.emit()

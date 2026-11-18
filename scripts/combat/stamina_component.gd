class_name StaminaComponent
extends Node
## Stamina of a character: regenerates after a delay and supports the three spending
## rules of DECISIONS/0007. Reports through signals; the actions decide the costs.

signal stamina_changed(current: float, maximum: float)
signal depleted

@export var tuning: StaminaTuning

var current: float = 0.0
## Extra maximum on top of the tuning (offerings at huacas, GDD §8.4). Use add_bonus().
var bonus_max: float = 0.0
var _idle_time: float = 0.0


func _ready() -> void:
	assert(tuning != null, "StaminaComponent needs a StaminaTuning resource.")
	current = get_maximum()
	_idle_time = tuning.regen_delay


func _physics_process(delta: float) -> void:
	tick(delta)


## Advances regeneration. Public so tests can drive time (set_physics_process(false)).
func tick(delta: float) -> void:
	_idle_time += delta
	var next: float = StaminaRules.regenerate(current, _idle_time, delta, tuning, get_maximum())
	if not is_equal_approx(next, current):
		_set_current(next)


## Attack: allowed while any stamina is left; drains down to zero at most.
func try_spend_partial(cost: float) -> bool:
	if not StaminaRules.can_spend_partial(current):
		return false
	_spend(cost)
	return true


## Dodge: needs the whole cost; otherwise nothing changes.
func try_spend_full(cost: float) -> bool:
	if not StaminaRules.can_spend_full(current, cost):
		return false
	_spend(cost)
	return true


## Blocked hit: always applies, clamped at zero. Returns false if it was not covered
## (the guard breaks).
func drain(cost: float) -> bool:
	var covered: bool = StaminaRules.can_spend_full(current, cost)
	_spend(cost)
	return covered


## Continuous spending (sprint) of `rate_per_second` over `delta`. Returns false if there
## was nothing left to spend.
func drain_over_time(rate_per_second: float, delta: float) -> bool:
	if current <= 0.0:
		return false
	_spend(rate_per_second * delta)
	return true


func is_empty() -> bool:
	return current <= 0.0


func get_maximum() -> float:
	return tuning.max_stamina + bonus_max


## Raises the maximum for good and fills the new room.
func add_bonus(amount: float) -> void:
	bonus_max += amount
	_set_current(current + amount)


func reset() -> void:
	_idle_time = tuning.regen_delay
	_set_current(get_maximum())


func _spend(cost: float) -> void:
	_idle_time = 0.0
	_set_current(StaminaRules.drain(current, cost))


func _set_current(value: float) -> void:
	var was_positive: bool = current > 0.0
	current = value
	stamina_changed.emit(current, get_maximum())
	if was_positive and current <= 0.0:
		depleted.emit()

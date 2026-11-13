class_name HealthComponent
extends Node
## Health of a character. Reports changes, damage and death through signals; knows nothing
## about who hits it or what happens on death.

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
signal died

@export var tuning: HealthTuning

var current: float = 0.0


func _ready() -> void:
	assert(tuning != null, "HealthComponent needs a HealthTuning resource.")
	current = tuning.max_health


## Applies damage and returns the amount actually taken (0 if dead or amount <= 0).
func apply_damage(amount: float) -> float:
	if is_dead() or amount <= 0.0:
		return 0.0
	var taken: float = minf(amount, current)
	_set_current(current - taken)
	damaged.emit(taken)
	if is_dead():
		died.emit()
	return taken


## Restores health up to the maximum. Does nothing once dead (use reset()).
func heal(amount: float) -> void:
	if is_dead() or amount <= 0.0:
		return
	_set_current(minf(current + amount, tuning.max_health))


## Back to full health, also after death (respawn).
func reset() -> void:
	_set_current(tuning.max_health)


func is_dead() -> bool:
	return current <= 0.0


func get_maximum() -> float:
	return tuning.max_health


func _set_current(value: float) -> void:
	current = value
	health_changed.emit(current, tuning.max_health)

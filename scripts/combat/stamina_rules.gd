class_name StaminaRules
extends RefCounted
## Pure stamina rules (GDD §6.5, DECISIONS/0007).


## Value after `delta` seconds. Only the part of `delta` past `regen_delay` regenerates, so
## the frame that crosses the delay is frame-rate independent too. `idle_time` already
## includes this `delta`.
static func regenerate(
	current: float, idle_time: float, delta: float, tuning: StaminaTuning
) -> float:
	var regen_time: float = clampf(idle_time - tuning.regen_delay, 0.0, maxf(delta, 0.0))
	return minf(current + tuning.regen_per_second * regen_time, tuning.max_stamina)


## Attacks (0007): allowed with any stamina left.
static func can_spend_partial(current: float) -> bool:
	return current > 0.0


## Dodge (0007): needs the whole cost.
static func can_spend_full(current: float, cost: float) -> bool:
	return cost <= current


## Spending that always applies (blocked hit, partial attack, sprint): never below zero.
static func drain(current: float, cost: float) -> float:
	return maxf(current - maxf(cost, 0.0), 0.0)

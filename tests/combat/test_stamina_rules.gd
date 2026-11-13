extends GdUnitTestSuite
## Unit tests for stamina rules (GDD §6.5, DECISIONS/0007).

const EPS: float = 0.0001


func _t() -> StaminaTuning:
	return StaminaTuning.new()


func test_no_regen_before_delay() -> void:
	var t := _t()
	assert_float(StaminaRules.regenerate(10.0, t.regen_delay - 0.01, 0.005, t)).is_equal_approx(
		10.0, EPS
	)


func test_regen_rate_after_delay() -> void:
	var t := _t()
	var v: float = StaminaRules.regenerate(10.0, t.regen_delay + 1.0, 0.5, t)
	assert_float(v).is_equal_approx(10.0 + t.regen_per_second * 0.5, EPS)


func test_regen_is_frame_rate_independent_across_the_delay() -> void:
	var t := _t()
	assert_float(_simulate(t, 1.0 / 30.0, 1.5)).is_equal_approx(
		_simulate(t, 1.0 / 144.0, 1.5), 0.05
	)
	# 1.5 s idle -> 0.9 s of regen at 30/s = 27
	assert_float(_simulate(t, 1.0 / 60.0, 1.5)).is_equal_approx(27.0, 0.1)


func test_regen_never_exceeds_max() -> void:
	var t := _t()
	assert_float(StaminaRules.regenerate(t.max_stamina - 1.0, 10.0, 1.0, t)).is_equal(t.max_stamina)


func test_partial_spend_needs_only_some_stamina() -> void:
	assert_bool(StaminaRules.can_spend_partial(0.1)).is_true()
	assert_bool(StaminaRules.can_spend_partial(0.0)).is_false()


func test_full_spend_needs_whole_cost() -> void:
	assert_bool(StaminaRules.can_spend_full(20.0, 20.0)).is_true()
	assert_bool(StaminaRules.can_spend_full(19.9, 20.0)).is_false()


func test_drain_clamps_at_zero_and_ignores_negative_cost() -> void:
	assert_float(StaminaRules.drain(5.0, 15.0)).is_equal(0.0)
	assert_float(StaminaRules.drain(5.0, -3.0)).is_equal(5.0)


func _simulate(t: StaminaTuning, step: float, seconds: float) -> float:
	var v: float = 0.0
	var idle: float = 0.0
	for i: int in roundi(seconds / step):
		idle += step
		v = StaminaRules.regenerate(v, idle, step, t)
	return v

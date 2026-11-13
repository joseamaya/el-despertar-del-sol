extends GdUnitTestSuite
## Unit tests for ExampleMath: normal cases, limits, no overshoot, frame-rate independence.

const EPS: float = 0.0001


func _tuning() -> ExampleTuning:
	return ExampleTuning.new()


func test_no_regen_before_delay() -> void:
	var t := _tuning()
	var v: float = ExampleMath.regenerate(10.0, t.regen_delay - 0.01, 0.005, t)
	assert_float(v).is_equal_approx(10.0, EPS)


func test_regen_after_delay_uses_rate() -> void:
	var t := _tuning()
	var v: float = ExampleMath.regenerate(10.0, t.regen_delay + 1.0, 0.5, t)
	assert_float(v).is_equal_approx(10.0 + t.regen_per_second * 0.5, EPS)


func test_regen_is_frame_rate_independent() -> void:
	var t := _tuning()
	var at_30: float = _simulate(t, 1.0 / 30.0, 1.0)
	var at_144: float = _simulate(t, 1.0 / 144.0, 1.0)
	assert_float(at_30).is_equal_approx(at_144, 0.01)


func test_regen_never_exceeds_max() -> void:
	var t := _tuning()
	var v: float = t.max_value - 1.0
	for i: int in 120:
		v = ExampleMath.regenerate(v, 10.0, 1.0 / 60.0, t)
		assert_float(v).is_less_equal(t.max_value)


func test_can_spend_limits() -> void:
	assert_bool(ExampleMath.can_spend(10.0, 10.0)).is_true()
	assert_bool(ExampleMath.can_spend(10.0, 10.01)).is_false()


func test_drain_clamps_at_zero() -> void:
	assert_float(ExampleMath.drain(5.0, 15.0)).is_equal(0.0)


## Regenerates from 0 for `seconds` at a fixed step, idle from the start.
func _simulate(t: ExampleTuning, step: float, seconds: float) -> float:
	var v: float = 0.0
	var idle: float = 0.0
	for i: int in roundi(seconds / step):
		idle += step
		v = ExampleMath.regenerate(v, idle, step, t)
	return v

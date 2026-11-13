extends GdUnitTestSuite
## StaminaComponent with time driven by tick().

const FRAME: float = 1.0 / 60.0

var _s: StaminaComponent
var _depleted: int = 0


func before_test() -> void:
	_depleted = 0
	_s = auto_free(StaminaComponent.new())
	_s.tuning = StaminaTuning.new()
	add_child(_s)
	_s.set_physics_process(false)
	_s.depleted.connect(func() -> void: _depleted += 1)


func _advance(seconds: float) -> void:
	for i: int in roundi(seconds / FRAME):
		_s.tick(FRAME)


func test_starts_full() -> void:
	assert_float(_s.current).is_equal(100.0)


func test_attack_with_little_stamina_is_allowed_and_drains_to_zero() -> void:
	_s.drain(95.0)
	assert_bool(_s.try_spend_partial(12.0)).is_true()
	assert_float(_s.current).is_equal(0.0)
	assert_bool(_s.try_spend_partial(12.0)).is_false()


func test_dodge_needs_whole_cost() -> void:
	_s.drain(85.0)
	assert_bool(_s.try_spend_full(20.0)).is_false()
	assert_float(_s.current).is_equal(15.0)


func test_blocked_hit_always_drains_and_reports_guard_break() -> void:
	assert_bool(_s.drain(15.0)).is_true()
	_s.drain(80.0)
	assert_bool(_s.drain(15.0)).is_false()
	assert_float(_s.current).is_equal(0.0)


func test_depleted_once_when_crossing_zero() -> void:
	_s.drain(100.0)
	_s.drain(10.0)
	_s.try_spend_partial(5.0)
	assert_int(_depleted).is_equal(1)


func test_regenerates_after_delay_only() -> void:
	_s.drain(50.0)
	_advance(0.5)
	assert_float(_s.current).is_equal_approx(50.0, 0.001)
	_advance(1.1)  # 0.1 s left of delay, then 1.0 s of regen
	assert_float(_s.current).is_equal_approx(80.0, 0.6)


func test_drain_over_time_spends_rate() -> void:
	for i: int in 60:
		_s.drain_over_time(8.0, FRAME)
	assert_float(_s.current).is_equal_approx(92.0, 0.01)

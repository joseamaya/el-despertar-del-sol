extends GdUnitTestSuite
## HealthComponent rules and signals.

var _h: HealthComponent
var _died: int = 0


func before_test() -> void:
	_died = 0
	_h = auto_free(HealthComponent.new())
	_h.tuning = HealthTuning.new()
	add_child(_h)
	_h.died.connect(func() -> void: _died += 1)


func test_starts_full() -> void:
	assert_float(_h.current).is_equal(100.0)
	assert_bool(_h.is_dead()).is_false()


func test_damage_reports_amount_taken_and_emits() -> void:
	var monitor := monitor_signals(_h)
	assert_float(_h.apply_damage(30.0)).is_equal(30.0)
	await assert_signal(monitor).is_emitted("damaged", [30.0])
	await assert_signal(monitor).is_emitted("health_changed", [70.0, 100.0])


func test_damage_never_goes_below_zero_and_died_once() -> void:
	assert_float(_h.apply_damage(150.0)).is_equal(100.0)
	assert_float(_h.current).is_equal(0.0)
	assert_float(_h.apply_damage(10.0)).is_equal(0.0)
	assert_int(_died).is_equal(1)


func test_ignores_zero_or_negative_damage() -> void:
	assert_float(_h.apply_damage(0.0)).is_equal(0.0)
	assert_float(_h.apply_damage(-5.0)).is_equal(0.0)
	assert_float(_h.current).is_equal(100.0)


func test_heal_caps_at_max_and_not_when_dead() -> void:
	_h.apply_damage(40.0)
	_h.heal(100.0)
	assert_float(_h.current).is_equal(100.0)
	_h.apply_damage(100.0)
	_h.heal(50.0)
	assert_float(_h.current).is_equal(0.0)


func test_reset_revives() -> void:
	_h.apply_damage(100.0)
	_h.reset()
	assert_float(_h.current).is_equal(100.0)
	assert_bool(_h.is_dead()).is_false()

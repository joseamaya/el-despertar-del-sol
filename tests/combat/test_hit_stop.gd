extends GdUnitTestSuite
## HitStop slows global time and restores it; overlapping hits extend it.

var _stop: HitStop


func before_test() -> void:
	_stop = auto_free(HitStop.new())
	_stop.tuning = CombatFeelTuning.new()
	add_child(_stop)


func after_test() -> void:
	Engine.time_scale = 1.0


func test_trigger_slows_time_and_restores() -> void:
	_stop.trigger()
	assert_bool(_stop.is_stopped()).is_true()
	assert_float(Engine.time_scale).is_equal_approx(_stop.tuning.hitstop_time_scale, 0.0001)
	await get_tree().create_timer(_stop.tuning.hitstop_duration + 0.05, true, false, true).timeout
	assert_float(Engine.time_scale).is_equal(1.0)


func test_overlapping_hits_extend_instead_of_cutting_short() -> void:
	_stop.trigger()
	await get_tree().create_timer(_stop.tuning.hitstop_duration * 0.6, true, false, true).timeout
	_stop.trigger()
	await get_tree().create_timer(_stop.tuning.hitstop_duration * 0.6, true, false, true).timeout
	assert_bool(_stop.is_stopped()).is_true()
	await get_tree().create_timer(_stop.tuning.hitstop_duration, true, false, true).timeout
	assert_float(Engine.time_scale).is_equal(1.0)


func test_zero_duration_disables_hitstop() -> void:
	_stop.tuning.hitstop_duration = 0.0
	_stop.trigger()
	assert_float(Engine.time_scale).is_equal(1.0)

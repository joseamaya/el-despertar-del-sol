extends GdUnitTestSuite
## Posture rules and component (time driven by tick()).

const FRAME: float = 1.0 / 60.0

var _p: PostureComponent
var _broken: int = 0
var _recovered: int = 0


func before_test() -> void:
	_broken = 0
	_recovered = 0
	_p = auto_free(PostureComponent.new())
	_p.tuning = PostureTuning.new()
	add_child(_p)
	_p.set_physics_process(false)
	_p.posture_broken.connect(func() -> void: _broken += 1)
	_p.posture_recovered.connect(func() -> void: _recovered += 1)


func _advance(seconds: float) -> void:
	for i: int in roundi(seconds / FRAME):
		_p.tick(FRAME)


func test_rules_decay_after_delay_and_frame_rate_independent() -> void:
	var t := PostureTuning.new()
	assert_float(PostureRules.decay(50.0, t.decay_delay - 0.01, 0.005, t)).is_equal(50.0)
	assert_float(PostureRules.decay(50.0, t.decay_delay + 1.0, 1.0, t)).is_equal_approx(
		35.0, 0.0001
	)
	assert_float(PostureRules.decay(5.0, 10.0, 1.0, t)).is_equal(0.0)
	assert_float(_drain(t, 1.0 / 30.0)).is_equal_approx(_drain(t, 1.0 / 144.0), 0.05)


func test_breaks_once_when_full_and_ignores_more() -> void:
	_p.apply(60.0)
	_p.apply(60.0)
	assert_bool(_p.is_broken()).is_true()
	assert_float(_p.current).is_equal(100.0)
	_p.apply(30.0)
	assert_int(_broken).is_equal(1)


func test_recovers_empty_after_broken_duration() -> void:
	_p.apply(100.0)
	_advance(_p.tuning.broken_duration - 0.1)
	assert_bool(_p.is_broken()).is_true()
	_advance(0.2)
	assert_bool(_p.is_broken()).is_false()
	assert_float(_p.current).is_equal(0.0)
	assert_int(_recovered).is_equal(1)


func test_drains_only_when_left_alone() -> void:
	_p.apply(40.0)
	_advance(1.0)
	assert_float(_p.current).is_equal(40.0)
	_advance(1.5)  # 0.5 s of delay left, then 1 s at 15/s
	assert_float(_p.current).is_equal_approx(25.0, 0.3)


func _drain(t: PostureTuning, step: float) -> float:
	var v: float = 60.0
	var idle: float = 0.0
	for i: int in roundi(3.0 / step):
		idle += step
		v = PostureRules.decay(v, idle, step, t)
	return v

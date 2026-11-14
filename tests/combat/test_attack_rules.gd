extends GdUnitTestSuite
## Unit tests for the attack timeline.

const EPS: float = 0.0001
const P := AttackRules.Phase


func _data(speed: float = 1.0) -> AttackData:
	var a := AttackData.new()
	a.clip_speed = speed
	a.windup_end = 0.3
	a.active_end = 0.5
	a.recovery_end = 1.0
	a.chain_from = 0.6
	a.lunge_distance = 0.5
	return a


func test_phases_follow_clip_times() -> void:
	var a := _data()
	assert_int(AttackRules.phase(0.0, a)).is_equal(P.WINDUP)
	assert_int(AttackRules.phase(0.29, a)).is_equal(P.WINDUP)
	assert_int(AttackRules.phase(0.3, a)).is_equal(P.ACTIVE)
	assert_int(AttackRules.phase(0.5, a)).is_equal(P.RECOVERY)
	assert_int(AttackRules.phase(1.0, a)).is_equal(P.DONE)


func test_clip_speed_scales_real_time() -> void:
	var a := _data(2.0)
	assert_float(AttackRules.real(0.3, a)).is_equal_approx(0.15, EPS)
	assert_int(AttackRules.phase(0.16, a)).is_equal(P.ACTIVE)
	assert_int(AttackRules.phase(0.5, a)).is_equal(P.DONE)


func test_buffer_window_before_chain_point() -> void:
	var a := _data()
	assert_bool(AttackRules.accepts_buffer(0.1, a)).is_false()
	assert_bool(AttackRules.accepts_buffer(0.6 - AttackRules.BUFFER_WINDOW, a)).is_true()
	assert_bool(AttackRules.can_chain(0.59, a)).is_false()
	assert_bool(AttackRules.can_chain(0.6, a)).is_true()


func test_lunge_only_until_active_ends() -> void:
	var a := _data()
	assert_float(AttackRules.lunge_speed(0.1, a)).is_equal_approx(1.0, EPS)
	assert_float(AttackRules.lunge_speed(0.5, a)).is_equal(0.0)


func test_chain_wraps() -> void:
	assert_int(AttackRules.next_in_chain(-1, 3)).is_equal(0)
	assert_int(AttackRules.next_in_chain(2, 3)).is_equal(0)
	assert_int(AttackRules.next_in_chain(0, 0)).is_equal(0)


func test_shipped_attacks_are_consistent() -> void:
	for id: String in ["light_1", "light_2", "light_3", "heavy"]:
		var a := load("res://resources/combat/attacks/%s.tres" % id) as AttackData
		assert_float(a.windup_end).is_less(a.active_end)
		assert_float(a.active_end).is_less_equal(a.chain_from)
		assert_float(a.chain_from).is_less_equal(a.recovery_end)

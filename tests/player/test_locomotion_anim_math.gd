extends GdUnitTestSuite
## Unit tests for speed -> locomotion blend / playback rate.

const EPS: float = 0.0001


func _tuning() -> PlayerAnimationTuning:
	return PlayerAnimationTuning.new()


func test_blend_follows_speed_inside_clip_range() -> void:
	var t := _tuning()
	assert_float(LocomotionAnimMath.blend_position(0.0, t)).is_equal(0.0)
	assert_float(LocomotionAnimMath.blend_position(t.walk_cycle_speed, t)).is_equal_approx(
		t.walk_cycle_speed, EPS
	)
	assert_float(LocomotionAnimMath.blend_position(5.0, t)).is_equal_approx(5.0, EPS)


func test_blend_is_clamped_to_sprint_cycle() -> void:
	var t := _tuning()
	assert_float(LocomotionAnimMath.blend_position(20.0, t)).is_equal_approx(
		t.sprint_cycle_speed, EPS
	)
	assert_float(LocomotionAnimMath.blend_position(-1.0, t)).is_equal(0.0)


func test_time_scale_is_one_up_to_sprint_cycle() -> void:
	var t := _tuning()
	assert_float(LocomotionAnimMath.time_scale(0.0, t)).is_equal(1.0)
	assert_float(LocomotionAnimMath.time_scale(t.sprint_cycle_speed, t)).is_equal(1.0)


func test_time_scale_speeds_up_above_sprint_and_is_capped() -> void:
	var t := _tuning()
	var faster: float = LocomotionAnimMath.time_scale(t.sprint_cycle_speed * 1.1, t)
	assert_float(faster).is_equal_approx(1.1, EPS)
	assert_float(LocomotionAnimMath.time_scale(100.0, t)).is_equal_approx(t.max_time_scale, EPS)


func test_tuned_player_speeds_fit_inside_clip_range() -> void:
	# The movement tuning should not exceed what the clips can show without speeding up.
	var move := MovementTuning.new()
	var t := _tuning()
	assert_float(move.run_speed).is_less_equal(t.sprint_cycle_speed)
	assert_float(move.sprint_speed).is_less_equal(t.sprint_cycle_speed)


func test_smooth_converges_and_is_frame_rate_independent() -> void:
	var a: float = 0.0
	var b: float = 0.0
	for i: int in 30:
		a = LocomotionAnimMath.smooth(a, 5.0, 12.0, 1.0 / 30.0)
	for i: int in 144:
		b = LocomotionAnimMath.smooth(b, 5.0, 12.0, 1.0 / 144.0)
	assert_float(a).is_equal_approx(b, 0.01)
	assert_float(a).is_equal_approx(5.0, 0.01)

extends GdUnitTestSuite
## Unit tests for the pure camera helpers.

const EPS: float = 0.0001


func _tuning() -> CameraTuning:
	return CameraTuning.new()


func test_mouse_right_turns_right_and_up_looks_up() -> void:
	var look: Vector2 = CameraMath.look_from_mouse(Vector2(10, -10), _tuning())
	assert_float(look.x).is_less(0.0)  # negative yaw = turn right
	assert_float(look.y).is_greater(0.0)  # positive pitch = look up


func test_mouse_sensitivity_scales_linearly() -> void:
	var t := _tuning()
	var look: Vector2 = CameraMath.look_from_mouse(Vector2(100, 0), t)
	assert_float(look.x).is_equal_approx(-deg_to_rad(100.0 * t.mouse_sensitivity), EPS)


func test_invert_flips_each_axis_independently() -> void:
	var t := _tuning()
	var normal: Vector2 = CameraMath.look_from_mouse(Vector2(10, 10), t)
	t.invert_y = true
	var inverted_y: Vector2 = CameraMath.look_from_mouse(Vector2(10, 10), t)
	assert_float(inverted_y.x).is_equal_approx(normal.x, EPS)
	assert_float(inverted_y.y).is_equal_approx(-normal.y, EPS)
	t.invert_x = true
	var inverted_both: Vector2 = CameraMath.look_from_mouse(Vector2(10, 10), t)
	assert_float(inverted_both.x).is_equal_approx(-normal.x, EPS)


func test_stick_turns_at_stick_sensitivity_per_second() -> void:
	var t := _tuning()
	var look: Vector2 = CameraMath.look_from_stick(Vector2(1, 0), 0.5, t)
	assert_float(look.x).is_equal_approx(-deg_to_rad(t.stick_sensitivity * 0.5), EPS)


func test_pitch_is_clamped_to_limits() -> void:
	var t := _tuning()
	var up: Vector2 = CameraMath.apply_look(Vector2.ZERO, Vector2(0, 10.0), t)
	var down: Vector2 = CameraMath.apply_look(Vector2.ZERO, Vector2(0, -10.0), t)
	assert_float(up.y).is_equal_approx(deg_to_rad(t.pitch_max_deg), EPS)
	assert_float(down.y).is_equal_approx(deg_to_rad(t.pitch_min_deg), EPS)


func test_yaw_wraps_instead_of_growing() -> void:
	var orbit := Vector2.ZERO
	for i: int in 100:
		orbit = CameraMath.apply_look(orbit, Vector2(0.5, 0), _tuning())
	assert_float(orbit.x).is_between(-PI, PI)
	assert_float(orbit.x).is_equal_approx(wrapf(50.0, -PI, PI), EPS)


func test_follow_converges_without_overshoot() -> void:
	var pos := Vector3.ZERO
	var target := Vector3(4, 1, -2)
	for i: int in 120:
		pos = CameraMath.follow(pos, target, 12.0, 1.0 / 60.0)
		assert_float(pos.distance_to(Vector3.ZERO)).is_less_equal(target.length() + EPS)
	assert_vector(pos).is_equal_approx(target, Vector3.ONE * 0.001)


func test_follow_is_frame_rate_independent() -> void:
	var at_30: Vector3 = _simulate_follow(1.0 / 30.0, 0.5)
	var at_144: Vector3 = _simulate_follow(1.0 / 144.0, 0.5)
	assert_vector(at_30).is_equal_approx(at_144, Vector3.ONE * 0.01)


func _simulate_follow(step: float, seconds: float) -> Vector3:
	var pos := Vector3.ZERO
	for i: int in roundi(seconds / step):
		pos = CameraMath.follow(pos, Vector3(10, 0, 0), 12.0, step)
	return pos

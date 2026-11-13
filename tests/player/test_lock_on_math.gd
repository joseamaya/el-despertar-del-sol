extends GdUnitTestSuite
## Unit tests for lock-on rules. Camera looks down -Z (identity basis): right is +X.

const EPS: float = 0.0001


func _tuning() -> LockOnTuning:
	return LockOnTuning.new()


func _points(values: Array[Vector3]) -> Array[Vector3]:
	return values


func test_view_angle_sign_and_magnitude() -> void:
	var b := Basis.IDENTITY
	assert_float(LockOnMath.view_angle(Vector3.ZERO, Vector3(0, 0, -5), b)).is_equal_approx(
		0.0, EPS
	)
	assert_float(LockOnMath.view_angle(Vector3.ZERO, Vector3(5, 0, -5), b)).is_equal_approx(
		PI / 4, EPS
	)
	assert_float(LockOnMath.view_angle(Vector3.ZERO, Vector3(-5, 0, -5), b)).is_less(0.0)


func test_view_angle_ignores_height_and_camera_pitch() -> void:
	var pitched := Basis.from_euler(Vector3(deg_to_rad(-40), 0, 0))
	var a: float = LockOnMath.view_angle(Vector3.ZERO, Vector3(3, 4, -3), pitched)
	assert_float(a).is_equal_approx(PI / 4, EPS)


func test_pick_best_prefers_centered_over_close() -> void:
	var c := _points([Vector3(-3, 0, -3), Vector3(0, 0, -9)])
	assert_int(LockOnMath.pick_best(Vector3.ZERO, Basis.IDENTITY, c, _tuning())).is_equal(1)


func test_pick_best_prefers_closer_when_equally_centered() -> void:
	var c := _points([Vector3(0, 0, -12), Vector3(0, 0, -4)])
	assert_int(LockOnMath.pick_best(Vector3.ZERO, Basis.IDENTITY, c, _tuning())).is_equal(1)


func test_pick_best_ignores_out_of_range_and_out_of_angle() -> void:
	var t := _tuning()
	var c := _points([Vector3(0, 0, -(t.lock_range + 1)), Vector3(5, 0, 0.5), Vector3(0, 0, 4)])
	assert_int(LockOnMath.pick_best(Vector3.ZERO, Basis.IDENTITY, c, t)).is_equal(LockOnMath.NONE)


func test_pick_best_with_no_candidates() -> void:
	var c: Array[Vector3] = []
	assert_int(LockOnMath.pick_best(Vector3.ZERO, Basis.IDENTITY, c, _tuning())).is_equal(
		LockOnMath.NONE
	)


func test_neighbor_right_and_left_pick_nearest_on_that_side() -> void:
	var c := _points(
		[
			Vector3(-6, 0, -8),
			Vector3(-2, 0, -8),
			Vector3(0, 0, -8),
			Vector3(3, 0, -8),
			Vector3(7, 0, -8)
		]
	)
	var current := Vector3(0, 0, -8)
	var t := _tuning()
	assert_int(LockOnMath.pick_neighbor(Vector3.ZERO, Basis.IDENTITY, current, c, 1, t)).is_equal(3)
	assert_int(LockOnMath.pick_neighbor(Vector3.ZERO, Basis.IDENTITY, current, c, -1, t)).is_equal(
		1
	)


func test_neighbor_none_on_that_side_keeps_current() -> void:
	var c := _points([Vector3(-2, 0, -8), Vector3(0, 0, -8)])
	var current := Vector3(0, 0, -8)
	var right: int = LockOnMath.pick_neighbor(
		Vector3.ZERO, Basis.IDENTITY, current, c, 1, _tuning()
	)
	assert_int(right).is_equal(LockOnMath.NONE)


func test_neighbor_ignores_out_of_range() -> void:
	var t := _tuning()
	var c := _points([Vector3(0, 0, -8), Vector3(t.lock_range, 0, -8)])
	var right: int = LockOnMath.pick_neighbor(
		Vector3.ZERO, Basis.IDENTITY, Vector3(0, 0, -8), c, 1, t
	)
	assert_int(right).is_equal(LockOnMath.NONE)


func test_switch_direction_threshold() -> void:
	assert_int(LockOnMath.switch_direction(0.5, 0.6)).is_equal(0)
	assert_int(LockOnMath.switch_direction(0.7, 0.6)).is_equal(1)
	assert_int(LockOnMath.switch_direction(-45.0, 40.0)).is_equal(-1)


func test_out_of_range_uses_break_distance() -> void:
	var t := _tuning()
	(
		assert_bool(
			LockOnMath.is_out_of_range(Vector3.ZERO, Vector3(0, 0, -t.break_distance + 0.1), t)
		)
		. is_false()
	)
	(
		assert_bool(
			LockOnMath.is_out_of_range(Vector3.ZERO, Vector3(0, 0, -t.break_distance - 0.1), t)
		)
		. is_true()
	)


func test_camera_yaw_towards_and_turn() -> void:
	var yaw: float = CameraMath.yaw_towards(Vector3.ZERO, Vector3(5, 0, 0))
	var facing: Vector3 = Basis(Vector3.UP, yaw) * Vector3.FORWARD
	assert_vector(facing).is_equal_approx(Vector3(1, 0, 0), Vector3.ONE * EPS)
	var orbit := Vector2.ZERO
	for i: int in 120:
		orbit = CameraMath.turn_towards(orbit, Vector2(1.0, -0.3), 10.0, 1.0 / 60.0)
	assert_vector(orbit).is_equal_approx(Vector2(1.0, -0.3), Vector2.ONE * 0.001)

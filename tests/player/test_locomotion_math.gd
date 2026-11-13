extends GdUnitTestSuite
## Unit tests for the pure locomotion helpers.

const EPS: float = 0.0001


func _camera_basis(yaw_deg: float, pitch_deg: float) -> Basis:
	return Basis.from_euler(Vector3(deg_to_rad(pitch_deg), deg_to_rad(yaw_deg), 0.0))


func test_forward_input_follows_camera_yaw() -> void:
	var dir: Vector3 = LocomotionMath.camera_relative_direction(
		Vector2(0, -1), _camera_basis(0, -40)
	)
	assert_vector(dir).is_equal_approx(Vector3(0, 0, -1), Vector3.ONE * EPS)
	var turned: Vector3 = LocomotionMath.camera_relative_direction(
		Vector2(0, -1), _camera_basis(90, -40)
	)
	assert_vector(turned).is_equal_approx(Vector3(-1, 0, 0), Vector3.ONE * EPS)


func test_right_input_follows_camera_right() -> void:
	var dir: Vector3 = LocomotionMath.camera_relative_direction(
		Vector2(1, 0), _camera_basis(0, -40)
	)
	assert_vector(dir).is_equal_approx(Vector3(1, 0, 0), Vector3.ONE * EPS)


func test_direction_stays_on_ground_plane_and_keeps_analog_magnitude() -> void:
	var dir: Vector3 = LocomotionMath.camera_relative_direction(
		Vector2(0, -0.5), _camera_basis(30, -60)
	)
	assert_float(dir.y).is_equal_approx(0.0, EPS)
	assert_float(dir.length()).is_equal_approx(0.5, EPS)


func test_diagonal_input_is_clamped_to_unit_length() -> void:
	var dir: Vector3 = LocomotionMath.camera_relative_direction(Vector2(1, -1), Basis.IDENTITY)
	assert_float(dir.length()).is_equal_approx(1.0, EPS)


func test_top_down_camera_still_gives_a_direction() -> void:
	var dir: Vector3 = LocomotionMath.camera_relative_direction(
		Vector2(0, -1), _camera_basis(0, -90)
	)
	assert_float(dir.length()).is_equal_approx(1.0, EPS)


func test_target_velocity_uses_sprint_speed_only_when_sprinting() -> void:
	var tuning := MovementTuning.new()
	var dir := Vector3(0, 0, -1)
	var run: Vector3 = LocomotionMath.target_velocity(dir, false, tuning)
	var sprint: Vector3 = LocomotionMath.target_velocity(dir, true, tuning)
	assert_float(run.length()).is_equal_approx(tuning.run_speed, EPS)
	assert_float(sprint.length()).is_equal_approx(tuning.sprint_speed, EPS)


func test_acceleration_converges_without_overshoot() -> void:
	var target := Vector3(5, 0, 0)
	var v := Vector3.ZERO
	for i: int in 60:
		v = LocomotionMath.approach_horizontal(v, target, 30.0, 40.0, 1.0 / 60.0)
		assert_float(v.length()).is_less_equal(target.length() + EPS)
	assert_vector(v).is_equal_approx(target, Vector3.ONE * EPS)


func test_acceleration_takes_expected_time() -> void:
	# 5 m/s at 30 m/s² should take 1/6 s = 10 frames at 60 Hz.
	var v := Vector3.ZERO
	for i: int in 9:
		v = LocomotionMath.approach_horizontal(v, Vector3(5, 0, 0), 30.0, 40.0, 1.0 / 60.0)
	assert_float(v.x).is_less(5.0)
	v = LocomotionMath.approach_horizontal(v, Vector3(5, 0, 0), 30.0, 40.0, 1.0 / 60.0)
	assert_float(v.x).is_equal_approx(5.0, EPS)


func test_deceleration_is_used_when_input_released() -> void:
	var v: Vector3 = LocomotionMath.approach_horizontal(
		Vector3(5, 0, 0), Vector3.ZERO, 30.0, 60.0, 1.0 / 60.0
	)
	assert_float(v.x).is_equal_approx(4.0, EPS)


func test_vertical_velocity_is_preserved() -> void:
	var v: Vector3 = LocomotionMath.approach_horizontal(
		Vector3(0, -3, 0), Vector3(5, 0, 0), 30.0, 40.0, 0.1
	)
	assert_float(v.y).is_equal_approx(-3.0, EPS)


func test_yaw_from_direction_faces_minus_z_forward() -> void:
	assert_float(LocomotionMath.yaw_from_direction(Vector3(0, 0, -1))).is_equal_approx(0.0, EPS)
	var yaw_right: float = LocomotionMath.yaw_from_direction(Vector3(1, 0, 0))
	var facing: Vector3 = Basis(Vector3.UP, yaw_right) * Vector3.FORWARD
	assert_vector(facing).is_equal_approx(Vector3(1, 0, 0), Vector3.ONE * EPS)


func test_smooth_yaw_takes_shortest_path_and_converges() -> void:
	var yaw: float = deg_to_rad(170.0)
	var target: float = deg_to_rad(-170.0)
	var first: float = LocomotionMath.smooth_yaw(yaw, target, 12.0, 1.0 / 60.0)
	assert_float(angle_difference(yaw, first)).is_greater(0.0)
	for i: int in 120:
		yaw = LocomotionMath.smooth_yaw(yaw, target, 12.0, 1.0 / 60.0)
	assert_float(absf(angle_difference(yaw, target))).is_less(0.001)


func test_locked_facing_faces_target_when_idle_or_advancing() -> void:
	var to_target := Vector3(0, 0, -5)
	var max_angle: float = deg_to_rad(50.0)
	var idle: Vector3 = LocomotionMath.locked_facing(Vector3.ZERO, to_target, max_angle)
	assert_vector(idle.normalized()).is_equal_approx(Vector3(0, 0, -1), Vector3.ONE * EPS)
	var diagonal: Vector3 = LocomotionMath.locked_facing(
		Vector3(0.5, 0, -1).normalized(), to_target, max_angle
	)
	assert_vector(diagonal.normalized()).is_equal_approx(Vector3(0, 0, -1), Vector3.ONE * EPS)


func test_locked_facing_follows_move_when_sideways_or_away() -> void:
	var to_target := Vector3(0, 0, -5)
	var max_angle: float = deg_to_rad(50.0)
	var side: Vector3 = LocomotionMath.locked_facing(Vector3(1, 0, 0), to_target, max_angle)
	assert_vector(side).is_equal_approx(Vector3(1, 0, 0), Vector3.ONE * EPS)
	var away: Vector3 = LocomotionMath.locked_facing(Vector3(0, 0, 1), to_target, max_angle)
	assert_vector(away).is_equal_approx(Vector3(0, 0, 1), Vector3.ONE * EPS)


func test_locked_facing_ignores_height() -> void:
	var f: Vector3 = LocomotionMath.locked_facing(Vector3.ZERO, Vector3(0, 3, -5), deg_to_rad(50))
	assert_float(f.y).is_equal(0.0)

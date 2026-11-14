extends GdUnitTestSuite
## View cone and hearing on the ground plane.


func test_view_cone_angle_and_distance() -> void:
	var o := Vector3.ZERO
	var fwd := Vector3(0, 0, -1)
	assert_bool(PerceptionRules.in_view_cone(o, fwd, Vector3(0, 0, -10), 14.0, 110.0)).is_true()
	assert_bool(PerceptionRules.in_view_cone(o, fwd, Vector3(5, 0, -5), 14.0, 110.0)).is_true()  # 45°
	assert_bool(PerceptionRules.in_view_cone(o, fwd, Vector3(10, 0, -2), 14.0, 110.0)).is_false()  # 79°
	assert_bool(PerceptionRules.in_view_cone(o, fwd, Vector3(0, 0, 5), 14.0, 110.0)).is_false()
	assert_bool(PerceptionRules.in_view_cone(o, fwd, Vector3(0, 0, -15), 14.0, 110.0)).is_false()


func test_view_cone_ignores_height() -> void:
	(
		assert_bool(
			PerceptionRules.in_view_cone(
				Vector3.ZERO, Vector3.FORWARD, Vector3(0, 6, -5), 14.0, 110.0
			)
		)
		. is_true()
	)


func test_hearing_is_omnidirectional() -> void:
	assert_bool(PerceptionRules.heard(Vector3.ZERO, Vector3(0, 0, 4.9), 5.0)).is_true()
	assert_bool(PerceptionRules.heard(Vector3.ZERO, Vector3(-3, 0, -3), 5.0)).is_true()
	assert_bool(PerceptionRules.heard(Vector3.ZERO, Vector3(0, 0, 5.1), 5.0)).is_false()

extends GdUnitTestSuite
## Unit tests for factions and sweep points.

const F := HitRules.Faction


func test_no_friendly_fire() -> void:
	assert_bool(HitRules.can_hit(F.PLAYER, F.PLAYER)).is_false()
	assert_bool(HitRules.can_hit(F.CHANCA, F.CHANCA)).is_false()
	assert_bool(HitRules.can_hit(F.PLAYER, F.CHANCA)).is_true()
	assert_bool(HitRules.can_hit(F.CHANCA, F.PLAYER)).is_true()


func test_neutral_hits_and_is_hit_by_everyone() -> void:
	assert_bool(HitRules.can_hit(F.NEUTRAL, F.PLAYER)).is_true()
	assert_bool(HitRules.can_hit(F.PLAYER, F.NEUTRAL)).is_true()


func test_sweep_points_cover_path_within_step() -> void:
	var pts: PackedVector3Array = HitRules.sweep_points(Vector3.ZERO, Vector3(1, 0, 0), 0.1)
	assert_int(pts.size()).is_equal(10)
	assert_vector(pts[pts.size() - 1]).is_equal(Vector3(1, 0, 0))
	var prev := Vector3.ZERO
	for p: Vector3 in pts:
		assert_float(prev.distance_to(p)).is_less_equal(0.1 + 0.0001)
		prev = p


func test_sweep_without_motion_tests_current_position() -> void:
	var pts: PackedVector3Array = HitRules.sweep_points(Vector3.ONE, Vector3.ONE, 0.1)
	assert_int(pts.size()).is_equal(1)
	assert_vector(pts[0]).is_equal(Vector3.ONE)


func test_sweep_points_are_capped() -> void:
	var pts: PackedVector3Array = HitRules.sweep_points(Vector3.ZERO, Vector3(100, 0, 0), 0.1)
	assert_int(pts.size()).is_equal(HitRules.MAX_SWEEP_POINTS)

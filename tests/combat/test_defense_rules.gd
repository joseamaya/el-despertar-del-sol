extends GdUnitTestSuite
## Unit tests for defense outcomes.

const O := DefenseRules.Outcome


func _t() -> DefenseTuning:
	return DefenseTuning.new()


func test_frontal_arc() -> void:
	var facing := Vector3(0, 0, -1)
	assert_bool(DefenseRules.is_frontal(facing, Vector3(0, 0, -2), 120.0)).is_true()
	assert_bool(DefenseRules.is_frontal(facing, Vector3(2, 0, -2), 120.0)).is_true()  # 45°
	assert_bool(DefenseRules.is_frontal(facing, Vector3(2, 0, 0), 120.0)).is_false()  # 90°
	assert_bool(DefenseRules.is_frontal(facing, Vector3(0, 0, 2), 120.0)).is_false()  # behind


func test_frontal_ignores_height() -> void:
	assert_bool(DefenseRules.is_frontal(Vector3(0, 0, -1), Vector3(0, 5, -1), 120.0)).is_true()


func test_evading_beats_everything() -> void:
	assert_int(DefenseRules.resolve(true, true, 0.0, true, true, _t())).is_equal(O.EVADED)
	assert_int(DefenseRules.resolve(true, false, 9.0, false, false, _t())).is_equal(O.EVADED)


func test_no_block_or_from_behind_is_a_hit() -> void:
	assert_int(DefenseRules.resolve(false, false, 0.0, true, true, _t())).is_equal(O.HIT)
	assert_int(DefenseRules.resolve(false, true, 0.0, false, true, _t())).is_equal(O.HIT)


func test_parry_only_inside_window() -> void:
	var t := _t()
	assert_int(DefenseRules.resolve(false, true, t.parry_window, true, true, t)).is_equal(O.PARRIED)
	assert_int(DefenseRules.resolve(false, true, t.parry_window + 0.01, true, true, t)).is_equal(
		O.BLOCKED
	)


func test_parry_works_even_without_stamina() -> void:
	assert_int(DefenseRules.resolve(false, true, 0.05, true, false, _t())).is_equal(O.PARRIED)


func test_block_without_stamina_breaks_guard() -> void:
	assert_int(DefenseRules.resolve(false, true, 1.0, true, false, _t())).is_equal(O.GUARD_BROKEN)

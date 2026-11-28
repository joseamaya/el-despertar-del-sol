extends GdUnitTestSuite
## EscortRules (F10 task 5): the freed walk in a row behind the leader, a Chanca goes for
## one only when the leader is far from them and the Chanca close, and the party has
## arrived when everyone is inside the radius.


func test_one_person_walks_straight_behind() -> void:
	var at: Vector3 = EscortRules.follow_slot(Vector3.ZERO, Vector3.FORWARD, 0, 1, 2.5, 1.4)
	assert_vector(at).is_equal_approx(Vector3(0, 0, 2.5), Vector3.ONE * 0.001)


func test_a_row_is_centred_and_spaced() -> void:
	var a: Vector3 = EscortRules.follow_slot(Vector3.ZERO, Vector3.FORWARD, 0, 3, 2.0, 1.5)
	var b: Vector3 = EscortRules.follow_slot(Vector3.ZERO, Vector3.FORWARD, 1, 3, 2.0, 1.5)
	var c: Vector3 = EscortRules.follow_slot(Vector3.ZERO, Vector3.FORWARD, 2, 3, 2.0, 1.5)
	assert_vector(b).is_equal_approx(Vector3(0, 0, 2), Vector3.ONE * 0.001)
	assert_float(a.distance_to(b)).is_equal_approx(1.5, 0.001)
	assert_float(c.distance_to(b)).is_equal_approx(1.5, 0.001)
	assert_float(a.x).is_equal_approx(-c.x, 0.001)


func test_the_row_turns_with_the_leader_and_ignores_height() -> void:
	var at: Vector3 = EscortRules.follow_slot(Vector3(10, 3, 0), Vector3(1, 5, 0), 0, 1, 2.0, 1.0)
	assert_vector(at).is_equal_approx(Vector3(8, 3, 0), Vector3.ONE * 0.001)


func test_no_direction_still_gives_a_place() -> void:
	var at: Vector3 = EscortRules.follow_slot(Vector3.ZERO, Vector3.ZERO, 0, 1, 2.0, 1.0)
	assert_float(at.length()).is_equal_approx(2.0, 0.001)


func test_a_chanca_goes_for_an_unguarded_prisoner_only() -> void:
	var prisoner := Vector3.ZERO
	var enemy := Vector3(3, 0, 0)
	# Cusi far, Chanca close: yes.
	assert_bool(EscortRules.threatens(Vector3(20, 0, 0), prisoner, enemy, 8.0, 6.0)).is_true()
	# Cusi close: no.
	assert_bool(EscortRules.threatens(Vector3(5, 0, 0), prisoner, enemy, 8.0, 6.0)).is_false()
	# Chanca far: no.
	(
		assert_bool(EscortRules.threatens(Vector3(20, 0, 0), prisoner, Vector3(10, 0, 0), 8.0, 6.0))
		. is_false()
	)
	# Height does not count.
	assert_bool(EscortRules.threatens(Vector3(5, 30, 0), prisoner, enemy, 8.0, 6.0)).is_false()


func test_arrived_only_when_everyone_is_inside() -> void:
	var inside := PackedVector3Array([Vector3(1, 0, 0), Vector3(0, 4, -2)])
	assert_bool(EscortRules.all_within(inside, Vector3.ZERO, 3.0)).is_true()
	inside.append(Vector3(4, 0, 0))
	assert_bool(EscortRules.all_within(inside, Vector3.ZERO, 3.0)).is_false()

extends GdUnitTestSuite
## The patrol route (F9 task 12): back on its round, a scout heads for the nearest point.


func test_nearest_point_of_the_route() -> void:
	var route: Array[Vector3] = [Vector3(0, 0, 0), Vector3(10, 0, 0), Vector3(10, 5, 10)]
	assert_int(EnemyPatrol.nearest_point(route, Vector3(1, 0, 1))).is_equal(0)
	assert_int(EnemyPatrol.nearest_point(route, Vector3(9, 0, -1))).is_equal(1)
	# On the ground: height does not count.
	assert_int(EnemyPatrol.nearest_point(route, Vector3(10, -40, 9))).is_equal(2)


func test_an_empty_route_gives_the_first_point() -> void:
	var route: Array[Vector3] = []
	assert_int(EnemyPatrol.nearest_point(route, Vector3.ZERO)).is_equal(0)

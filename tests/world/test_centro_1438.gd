extends GdUnitTestSuite
## The Cusco of 1438 in the hub (F9, chosen by the developer with the chronicles): the old
## house of the Sun (Inticancha, stone under ichu, in its own walled kancha, downstream),
## kanchas of the past Incas in the upper part (Hanan), the war stone in the square and two
## streams with eaten banks on either side of the city, which Cusi cannot leave along.

const LAYOUT: String = "res://resources/levels/centro_layout.tres"
const SCENE: String = "res://scenes/levels/centro.tscn"

var _layout: SectorLayout


func before_test() -> void:
	_layout = load(LAYOUT) as SectorLayout


## The boundary walls that close a rectangle around `at` (an enclosure), or 0.
func _walls_around(at: Vector2) -> int:
	var sides: int = 0
	for w: Vector4 in _layout.boundary_walls:
		var a := Vector2(w.x, w.y)
		var b := Vector2(w.z, w.w)
		if is_equal_approx(a.y, b.y) and minf(a.x, b.x) <= at.x and at.x <= maxf(a.x, b.x):
			sides += 1 if absf(a.y - at.y) < 20.0 else 0
		elif is_equal_approx(a.x, b.x) and minf(a.y, b.y) <= at.y and at.y <= maxf(a.y, b.y):
			sides += 1 if absf(a.x - at.x) < 20.0 else 0
	return sides


func test_inticancha_is_stone_in_its_own_kancha_downstream() -> void:
	assert_int(_layout.stone_houses.size()).is_greater(0)
	for i: int in _layout.stone_houses:
		var h: Vector3 = _layout.houses[i]
		var at := Vector2(h.x, h.y)
		assert_float(h.y).override_failure_message("downstream").is_greater(0.0)
		assert_int(_walls_around(at)).override_failure_message("walled").is_greater(2)
		assert_bool(_layout.closed_houses.has(i)).is_false()
	assert_bool(_layout.big_houses.has(_layout.stone_houses[0])).is_true()


func test_the_past_incas_have_kanchas_up_in_hanan() -> void:
	var upper: int = 0
	for i: int in _layout.big_houses:
		var h: Vector3 = _layout.houses[i]
		if h.y < -38.0 and _walls_around(Vector2(h.x, h.y)) > 2:
			upper += 1
	assert_int(upper).is_greater(1)


func test_the_war_stone_stands_in_the_square() -> void:
	assert_int(_layout.shrines.size()).is_equal(1)
	var stone := Vector2(_layout.shrines[0].x, _layout.shrines[0].y)
	assert_float(stone.length()).is_less(15.0)


func test_two_streams_run_through_the_city_in_a_bed() -> void:
	assert_int(_layout.streams.size()).is_equal(2)
	var sides: Array[float] = []
	for line: PackedVector2Array in _layout.streams:
		sides.append(signf(line[0].x))
		var mid: Vector2 = line[line.size() / 2]
		var bed: float = _layout.height_at(mid.x, mid.y)
		assert_float(bed).is_less(_layout.profile_at(mid.y) - _layout.stream_depth * 0.5)
		# Downstream last: the water runs down the profile.
		var first: Vector2 = line[0]
		var last: Vector2 = line[line.size() - 1]
		assert_float(_layout.profile_at(last.y)).is_less_equal(_layout.profile_at(first.y))
	assert_array(sides).contains_exactly_in_any_order([-1.0, 1.0])


func test_nothing_stands_in_a_stream() -> void:
	var clear: float = _layout.stream_width * 0.5 + 1.0
	for i: int in _layout.houses.size():
		var h: Vector3 = _layout.houses[i]
		var reach: float = maxf(_layout.house_size_at(i).x, _layout.house_size_at(i).z) * 0.5
		(
			assert_float(_layout.distance_to_stream(Vector2(h.x, h.y)))
			. override_failure_message("house %d" % i)
			. is_greater(reach + clear)
		)
	for key: StringName in _layout.points:
		assert_float(_layout.distance_to_stream(_layout.points[key])).is_greater(clear + 2.0)


func test_cusi_cannot_leave_along_a_stream() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	var level := runner.find_child("SectorLevel") as SectorLevel
	for i: int in 10:
		await get_tree().physics_frame
	var map: RID = level.get_world_3d().navigation_map
	var from: Vector3 = level.to_global_point(_layout.start)
	for line: PackedVector2Array in _layout.streams:
		for end: Vector2 in [line[0], line[line.size() - 1]]:
			var beyond: Vector2 = end + Vector2(0.0, signf(end.y) * 12.0)
			var goal: Vector3 = level.to_global_point(beyond)
			var path: PackedVector3Array = NavigationServer3D.map_get_path(map, from, goal, true)
			var reached: Vector3 = path[path.size() - 1] if not path.is_empty() else from
			(
				assert_float(Vector2(reached.x - goal.x, reached.z - goal.z).length())
				. override_failure_message("out along the stream at %s" % beyond)
				. is_greater(4.0)
			)

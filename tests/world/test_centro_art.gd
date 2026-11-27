extends GdUnitTestSuite
## The art of the hub (F9 task 4): bigger and shut houses, streets between low pirca, a
## gate of stone posts at each kancha, and a huaca in the square. None of it blocks the
## path or stands where someone waits.

const LAYOUT: String = "res://resources/levels/centro_layout.tres"
const SCENE: String = "res://scenes/levels/centro.tscn"
## The square (x, z half sizes around the origin): its houses face it.
const SQUARE: Vector2 = Vector2(22.0, 17.0)
## How close a gate has to be to the curaca waiting at it.
const GATE_REACH: float = 4.0

var _layout: SectorLayout


func before_test() -> void:
	_layout = load(LAYOUT) as SectorLayout


func _people() -> Dictionary:
	var at: Dictionary = _layout.points.duplicate()
	at[&"Mentor"] = _layout.mentor
	at[&"Start"] = _layout.start
	return at


func _wall_distance(p: Vector2, w: Vector4) -> float:
	var near: Vector2 = Geometry2D.get_closest_point_to_segment(
		p, Vector2(w.x, w.y), Vector2(w.z, w.w)
	)
	return p.distance_to(near)


func test_variants_point_at_real_houses() -> void:
	assert_int(_layout.big_houses.size()).is_greater(0)
	assert_int(_layout.closed_houses.size()).is_greater(0)
	for i: int in Array(_layout.big_houses) + Array(_layout.closed_houses):
		assert_int(i).is_between(0, _layout.houses.size() - 1)
	assert_vector(_layout.house_size_at(_layout.big_houses[0])).is_equal(_layout.big_house_size)
	assert_vector(_layout.house_size_at(-1)).is_equal(_layout.house_size)


func test_every_kancha_has_a_big_house() -> void:
	for curaca: StringName in [&"Curaca_valle", &"Curaca_quilescachis", &"Curaca_camino"]:
		var c: Vector2 = _layout.points[curaca]
		var found: bool = false
		for i: int in _layout.big_houses:
			var h: Vector3 = _layout.houses[i]
			# Inside the kancha: on the far side of the gate from the street.
			found = (
				found
				or (signf(h.x) == signf(c.x) and absf(h.x) > absf(c.x) and absf(h.y - c.y) < 10.0)
			)
		assert_bool(found).override_failure_message(String(curaca)).is_true()


func test_houses_on_the_square_face_it() -> void:
	for h: Vector3 in _layout.houses:
		if absf(h.x) > SQUARE.x or absf(h.y) > SQUARE.y:
			continue
		var door := Vector2(0, 1).rotated(-deg_to_rad(h.z))
		var to_centre: Vector2 = -Vector2(h.x, h.y).normalized()
		(
			assert_float(door.dot(to_centre))
			. override_failure_message("house at (%.0f, %.0f) turns its back" % [h.x, h.y])
			. is_greater(0.5)
		)


func test_street_walls_leave_the_path_free() -> void:
	var clear: float = _layout.path_width * 0.5 + 0.5
	for w: Vector4 in _layout.boundary_walls:
		for i: int in _layout.path.size() - 1:
			var a: Vector2 = _layout.path[i]
			var b: Vector2 = _layout.path[i + 1]
			for k: int in 21:
				var p: Vector2 = a.lerp(b, k / 20.0)
				(
					assert_float(_wall_distance(p, w))
					. override_failure_message("wall %s on the path at %s" % [w, p])
					. is_greater(clear)
				)


func test_walls_keep_off_houses_and_people() -> void:
	var people: Dictionary = _people()
	for w: Vector4 in _layout.boundary_walls:
		for key: StringName in people:
			var p: Vector2 = people[key]
			(
				assert_float(_wall_distance(p, w))
				. override_failure_message("wall %s on %s" % [w, key])
				. is_greater(1.0)
			)
		for i: int in _layout.houses.size():
			var h: Vector3 = _layout.houses[i]
			var size: Vector3 = _layout.house_size_at(i)
			var reach: float = minf(size.x, size.z) * 0.5
			(
				assert_float(_wall_distance(Vector2(h.x, h.y), w))
				. override_failure_message("wall %s through house %d" % [w, i])
				. is_greater(reach)
			)


func test_each_curaca_waits_at_a_gate() -> void:
	for curaca: StringName in [&"Curaca_valle", &"Curaca_quilescachis", &"Curaca_camino"]:
		var c: Vector2 = _layout.points[curaca]
		var posts: int = 0
		for g: Vector3 in _layout.gate_posts:
			if c.distance_to(Vector2(g.x, g.y)) < GATE_REACH:
				posts += 1
		assert_int(posts).override_failure_message(String(curaca)).is_equal(2)


func test_the_square_has_a_huaca_out_of_the_way() -> void:
	assert_int(_layout.shrines.size()).is_equal(1)
	var at := Vector2(_layout.shrines[0].x, _layout.shrines[0].y)
	assert_bool(absf(at.x) < SQUARE.x and absf(at.y) < SQUARE.y).is_true()
	var reach: float = SectorTown.RING_RADIUS + 1.5
	assert_float(_layout.distance_to_path(at)).is_greater(reach)
	var people: Dictionary = _people()
	for key: StringName in people:
		(
			assert_float(at.distance_to(people[key] as Vector2))
			. override_failure_message(String(key))
			. is_greater(reach)
		)
	# The slice's huaca and its rite stay out of the hub.
	assert_bool(_layout.has_huaca).is_false()


func test_the_hub_builds_its_town() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	var level := runner.find_child("SectorLevel") as SectorLevel
	var town := level.find_child("Town", true, false) as MeshInstance3D
	assert_object(town).is_not_null()
	assert_int(town.mesh.get_surface_count()).is_equal(1)


## The city goes on past the hub: the houses beyond stand up on the ground Cusi cannot reach,
## and the hub keeps about forty houses of its own (the developer found it too small).
func test_the_city_goes_on_beyond_the_walkable_ground() -> void:
	assert_int(_layout.houses.size()).is_greater(40)
	assert_int(_layout.outskirts.size()).is_greater(80)
	for h: Vector3 in _layout.outskirts:
		var rise: float = _layout.height_at(h.x, h.y) - _layout.profile_at(h.y)
		(
			assert_float(rise)
			. override_failure_message("outskirt house at (%.0f, %.0f) is reachable" % [h.x, h.y])
			. is_greater(_layout.side_max_rise - 0.5)
		)


func test_the_outskirts_cast_no_shadow() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	var level := runner.find_child("SectorLevel") as SectorLevel
	var outskirts := level.find_child("Outskirts", true, false) as MeshInstance3D
	assert_object(outskirts).is_not_null()
	assert_int(outskirts.cast_shadow).is_equal(GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	# F10 task 1: they are far houses, so the city beyond costs little (fewer than 100
	# triangles a house).
	var triangles: int = (outskirts.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]).size() / 3
	assert_int(triangles).is_less(_layout.outskirts.size() * 100)

extends GdUnitTestSuite
## Unit: low-poly scenery generators (dimensions, determinism, faces pointing out).

const LIGHT: Color = Color(0.7, 0.7, 0.7)
const DARK: Color = Color(0.3, 0.3, 0.3)


func _verts(mesh: ArrayMesh) -> PackedVector3Array:
	return mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]


func _normals(mesh: ArrayMesh) -> PackedVector3Array:
	return mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]


func test_pirca_wall_fills_its_length_and_height() -> void:
	var aabb: AABB = LowPolyMesh.pirca_wall(4.0, 1.6, 0.6, 1, LIGHT, DARK).get_aabb()
	assert_float(aabb.position.x).is_between(-0.1, 0.1)
	assert_float(aabb.end.x).is_between(3.8, 4.1)
	assert_float(aabb.end.y).is_between(1.45, 1.7)
	# Thickness plus stone jitter (±0.06 per corner) and course offset (±0.03).
	assert_float(aabb.size.z).is_between(0.5, 0.9)


func test_pirca_wall_is_deterministic_per_seed() -> void:
	var a := _verts(LowPolyMesh.pirca_wall(3.0, 1.0, 0.5, 7, LIGHT, DARK))
	var b := _verts(LowPolyMesh.pirca_wall(3.0, 1.0, 0.5, 7, LIGHT, DARK))
	var c := _verts(LowPolyMesh.pirca_wall(3.0, 1.0, 0.5, 8, LIGHT, DARK))
	assert_bool(a == b).is_true()
	assert_bool(a == c).is_false()


func test_pirca_stones_vary_between_the_two_colours() -> void:
	var colours: PackedColorArray = (
		LowPolyMesh
		. pirca_wall(4.0, 1.0, 0.5, 3, LIGHT, DARK)
		. surface_get_arrays(0)[Mesh.ARRAY_COLOR]
	)
	var lo: float = 1.0
	var hi: float = 0.0
	for c: Color in colours:
		lo = minf(lo, c.r)
		hi = maxf(hi, c.r)
	assert_float(lo).is_greater_equal(DARK.r - 0.01)
	assert_float(hi).is_less_equal(LIGHT.r + 0.01)
	assert_float(hi - lo).is_greater(0.1)


func test_box_faces_point_outwards() -> void:
	var mesh: ArrayMesh = LowPolyMesh.box(Vector3(2, 1, 3), Color.WHITE, 5, 0.05)
	var verts := _verts(mesh)
	var normals := _normals(mesh)
	var centre: Vector3 = mesh.get_aabb().get_center()
	assert_int(verts.size()).is_equal(36)
	for i: int in range(0, verts.size(), 3):
		var mid: Vector3 = (verts[i] + verts[i + 1] + verts[i + 2]) / 3.0
		assert_float(normals[i].dot(mid - centre)).is_greater(0.0)
		# Godot's front face: (b - a) x (c - a) points inwards.
		var winding: Vector3 = (verts[i + 1] - verts[i]).cross(verts[i + 2] - verts[i])
		assert_float(winding.dot(normals[i])).is_less(0.0)


func test_adobe_house_leaves_a_door_gap() -> void:
	var mesh: ArrayMesh = LowPolyMesh.adobe_house_walls(
		Vector3(4, 2.2, 3), 0.4, Vector2(0.9, 1.7), Color.WHITE, 1
	)
	var aabb: AABB = mesh.get_aabb()
	assert_float(aabb.size.x).is_between(3.9, 4.1)
	assert_float(aabb.size.y).is_between(2.1, 2.3)
	# No geometry in the doorway (front wall, centre, below the lintel).
	var verts := _verts(mesh)
	for v: Vector3 in verts:
		var in_door: bool = absf(v.x) < 0.3 and v.y < 1.5 and v.z > 1.2
		assert_bool(in_door).is_false()


func test_rock_sits_on_the_ground() -> void:
	var aabb: AABB = LowPolyMesh.rock(1.0, 1.2, 4, Color.GRAY).get_aabb()
	assert_float(aabb.position.y).is_between(-0.4, 0.4)
	assert_float(aabb.end.y).is_greater(1.8)


func test_mountain_is_a_unit_cone_to_scale() -> void:
	var aabb: AABB = LowPolyMesh.mountain(9, Color.GRAY).get_aabb()
	assert_float(aabb.position.y).is_equal_approx(0.0, 0.01)
	assert_float(aabb.end.y).is_between(0.9, 1.1)
	assert_float(aabb.size.x).is_between(1.6, 2.4)


func test_ground_follows_the_height_function() -> void:
	var slope := func(xz: Vector2) -> float: return xz.y * 0.5
	var mesh: ArrayMesh = LowPolyMesh.ground(Vector2(10, 10), 5, slope, DARK, LIGHT, 1)
	assert_int(_verts(mesh).size()).is_equal(5 * 5 * 6)
	assert_float(mesh.get_aabb().size.y).is_equal_approx(5.0, 0.01)
	for n: Vector3 in _normals(mesh):
		assert_float(n.y).is_greater(0.0)

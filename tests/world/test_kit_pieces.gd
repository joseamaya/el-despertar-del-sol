extends GdUnitTestSuite
## Unit: modular kit v1 — sizes from the visual guide, faces pointing out, openings.

var _p: PaletteTuning


func before() -> void:
	_p = load("res://resources/style/palette_amanecer_calido.tres") as PaletteTuning


func _verts(mesh: ArrayMesh) -> PackedVector3Array:
	return mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]


func _assert_front_faces_match_normals(mesh: ArrayMesh) -> void:
	var arrays: Array = mesh.surface_get_arrays(0)
	var v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var n: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var bad: int = 0
	for i: int in range(0, v.size(), 3):
		var winding: Vector3 = (v[i + 1] - v[i]).cross(v[i + 2] - v[i])
		if winding.dot(n[i]) > 0.0:
			bad += 1
	assert_int(bad).is_equal(0)


func test_every_catalog_piece_has_geometry() -> void:
	for entry: Array in KitCatalog.pieces(_p):
		var mesh: ArrayMesh = entry[1]
		assert_int(mesh.get_surface_count()).override_failure_message(entry[0]).is_equal(1)
		assert_int(_verts(mesh).size()).override_failure_message(entry[0]).is_greater(36)
		_assert_front_faces_match_normals(mesh)


func test_terrace_wall_has_its_height_and_a_coping() -> void:
	var aabb: AABB = KitWalls.terrace_wall(4.0, 1.6, 1.0, 1, _p).get_aabb()
	assert_float(aabb.end.y).is_between(1.5, 1.7)
	# The slabs jut out past the stones on the front (+Z).
	assert_float(aabb.end.z).is_greater(0.55)


func test_boundary_wall_is_about_a_metre() -> void:
	var aabb: AABB = KitWalls.boundary_wall(4.0, 1.0, 2, _p).get_aabb()
	assert_float(aabb.end.y).is_between(0.85, 1.2)


func test_stairs_reach_the_drop_and_climb_towards_minus_z() -> void:
	var aabb: AABB = KitWalls.stairs(1.6, 1.8, 0.2, 0.3, 4, _p).get_aabb()
	assert_float(aabb.end.y).is_between(1.55, 1.65)
	assert_float(aabb.position.z).is_between(-0.1, 0.1)
	assert_float(aabb.end.z).is_between(2.3, 2.5)


func test_house_follows_the_scale_of_the_guide() -> void:
	var mesh: ArrayMesh = KitBuildings.house(Vector3(4.5, 2.2, 3.6), 5, _p)
	var aabb: AABB = mesh.get_aabb()
	assert_float(aabb.size.x).is_between(4.5, 6.0)
	assert_float(aabb.end.y).is_between(3.9, 4.5)
	# The doorway (front wall, centre, below the lintel) is open.
	for v: Vector3 in _verts(mesh):
		var in_door: bool = absf(v.x) < 0.3 and v.y > 0.05 and v.y < 1.55 and absf(v.z - 1.6) < 0.2
		assert_bool(in_door).is_false()


## F9 task 4: a shut house has its doorway walled up with stones.
func test_a_closed_house_has_its_door_walled_up() -> void:
	var mesh: ArrayMesh = KitBuildings.house(Vector3(4.5, 2.2, 3.6), 5, _p, true)
	var in_door: int = 0
	for v: Vector3 in _verts(mesh):
		if absf(v.x) < 0.3 and v.y > 0.05 and v.y < 1.55 and absf(v.z - 1.6) < 0.2:
			in_door += 1
	assert_int(in_door).is_greater(0)


## F9 task 4: the square's huaca is taller and narrower than the slice's.
func test_the_square_huaca_stands_taller_than_the_slice_one() -> void:
	var standing: AABB = KitBuildings.standing_huaca(16, _p).get_aabb()
	var slice: AABB = KitBuildings.huaca(16, _p).get_aabb()
	assert_float(standing.end.y).is_between(3.2, 4.2)
	assert_float(standing.end.y).is_greater(slice.end.y)


func test_corral_leaves_its_opening_downhill() -> void:
	var segments: Array[Array] = KitWalls.corral_segments(4.0, 40.0)
	assert_int(segments.size()).is_greater(5)
	for seg: Array in segments:
		var xf: Transform3D = seg[0]
		var mid: Vector3 = xf.origin + xf.basis.x * float(seg[1]) * 0.5
		var angle: float = atan2(mid.x, mid.z)
		assert_float(absf(angle)).is_greater(deg_to_rad(20.0))


func test_channel_carries_water_colour() -> void:
	var colours: PackedColorArray = KitWalls.channel(3.0, 1, _p).surface_get_arrays(0)[
		Mesh.ARRAY_COLOR
	]
	# Vertex colours are stored with 8 bits per channel: compare loosely.
	var found: bool = false
	for c: Color in colours:
		found = (
			found
			or c.is_equal_approx(_p.water)
			or (absf(c.r - _p.water.r) + absf(c.g - _p.water.g) + absf(c.b - _p.water.b) < 0.03)
		)
	assert_bool(found).is_true()


func test_pieces_are_deterministic() -> void:
	var a := _verts(KitBuildings.house(Vector3(4.5, 2.2, 3.6), 5, _p))
	var b := _verts(KitBuildings.house(Vector3(4.5, 2.2, 3.6), 5, _p))
	assert_bool(a == b).is_true()


func test_catalog_scene_builds() -> void:
	var runner := scene_runner("res://scenes/tests/kit_catalog.tscn")
	await runner.simulate_frames(2)
	var meshes: Array[Node] = runner.scene().find_children("*", "MeshInstance3D", true, false)
	assert_int(meshes.size()).is_equal(KitCatalog.pieces(_p).size() + 1)


func test_catalog_has_a_review_camera_that_moves() -> void:
	var runner := scene_runner("res://scenes/tests/kit_catalog.tscn")
	var catalog := runner.scene() as KitCatalog
	await runner.simulate_frames(2)
	assert_bool(catalog.camera.current).is_true()
	var before: Vector3 = catalog.camera.position
	Input.action_press(&"move_right")
	await runner.simulate_frames(20)
	Input.action_release(&"move_right")
	assert_float(catalog.camera.position.x).is_greater(before.x)


## F4 task 12c: what the people who fled left behind is small and lies on the ground.
func test_traces_are_small_and_on_the_ground() -> void:
	for kind: int in KitProps.Kind.size():
		var aabb: AABB = KitProps.piece(kind as KitProps.Kind, 3, _p).get_aabb()
		var label: String = KitProps.Kind.keys()[kind]
		assert_float(aabb.position.y).override_failure_message(label).is_between(-0.1, 0.05)
		assert_float(aabb.end.y).override_failure_message(label).is_between(0.05, 0.6)
		assert_float(maxf(aabb.size.x, aabb.size.z)).override_failure_message(label).is_less(1.2)

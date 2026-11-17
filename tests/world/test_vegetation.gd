extends GdUnitTestSuite
## Vegetation of Carmenca: cheap (chunks, visibility range, no ichu shadows) and out of
## the way (no plant on the path, the stairs or the encounter zones).

const SCENE: String = "res://scenes/levels/carmenca.tscn"

var _runner: GdUnitSceneRunner
var _level: SectorLevel


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	await _runner.simulate_frames(2)


func _chunks() -> Array[Node]:
	return (_level.sector.get_node("Vegetation") as Node3D).get_children()


func test_plants_grow_in_chunks_with_a_draw_distance() -> void:
	var chunks: Array[Node] = _chunks()
	assert_int(chunks.size()).is_greater(20)
	for node: Node in chunks:
		var mm := node as MultiMeshInstance3D
		var range_end: float = _level.layout.plant_range + _level.layout.plant_chunk * 0.5
		assert_float(mm.visibility_range_end).is_equal_approx(range_end, 0.01)
		if String(node.name).begins_with("Ichu"):
			assert_int(mm.cast_shadow).is_equal(GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)


func _all_plants() -> Array[Transform3D]:
	var out: Array[Transform3D] = []
	# Placement data, not the MultiMesh: headless runs do not keep instance transforms.
	for c: Dictionary in SectorVegetation.placements(_level.layout):
		for xf: Transform3D in c["ichu"]:
			out.append(xf)
		for xf: Transform3D in c["shrub"]:
			out.append(xf)
	return out


func test_no_plant_on_the_path_stairs_or_encounter_zones() -> void:
	var l: SectorLayout = _level.layout
	var steps: PackedVector3Array = l.terrace_steps()
	var plants: Array[Transform3D] = _all_plants()
	assert_int(plants.size()).is_greater(3000)
	for xf: Transform3D in plants:
		var xz := Vector2(xf.origin.x, xf.origin.z)
		assert_bool(SectorVegetation.is_clear(l, steps, xz)).is_true()
		assert_float(l.distance_to_path(xz)).is_greater(l.path_width * 0.5)
		for e: Vector3 in l.encounters:
			assert_float(xz.distance_to(Vector2(e.x, e.y))).is_greater(e.z)


func test_plants_sit_on_the_ground() -> void:
	var l: SectorLayout = _level.layout
	var plants: Array[Transform3D] = _all_plants()
	for i: int in range(0, plants.size(), 25):
		var at: Vector3 = plants[i].origin
		assert_float(at.y).is_equal_approx(l.height_at(at.x, at.z), 0.2)


func test_chunk_nodes_match_the_placement_data() -> void:
	var expected: int = 0
	for c: Dictionary in SectorVegetation.placements(_level.layout):
		expected += 1 if not (c["ichu"] as Array).is_empty() else 0
		expected += 1 if not (c["shrub"] as Array).is_empty() else 0
	assert_int(_chunks().size()).is_equal(expected)


func test_ichu_tuft_is_tiny() -> void:
	var p := PaletteTuning.new()
	var mesh: ArrayMesh = KitPlants.ichu_tuft(0.8, 1, p)
	var verts: PackedVector3Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	assert_int(verts.size() / 3).is_equal(KitPlants.BLADES * 2)
	assert_float(mesh.get_aabb().end.y).is_between(0.55, 1.0)
	var shrub: ArrayMesh = KitPlants.shrub(0.6, 1, p)
	var shrub_verts: PackedVector3Array = shrub.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	assert_int(shrub_verts.size() / 3).is_less_equal(40)

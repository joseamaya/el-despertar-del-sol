extends GdUnitTestSuite
## SectorNavigation (F3 task 9): the navmesh of every level of the chapter reaches both
## ends of its path. F10 task 6a: the baking filter was given in world space, so the
## rotated sectors lost the last ~20 m of each end (mission B's mouth was off the mesh).

const CATALOG: String = "res://resources/levels/level_catalog.tres"
## How far from the mesh an end of the path may be.
const NEAR: float = 1.0


func test_the_navmesh_reaches_both_ends_of_every_path() -> void:
	var catalog := load(CATALOG) as LevelCatalog
	var seen: Array[String] = []
	for id: StringName in catalog.levels:
		var path: String = catalog.path_of(id)
		if seen.has(path):
			continue
		seen.append(path)
		var scene: Node = (load(path) as PackedScene).instantiate()
		add_child(scene)
		var level := scene.find_child("SectorLevel", true, false) as SectorLevel
		var map: RID = level.get_world_3d().navigation_map
		for i: int in 120:
			await get_tree().physics_frame
			if i >= 10 and NavigationServer3D.map_get_iteration_id(map) > 0:
				break
		var ends: Array[Vector2] = [level.layout.path[0], level.layout.path[-1]]
		for end: Vector2 in ends:
			var at: Vector3 = level.to_global_point(end)
			var closest: Vector3 = NavigationServer3D.map_get_closest_point(map, at)
			(
				assert_float(Vector2(closest.x - at.x, closest.z - at.z).length())
				. override_failure_message("%s: %s is off the navmesh" % [path.get_file(), end])
				. is_less(NEAR)
			)
		scene.free()
		await get_tree().physics_frame

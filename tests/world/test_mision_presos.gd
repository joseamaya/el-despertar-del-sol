extends GdUnitTestSuite
## Mission B's zone (F10 task 6a, `docs/fases/F10-diseno-misiones.md` §4): a narrow
## ravine with a stream, a lookout and the scouts' camp in a hollow at the far end. The
## chapter loads it for the mission; the stream keeps off the path, and Cusi can walk from
## the mouth to every point of the mission.

const LAYOUT: String = "res://resources/levels/presos_layout.tres"
const SCENE: String = "res://scenes/levels/mision_presos.tscn"
const CATALOG: String = "res://resources/levels/level_catalog.tres"
const POINTS: Array[StringName] = [
	&"Boca", &"Emboscada", &"Mirador", &"Campamento", &"Preso_1", &"Preso_2", &"Preso_3"
]
## How close the navmesh path has to end to a point to count as reaching it.
const REACHED: float = 1.0

var _layout: SectorLayout


func before_test() -> void:
	_layout = load(LAYOUT) as SectorLayout


func test_the_chapter_plays_the_mission_here() -> void:
	var catalog := load(CATALOG) as LevelCatalog
	assert_str(catalog.path_of(&"mision_presos")).is_equal(SCENE)


func test_the_mission_points_and_no_huaca_or_llamas() -> void:
	for point: StringName in POINTS:
		assert_bool(_layout.points.has(point)).override_failure_message(point).is_true()
	assert_bool(_layout.has_huaca).is_false()
	assert_bool(_layout.has_llamas).is_false()


func test_the_stream_keeps_off_the_path() -> void:
	var clear: float = _layout.stream_width * 0.5 + 0.6 + _layout.path_width * 0.5
	for line: PackedVector2Array in _layout.streams:
		for s: int in line.size() - 1:
			for p: int in _layout.path.size() - 1:
				for t: float in [0.0, 0.25, 0.5, 0.75, 1.0]:
					var at: Vector2 = line[s].lerp(line[s + 1], t)
					var near: Vector2 = Geometry2D.get_closest_point_to_segment(
						at, _layout.path[p], _layout.path[p + 1]
					)
					(
						assert_float(at.distance_to(near))
						. override_failure_message("stream at %s on the path" % at)
						. is_greater(clear)
					)


func test_every_point_can_be_walked_to_from_the_mouth() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	var level := runner.find_child("SectorLevel") as SectorLevel
	# The navmesh is baked in _ready; the map takes a few physics frames to sync, more
	# when the machine is busy.
	var map: RID = level.get_world_3d().navigation_map
	for i: int in 120:
		await get_tree().physics_frame
		if i >= 10 and NavigationServer3D.map_get_iteration_id(map) > 0:
			break
	var from: Vector3 = level.to_global_point(_layout.start)
	for key: StringName in _layout.points:
		var goal: Vector3 = level.to_global_point(_layout.points[key])
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, from, goal, true)
		assert_int(path.size()).override_failure_message(String(key)).is_greater(1)
		if path.size() < 2:
			continue
		var end: Vector3 = path[path.size() - 1]
		(
			assert_float(Vector2(end.x - goal.x, end.z - goal.z).length())
			. override_failure_message(
				"%s: the path ends %s from it" % [key, end.distance_to(goal)]
			)
			. is_less(REACHED)
		)

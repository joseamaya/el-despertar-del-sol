extends GdUnitTestSuite
## Mission A's zone (F10 task 4a, `docs/fases/F10-diseno-misiones.md` §3): a farming slope
## with the ayllu's houses and plundered stores below, terraces, and the porters' camp up
## by the pass. The chapter loads it for the mission; the path is free of houses, its turns
## are off the stairs (a turn on a stair left the walker stuck against its side), and Cusi
## can walk from the arrival to every point of the mission.

const LAYOUT: String = "res://resources/levels/provisiones_layout.tres"
const SCENE: String = "res://scenes/levels/mision_provisiones.tscn"
const CATALOG: String = "res://resources/levels/level_catalog.tres"
const POINTS: Array[StringName] = [&"Ayllu", &"Depositos", &"Rastro", &"Porteadores"]
## How close the navmesh path has to end to a point to count as reaching it.
const REACHED: float = 1.0
## Room kept around a stair, so the walker turns before or after it.
const STAIR_CLEAR: float = 0.5

var _layout: SectorLayout


func before_test() -> void:
	_layout = load(LAYOUT) as SectorLayout


func test_the_chapter_plays_the_mission_here() -> void:
	var catalog := load(CATALOG) as LevelCatalog
	assert_str(catalog.path_of(&"mision_provisiones")).is_equal(SCENE)


func test_the_mission_points_and_no_huaca_or_llamas() -> void:
	for point: StringName in POINTS:
		assert_bool(_layout.points.has(point)).override_failure_message(point).is_true()
	assert_bool(_layout.has_huaca).is_false()
	assert_bool(_layout.has_llamas).is_false()


func test_the_path_is_free_of_houses() -> void:
	for index: int in _layout.houses.size():
		var h: Vector3 = _layout.houses[index]
		var size: Vector3 = _layout.house_size_at(index)
		var clear: float = maxf(size.x, size.z) * 0.5 + _layout.path_width * 0.5
		var house := Vector2(h.x, h.y)
		for i: int in _layout.path.size() - 1:
			var near: Vector2 = Geometry2D.get_closest_point_to_segment(
				house, _layout.path[i], _layout.path[i + 1]
			)
			(
				assert_float(house.distance_to(near))
				. override_failure_message("house at (%.0f, %.0f) on the path" % [h.x, h.y])
				. is_greater(clear)
			)


func test_the_path_turns_off_the_stairs() -> void:
	for step: Vector3 in _layout.terrace_steps():
		var x: float = _layout.path_x_at(step.x)
		assert_bool(is_nan(x)).override_failure_message("no path over %s" % step.x).is_false()
		var run: float = ceili((step.z - step.y) / SectorBuilder.STEP_RISE) * SectorBuilder.STEP_RUN
		for p: Vector2 in _layout.path:
			var beside: bool = absf(p.x - x) < SectorBuilder.STAIR_WIDTH * 0.5 + STAIR_CLEAR
			var along: bool = p.y > step.x - STAIR_CLEAR and p.y < step.x + run + STAIR_CLEAR
			(
				assert_bool(beside and along)
				. override_failure_message("turn (%s, %s) on the stair at %s" % [p.x, p.y, step.x])
				. is_false()
			)


func test_every_point_can_be_walked_to_from_the_arrival() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	var level := runner.find_child("SectorLevel") as SectorLevel
	# The navmesh is baked in _ready; the map takes a few physics frames to sync, more
	# when the machine is busy (a fixed wait failed once in the full suite).
	var map: RID = level.get_world_3d().navigation_map
	for i: int in 120:
		await get_tree().physics_frame
		if i >= 10 and NavigationServer3D.map_get_iteration_id(map) > 0:
			break
	var from: Vector3 = level.to_global_point(_layout.start)
	var goals: Dictionary = _layout.points.duplicate()
	goals[&"Ending"] = _layout.ending
	for key: StringName in goals:
		var goal: Vector3 = level.to_global_point(goals[key] as Vector2)
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

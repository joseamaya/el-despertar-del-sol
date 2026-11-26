extends GdUnitTestSuite
## The hub of the Cusco (F9 task 3, `docs/fases/F9-diseno-centro.md`): the path is free of
## houses, nobody stands inside a house, and Cusi can walk from the arrival to every
## curaca, Apo Mayta and Vicaquirao.

const LAYOUT: String = "res://resources/levels/centro_layout.tres"
const SCENE: String = "res://scenes/levels/centro.tscn"
## How close the navmesh path has to end to a point to count as reaching it.
const REACHED: float = 1.0

var _layout: SectorLayout


func before_test() -> void:
	_layout = load(LAYOUT) as SectorLayout


func _people() -> Dictionary:
	var at: Dictionary = _layout.points.duplicate()
	at[&"Mentor"] = _layout.mentor
	return at


## Half of the longest side of house `index` (F9 task 4: big houses are longer).
func _reach(index: int) -> float:
	var size: Vector3 = _layout.house_size_at(index)
	return maxf(size.x, size.z) * 0.5


func test_the_path_is_free_of_houses() -> void:
	for index: int in _layout.houses.size():
		var h: Vector3 = _layout.houses[index]
		var clear: float = _reach(index) + _layout.path_width * 0.5
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


func test_nobody_stands_inside_a_house() -> void:
	var people: Dictionary = _people()
	for key: StringName in people:
		var p: Vector2 = people[key]
		for index: int in _layout.houses.size():
			var h: Vector3 = _layout.houses[index]
			(
				assert_float(p.distance_to(Vector2(h.x, h.y)))
				. override_failure_message("%s inside the house at (%.0f, %.0f)" % [key, h.x, h.y])
				. is_greater(_reach(index) + 0.5)
			)


func test_three_curacas_and_apo_mayta() -> void:
	for curaca: StringName in [
		&"Curaca_llamas", &"Curaca_prisioneros", &"Curaca_disputa", &"ApoMayta"
	]:
		assert_bool(_layout.points.has(curaca)).override_failure_message(curaca).is_true()


func test_every_point_can_be_walked_to_from_the_arrival() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	var level := runner.find_child("SectorLevel") as SectorLevel
	# The navmesh is baked in _ready; the map takes a few physics frames to sync.
	for i: int in 10:
		await get_tree().physics_frame
	var map: RID = level.get_world_3d().navigation_map
	var from: Vector3 = level.to_global_point(_layout.start)
	var people: Dictionary = _people()
	for key: StringName in people:
		var goal: Vector3 = level.to_global_point(people[key] as Vector2)
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, from, goal, true)
		assert_int(path.size()).override_failure_message(String(key)).is_greater(1)
		var end: Vector3 = path[path.size() - 1]
		(
			assert_float(Vector2(end.x - goal.x, end.z - goal.z).length())
			. override_failure_message(
				"%s: the path ends %s from it" % [key, end.distance_to(goal)]
			)
			. is_less(REACHED)
		)

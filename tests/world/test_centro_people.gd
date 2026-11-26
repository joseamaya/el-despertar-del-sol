extends GdUnitTestSuite
## The people of the hub (F9 task 7): a half-empty Cusco, so only a few, sitting, kneeling,
## on guard or going round on errands, some with a line in passing. None stands or walks
## where someone gives a mission, through a house, a wall or the huaca, and the ones who
## walk keep going round instead of leaving.

const LAYOUT: String = "res://resources/levels/centro_layout.tres"
const PEOPLE: String = "res://resources/levels/centro_people.tres"
const SCENE: String = "res://scenes/levels/centro.tscn"
## HubTalks' radius plus a body: nobody in the way of a talk.
const TALK_CLEAR: float = 3.5
const HOUSE_CLEAR: float = 0.6
const WALL_CLEAR: float = 0.8

var _layout: SectorLayout
var _people: SectorPeople


func before_test() -> void:
	_layout = load(LAYOUT) as SectorLayout
	_people = load(PEOPLE) as SectorPeople


## Points every person stands on or walks through, sampled every half metre.
func _points(person: SectorPerson) -> PackedVector2Array:
	if person.route.size() < 2:
		return PackedVector2Array([person.at])
	var out := PackedVector2Array()
	var route: PackedVector2Array = person.route.duplicate()
	if person.loop:
		route.append(route[0])
	for i: int in route.size() - 1:
		var steps: int = maxi(1, ceili(route[i].distance_to(route[i + 1]) * 2.0))
		for k: int in steps + 1:
			out.append(route[i].lerp(route[i + 1], float(k) / steps))
	return out


func _talk_spots() -> PackedVector2Array:
	var out := PackedVector2Array([_layout.mentor])
	for key: StringName in _layout.points:
		out.append(_layout.points[key])
	return out


func test_only_a_few() -> void:
	assert_int(_people.people.size()).is_between(6, 8)
	var walkers: int = 0
	var lines: int = 0
	for person: SectorPerson in _people.people:
		walkers += 1 if person.route.size() >= 2 else 0
		lines += 1 if person.line != &"" else 0
	assert_int(walkers).is_greater(1)
	assert_int(lines).is_greater(1)


func test_nobody_in_the_way_of_a_talk() -> void:
	for i: int in _people.people.size():
		for p: Vector2 in _points(_people.people[i]):
			for spot: Vector2 in _talk_spots():
				(
					assert_float(p.distance_to(spot))
					. override_failure_message("person %d at %s" % [i, p])
					. is_greater(TALK_CLEAR)
				)


func test_nobody_goes_through_houses_walls_or_the_huaca() -> void:
	for i: int in _people.people.size():
		for p: Vector2 in _points(_people.people[i]):
			var where: String = "person %d at %s" % [i, p]
			for h: int in _layout.houses.size():
				var house: Vector3 = _layout.houses[h]
				var size: Vector3 = _layout.house_size_at(h)
				var local: Vector2 = (p - Vector2(house.x, house.y)).rotated(deg_to_rad(house.z))
				var inside: bool = (
					absf(local.x) < size.x * 0.5 + HOUSE_CLEAR
					and absf(local.y) < size.z * 0.5 + HOUSE_CLEAR
				)
				assert_bool(inside).override_failure_message(where + " in house %d" % h).is_false()
			for w: Vector4 in _layout.boundary_walls:
				var near: Vector2 = Geometry2D.get_closest_point_to_segment(
					p, Vector2(w.x, w.y), Vector2(w.z, w.w)
				)
				assert_float(p.distance_to(near)).override_failure_message(where).is_greater(
					WALL_CLEAR
				)
			(
				assert_bool(_layout.near_shrine(p, SectorTown.RING_RADIUS + 0.5))
				. override_failure_message(where)
				. is_false()
			)


func test_every_line_has_its_text() -> void:
	for person: SectorPerson in _people.people:
		if person.line == &"":
			continue
		assert_str(tr(person.line)).is_not_equal(String(person.line))
		assert_str(tr(person.speaker)).is_not_equal(String(person.speaker))


func test_the_walkers_go_round_instead_of_leaving() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	(runner.find_child("CameraRig") as CameraController).capture_mouse = false
	var crowd := runner.find_child("Crowd") as SectorCrowd
	var level := runner.find_child("SectorLevel") as SectorLevel
	var left: Array[int] = []
	crowd.person_left.connect(func(i: int) -> void: left.append(i))
	await runner.simulate_frames(5)
	assert_int(crowd.count()).is_equal(_people.people.size())
	Engine.time_scale = 4.0
	# The plaza walker's loop is about 35 m: more than one round at 1.25 m/s.
	var walker: int = 4
	var start: Vector3 = level.to_global_point(_people.people[walker].route[0])
	var far: float = 0.0
	for i: int in 60 * 40 / 4:
		await get_tree().physics_frame
		var at: Vector3 = crowd.body(walker).global_position
		far = maxf(far, Vector2(at.x - start.x, at.z - start.z).length())
	Engine.time_scale = 1.0
	assert_array(left).is_empty()
	assert_float(far).is_greater(5.0)
	assert_bool(crowd.is_active(walker)).is_true()


func after_test() -> void:
	Engine.time_scale = 1.0

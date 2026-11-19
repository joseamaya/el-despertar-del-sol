extends GdUnitTestSuite
## Unit: SectorLayout heights and terrace detection; data checks on the Carmenca layout.

const CARMENCA: String = "res://resources/levels/carmenca_layout.tres"
## The player's floor_max_angle is 45°; keep the path well below it.
const MAX_PATH_GRADE: float = 0.7


func _simple() -> SectorLayout:
	var l := SectorLayout.new()
	l.profile = PackedVector2Array(
		[Vector2(10, 0), Vector2(0, 0), Vector2(-1, 1.6), Vector2(-10, 1.6)]
	)
	l.corridor = PackedVector2Array([Vector2(10, 5), Vector2(-10, 5)])
	l.side_grade = 2.0
	return l


func _carmenca() -> SectorLayout:
	return load(CARMENCA) as SectorLayout


func test_height_follows_profile_and_rises_outside_the_corridor() -> void:
	var l := _simple()
	assert_float(l.height_at(0, 5)).is_equal_approx(0.0, 0.001)
	assert_float(l.height_at(0, -5)).is_equal_approx(1.6, 0.001)
	assert_float(l.height_at(0, -0.5)).is_equal_approx(0.8, 0.001)
	assert_float(l.height_at(7, 5)).is_equal_approx(4.0, 0.001)
	assert_float(l.height_at(-7, 5)).is_equal_approx(4.0, 0.001)


func test_steep_profile_segments_are_terrace_steps() -> void:
	var steps: PackedVector3Array = _simple().terrace_steps()
	assert_int(steps.size()).is_equal(1)
	assert_vector(steps[0]).is_equal(Vector3(0, 0, 1.6))


func test_long_steep_segments_are_cliffs_not_terraces() -> void:
	var l := _simple()
	l.profile.append(Vector2(-30, 30.0))
	assert_int(l.terrace_steps().size()).is_equal(1)


func test_profile_order_does_not_matter() -> void:
	var l := _simple()
	var shuffled := PackedVector2Array(
		[Vector2(-1, 1.6), Vector2(10, 0), Vector2(-10, 1.6), Vector2(0, 0)]
	)
	l.profile = shuffled
	assert_float(l.height_at(0, -0.5)).is_equal_approx(0.8, 0.001)


func test_carmenca_path_is_walkable_except_at_stairs() -> void:
	var l := _carmenca()
	var steps: PackedVector3Array = l.terrace_steps()
	for i: int in range(l.path.size() - 1):
		var a: Vector2 = l.path[i]
		var b: Vector2 = l.path[i + 1]
		var pieces: int = maxi(1, int(a.distance_to(b) * 2.0))
		for k: int in pieces:
			var p0: Vector2 = a.lerp(b, float(k) / pieces)
			var p1: Vector2 = a.lerp(b, float(k + 1) / pieces)
			var on_stairs: bool = false
			for s: Vector3 in steps:
				on_stairs = on_stairs or (minf(p0.y, p1.y) <= s.x and maxf(p0.y, p1.y) >= s.x - 1.0)
			if on_stairs:
				continue
			var grade: float = absf(l.height_at(p1.x, p1.y) - l.height_at(p0.x, p0.y))
			grade /= maxf(p0.distance_to(p1), 0.001)
			(
				assert_float(grade)
				. override_failure_message("Path too steep near %s: %.2f" % [p0, grade])
				. is_less_equal(MAX_PATH_GRADE)
			)


func test_carmenca_path_crosses_every_terrace_once() -> void:
	var l := _carmenca()
	var steps: PackedVector3Array = l.terrace_steps()
	assert_int(steps.size()).is_equal(7)
	for s: Vector3 in steps:
		var crossings: int = 0
		for i: int in range(l.path.size() - 1):
			if (l.path[i].y - s.x) * (l.path[i + 1].y - s.x) < 0.0:
				crossings += 1
		assert_int(crossings).is_equal(1)


func test_carmenca_path_stays_inside_the_corridor() -> void:
	var l := _carmenca()
	for p: Vector2 in l.path:
		assert_float(absf(p.x)).is_less(l.corridor_half_width(p.y) - 1.0)
	assert_float(l.path_length()).is_between(300.0, 700.0)


func test_carmenca_encounter_zones_are_flat_and_open() -> void:
	var l := _carmenca()
	assert_int(l.encounters.size()).is_equal(3)
	for e: Vector3 in l.encounters:
		var lo: float = INF
		var hi: float = -INF
		for k: int in 16:
			var angle: float = TAU * k / 16.0
			for r: float in [0.0, e.z * 0.5, e.z]:
				var h: float = l.height_at(e.x + cos(angle) * r, e.y + sin(angle) * r)
				lo = minf(lo, h)
				hi = maxf(hi, h)
		assert_float(hi - lo).override_failure_message("Zone %s not flat" % e).is_less(0.8)
		assert_float(l.corridor_half_width(e.y)).is_greater(e.z + absf(e.x))


func test_capped_sides_rise_steeply_then_roll_gently() -> void:
	var l := _simple()
	l.side_max_rise = 4.0
	l.side_far_grade = 0.1
	# Steep band: 2 m of run at grade 2 reach the 4 m cap; then grade 0.1.
	assert_float(l.side_rise(1.0)).is_equal_approx(2.0, 0.001)
	assert_float(l.side_rise(2.0)).is_equal_approx(4.0, 0.001)
	assert_float(l.side_rise(12.0)).is_equal_approx(5.0, 0.001)
	assert_float(l.height_at(15.0, 5.0)).is_equal_approx(4.8, 0.001)
	l.side_max_rise = 0.0
	assert_float(l.side_rise(12.0)).is_equal_approx(24.0, 0.001)


## The player has no jump and floor_max_angle 45°: a band steeper than 1.0 and a few
## metres high keeps them inside, on the sides and past the end of the path.
func test_carmenca_sides_and_end_cannot_be_climbed() -> void:
	var l := _carmenca()
	assert_float(l.side_grade).is_greater(1.0)
	assert_float(l.side_max_rise).is_greater_equal(6.0)
	var last_z: float = INF
	for p: Vector2 in l.path:
		last_z = minf(last_z, p.y)
	var steep_rise: float = 0.0
	var best: float = 0.0
	var z: float = last_z
	while z > -l.size.y * 0.5:
		var dh: float = l.profile_at(z - 0.5) - l.profile_at(z)
		steep_rise = steep_rise + dh if dh > 0.5 else 0.0
		best = maxf(best, steep_rise)
		z -= 0.5
	assert_float(best).is_greater_equal(6.0)


## F4 task 12c: the neighbourhood. Houses stand on level ground, apart from each other,
## off the path and out of the fights; nothing left behind blocks the path or a house.
func test_carmenca_houses_stand_level_off_the_path_and_out_of_the_fights() -> void:
	var l := _carmenca()
	assert_int(l.houses.size()).is_greater_equal(10)
	for i: int in l.houses.size():
		var h: Vector3 = l.houses[i]
		var at := Vector2(h.x, h.y)
		var name: String = "House %s" % h
		assert_float(l.distance_to_path(at)).override_failure_message(name).is_greater(5.0)
		var lo: float = INF
		var hi: float = -INF
		for corner: Vector2 in [Vector2(-2.5, -2.5), Vector2(2.5, -2.5), Vector2(-2.5, 2.5)]:
			var y: float = l.height_at(at.x + corner.x, at.y + corner.y)
			lo = minf(lo, y)
			hi = maxf(hi, y)
		assert_float(hi - lo).override_failure_message(name + " not level").is_less(0.3)
		for e: Vector3 in l.encounters:
			assert_float(at.distance_to(Vector2(e.x, e.y))).is_greater(e.z + 1.5)
		for k: int in range(i + 1, l.houses.size()):
			assert_float(at.distance_to(Vector2(l.houses[k].x, l.houses[k].y))).is_greater(6.0)


func test_carmenca_traces_lie_beside_the_path_not_in_houses() -> void:
	var l := _carmenca()
	var hearths: int = 0
	for prop: Vector4 in l.props:
		var at := Vector2(prop.x, prop.y)
		assert_int(int(prop.w)).is_between(0, KitProps.Kind.size() - 1)
		hearths += 1 if int(prop.w) == KitProps.Kind.HEARTH else 0
		var gap: float = l.distance_to_path(at) - l.path_width * 0.5
		assert_float(gap).override_failure_message("Prop %s on the path" % at).is_greater(0.2)
		for h: Vector3 in l.houses:
			assert_float(at.distance_to(Vector2(h.x, h.y))).is_greater(2.2)
	assert_int(hearths).is_greater_equal(2)

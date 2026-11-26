extends GdUnitTestSuite
## Scouts that walk a round (F9 task 12): in Carmenca one club warrior of each skirmish
## walks a route from the layout. The routes stay clear of houses and crags and can be
## walked; a scout on its round leaves its spawn point, notices Cusi and fights; and once it
## loses him it goes back to its round.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const LAYOUT: String = "res://resources/levels/carmenca_layout.tres"
## Half of the house's longest side (4.5 m), plus room to walk by.
const HOUSE_CLEAR: float = 3.0
## How close the navmesh path has to end to a point to count as reaching it.
const REACHED: float = 1.0

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _arena: ArenaController
var _player: PlayerController


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_arena = _runner.find_child("ArenaController") as ArenaController
	_player = _runner.find_child("Player") as PlayerController
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	(_runner.find_child("SliceDirector") as SliceDirector).set_physics_process(false)
	await _frames(20)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


## Cusi far from every zone, so nobody notices him.
func _player_away() -> void:
	_player.global_position = _level.to_global_point(Vector2(30, 140)) + Vector3.UP * 0.1


## The first warrior of zone `zone` (1-based) once spawned: the scout of the round.
func _scout(zone: int) -> EnemyController:
	_arena.start_zone(zone)
	await _frames(3)
	var index: int = 0
	for i: int in zone - 1:
		index += _arena.zone_sizes[i]
	for enemy: EnemyController in _arena.alive_enemies():
		if enemy.home_position.is_equal_approx(_arena.spawn_points[index].global_position):
			return enemy
	return null


func test_one_club_scout_per_skirmish() -> void:
	var layout := load(LAYOUT) as SectorLayout
	assert_array(layout.patrols.keys()).contains_exactly_in_any_order([0, 2, 4])
	for index: int in layout.patrols:
		assert_bool(_arena.lancer_spawns.has(index)).is_false()
		assert_int(layout.patrols[index].size()).is_greater_equal(2)
	assert_int(_arena.patrol_routes.size()).is_equal(3)


func test_routes_stay_clear_of_houses_and_crags() -> void:
	var layout := load(LAYOUT) as SectorLayout
	for index: int in layout.patrols:
		for p: Vector2 in layout.patrols[index]:
			for h: Vector3 in layout.houses:
				(
					assert_float(p.distance_to(Vector2(h.x, h.y)))
					. override_failure_message(
						"route %d by a house at (%s, %s)" % [index, h.x, h.y]
					)
					. is_greater(HOUSE_CLEAR)
				)
			for c: Vector3 in layout.crags:
				(
					assert_float(p.distance_to(Vector2(c.x, c.y)))
					. override_failure_message("route %d in a crag" % index)
					. is_greater(c.z)
				)


func test_every_route_can_be_walked() -> void:
	var map: RID = _level.get_world_3d().navigation_map
	for index: int in _arena.patrol_routes:
		var route: PackedVector3Array = _arena.patrol_routes[index]
		var from: Vector3 = _arena.spawn_points[index].global_position
		for goal: Vector3 in route:
			var path: PackedVector3Array = NavigationServer3D.map_get_path(map, from, goal, true)
			assert_int(path.size()).override_failure_message("route %d" % index).is_greater(1)
			var end: Vector3 = path[path.size() - 1]
			(
				assert_float(Vector2(end.x - goal.x, end.z - goal.z).length())
				. override_failure_message(
					"route %d: ends %.1f m off" % [index, end.distance_to(goal)]
				)
				. is_less(REACHED)
			)
			from = goal


func test_the_scout_walks_its_round() -> void:
	_player_away()
	var scout: EnemyController = await _scout(1)
	assert_object(scout).is_not_null()
	assert_int(scout.patrol_points.size()).is_equal(3)
	var start: Vector3 = scout.global_position
	var states: Array[String] = []
	for i: int in 300:
		states.append(String(scout.state_machine.current_name()))
		await get_tree().physics_frame
	assert_array(states).contains(["patrol"])
	assert_bool(scout.perception.has_target()).is_false()
	assert_float(scout.distance_to(start)).is_greater(3.0)


func test_the_others_wait_at_their_post() -> void:
	_player_away()
	await _scout(1)
	for enemy: EnemyController in _arena.alive_enemies():
		if enemy.patrol_points.is_empty():
			await _frames(120)
			assert_float(enemy.distance_to(enemy.home_position)).is_less(1.0)
			return
	fail("zone 1 has no warrior waiting at its post")


func test_it_notices_cusi_and_leaves_the_round() -> void:
	_player_away()
	var scout: EnemyController = await _scout(1)
	await _frames(30)
	_player.global_position = scout.global_position + scout.global_basis.z * -4.0
	var noticed: bool = false
	for i: int in 180:
		if scout.perception.has_target():
			noticed = true
			break
		await get_tree().physics_frame
	assert_bool(noticed).is_true()


func test_having_lost_cusi_it_goes_back_to_the_round() -> void:
	_player_away()
	var scout: EnemyController = await _scout(1)
	await _frames(30)
	# As if it had chased Cusi off its round and lost him there: the perception gives up,
	# idle sends it back on patrol.
	var off: Vector3 = _level.to_global_point(Vector2(-6, 109))
	scout.global_position = off
	scout.state_machine.transition_to(&"idle")
	var nearest: Vector3 = scout.patrol_points[EnemyPatrol.nearest_point(scout.patrol_points, off)]
	var closest: float = INF
	# About 9 m back at walking pace.
	for i: int in 720:
		closest = minf(closest, scout.distance_to(nearest))
		await get_tree().physics_frame
	assert_float(closest).is_less(1.0)

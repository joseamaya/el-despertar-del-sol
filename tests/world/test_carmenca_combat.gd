extends GdUnitTestSuite
## Integration: the fights of the slice happen in Carmenca (F3 task 9). The navmesh
## covers the path and the zones; warriors in each zone engage and land hits, also
## down a slope; at the pass no more than two attack at once; a defeat brings back only
## the zone being fought (F4 task 2: one zone at a time).

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const TIME_SCALE: float = 2.0

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _arena: ArenaController
var _player: PlayerController
var _health: HealthComponent


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_arena = _runner.find_child("ArenaController") as ArenaController
	_player = _runner.find_child("Player") as PlayerController
	_health = _player.get_node("Health") as HealthComponent
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	# These tests pick the zone themselves: hold the slice at its opening.
	(_runner.find_child("SliceDirector") as SliceDirector).set_physics_process(false)
	# Let the navigation map pick up the baked region.
	await _frames(20)


func after_test() -> void:
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


## Starts zone `zone` (1-based): only its warriors are in the sector.
func _only_zone(zone: int) -> Array[EnemyController]:
	_arena.start_zone(zone)
	return _arena.alive_enemies()


func _place(local: Vector2) -> void:
	_player.respawn(_level.to_global_point(local) + Vector3.UP * 0.1, 0.0)


func test_navmesh_covers_the_path_and_the_zones() -> void:
	var map: RID = _player.get_world_3d().navigation_map
	var points: Array[Vector3] = []
	for p: Vector2 in _level.layout.path:
		points.append(_level.to_global_point(p))
	for i: int in _level.layout.encounters.size():
		points.append(_level.marker_position(StringName("Encounter%d" % (i + 1))))
	for p: Vector3 in points:
		var closest: Vector3 = NavigationServer3D.map_get_closest_point(map, p)
		(
			assert_float(closest.distance_to(p))
			. override_failure_message("No navmesh near %s" % p)
			. is_less(1.0)
		)


func test_every_zone_has_its_warriors() -> void:
	assert_int(_arena.alive_enemies().size()).is_equal(0)
	for zone: int in range(1, _level.layout.encounters.size() + 1):
		var warriors: Array[EnemyController] = _only_zone(zone)
		assert_int(warriors.size()).is_equal(_level.layout.encounter_enemies[zone - 1])
		var centre: Vector3 = _level.marker_position(StringName("Encounter%d" % zone))
		for w: EnemyController in warriors:
			var flat := Vector2(w.global_position.x - centre.x, w.global_position.z - centre.z)
			assert_float(flat.length()).is_less(_level.layout.encounters[zone - 1].z)
		await _frames(2)


## Puts the player in front of a zone's warriors and waits for a hit (fresh scene per
## zone: a hit's hitstop resets Engine.time_scale, and warriors hold director tokens).
func _zone_lands_a_hit(zone: int) -> bool:
	Engine.time_scale = TIME_SCALE
	var e: Vector3 = _level.layout.encounters[zone - 1]
	_only_zone(zone)
	_place(Vector2(e.x, e.y + 3.0))
	_health.reset()
	for i: int in 1200:
		await get_tree().physics_frame
		if _health.current < _health.get_maximum():
			return true
	return false


func test_skirmish_on_the_terrace_lands_a_hit() -> void:
	assert_bool(await _zone_lands_a_hit(1)).is_true()


func test_skirmish_among_the_houses_lands_a_hit() -> void:
	assert_bool(await _zone_lands_a_hit(2)).is_true()


func test_warriors_chase_down_the_slope() -> void:
	Engine.time_scale = TIME_SCALE
	_only_zone(2)
	var e: Vector3 = _level.layout.encounters[1]
	var z: float = e.y + 3.0
	_place(Vector2(e.x, z))
	await _frames(90)
	# Back off down the slope below the houses at ~2 m/s while they chase, then stand
	# on the slope: they must follow and still hit.
	while z < 24.0:
		z += 1.0
		_place(Vector2(0.0, z))
		await _frames(30)
	var start_y: float = _level.layout.height_at(0.0, e.y)
	assert_float(_player.global_position.y).is_less(start_y - 2.5)
	_health.reset()
	var hit: bool = false
	for i: int in 900:
		await get_tree().physics_frame
		if _health.current < _health.get_maximum():
			hit = true
			break
	assert_bool(hit).is_true()


func test_no_more_than_two_attack_at_the_pass() -> void:
	Engine.time_scale = TIME_SCALE
	var warriors: Array[EnemyController] = _only_zone(3)
	var director := _runner.find_child("EncounterDirector") as EncounterDirector
	var e: Vector3 = _level.layout.encounters[2]
	_place(Vector2(e.x, e.y + 3.0))
	var most: int = 0
	var aware: int = 0
	for i: int in 900:
		await get_tree().physics_frame
		_health.reset()
		most = maxi(most, director.token_count())
		aware = 0
		for w: EnemyController in warriors:
			aware += 1 if w.perception.has_target() else 0
	assert_int(aware).is_equal(warriors.size())
	assert_int(most).is_between(1, 2)


func test_defeat_brings_back_only_the_active_zone() -> void:
	_only_zone(2)
	await _frames(2)
	_place(Vector2(0.0, 20.0))
	_health.apply_damage(_health.get_maximum())
	await _frames(10)
	assert_int(_arena.state).is_equal(ArenaController.EncounterState.DEFEATED)
	_arena.reset_encounter()
	await _frames(3)
	# The slice is held at its opening, so the respawn is still the start.
	var start: Vector3 = _level.marker_position(&"Start")
	assert_float(_player.global_position.distance_to(start)).is_less(1.0)
	assert_int(_arena.alive_enemies().size()).is_equal(_level.layout.encounter_enemies[1])
	assert_bool(_health.is_dead()).is_false()

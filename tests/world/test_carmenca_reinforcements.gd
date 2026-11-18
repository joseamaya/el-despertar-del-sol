extends GdUnitTestSuite
## Integration: the reinforcements at the pass (F4 task 12b). They wait uphill of the
## pass, on the navmesh; when its first warriors fall they are called, appear after a
## beat already hunting the player and come down to them; the pass is won only when they
## fall too; a defeat while they are on their way restarts the pass from its first
## warriors, and the old call never arrives; zones without reinforcements are won at once.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const TIME_SCALE: float = 2.0
const PASS: int = 3

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
	await _frames(20)


func after_test() -> void:
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _kill_all() -> void:
	for enemy: EnemyController in _arena.alive_enemies():
		enemy.health.apply_damage(enemy.health.get_maximum())
	await _frames(3)


func _wait_wave() -> void:
	for i: int in int(_arena.wave_delay * 60.0 / Engine.time_scale) + 30:
		if not _arena.is_wave_pending():
			break
		await _frames(1)


## Starts the pass with the player at its downhill edge.
func _to_the_pass() -> void:
	_arena.start_zone(PASS)
	var zone: Vector3 = _level.layout.encounters[PASS - 1]
	_player.respawn(_level.to_global_point(Vector2(zone.x, zone.y + 6.0)) + Vector3.UP * 0.1, 0.0)
	await _frames(3)


func test_reinforcements_wait_uphill_of_the_pass_on_the_navmesh() -> void:
	assert_int(_arena.wave_size(PASS)).is_equal(3)
	assert_int(_arena.wave_size(1) + _arena.wave_size(2)).is_equal(0)
	assert_int(_arena.wave_points.size()).is_equal(3)
	var pass_at: Vector3 = _level.marker_position(&"Encounter3")
	var map: RID = _player.get_world_3d().navigation_map
	for point: Node3D in _arena.wave_points:
		var at: Vector3 = point.global_position
		var closest: Vector3 = NavigationServer3D.map_get_closest_point(map, at)
		assert_float(closest.distance_to(at)).override_failure_message("navmesh").is_less(1.0)
		# Uphill: higher than the pass and outside it.
		assert_float(at.y).is_greater(pass_at.y)
		var flat := Vector2(at.x - pass_at.x, at.z - pass_at.z)
		assert_float(flat.length()).is_greater(_level.layout.encounters[PASS - 1].z)


func test_the_pass_is_won_only_after_its_reinforcements() -> void:
	Engine.time_scale = TIME_SCALE
	var called: Array[int] = []
	var arrived: Array[int] = []
	var won: Array[int] = []
	_arena.reinforcements_called.connect(func(z: int) -> void: called.append(z))
	_arena.reinforcements_arrived.connect(func(z: int) -> void: arrived.append(z))
	_arena.zone_won.connect(func(z: int) -> void: won.append(z))
	await _to_the_pass()
	await _kill_all()
	assert_array(called).is_equal([PASS])
	assert_array(won).is_empty()
	assert_bool(_arena.is_wave_pending()).is_true()
	assert_bool(_arena.is_zone_won(PASS)).is_false()
	await _wait_wave()
	assert_array(arrived).is_equal([PASS])
	var wave: Array[EnemyController] = _arena.alive_enemies()
	assert_int(wave.size()).is_equal(3)
	for enemy: EnemyController in wave:
		assert_object(enemy.perception.target).is_same(_player)
	# They come down to the player.
	var far: float = wave[0].distance_to(_player.global_position)
	await _frames(int(4.0 * 60.0 / TIME_SCALE))
	assert_float(wave[0].distance_to(_player.global_position)).is_less(far - 5.0)
	assert_bool(_arena.is_zone_engaged()).is_true()
	await _kill_all()
	assert_array(won).is_equal([PASS])
	assert_array(called).is_equal([PASS])


func test_a_defeat_on_the_way_restarts_the_pass_from_its_first_warriors() -> void:
	var arrived: Array[int] = []
	_arena.reinforcements_arrived.connect(func(z: int) -> void: arrived.append(z))
	await _to_the_pass()
	await _kill_all()
	assert_bool(_arena.is_wave_pending()).is_true()
	_health.apply_damage(_health.get_maximum())
	await _frames(10)
	_arena.reset_encounter()
	await _frames(3)
	assert_int(_arena.alive_enemies().size()).is_equal(_level.layout.encounter_enemies[PASS - 1])
	assert_bool(_arena.is_wave_pending()).is_false()
	# The old call never arrives.
	await _frames(int(_arena.wave_delay * 60.0) + 30)
	assert_array(arrived).is_empty()
	assert_int(_arena.alive_enemies().size()).is_equal(_level.layout.encounter_enemies[PASS - 1])


func test_zones_without_reinforcements_are_won_at_once() -> void:
	var won: Array[int] = []
	_arena.zone_won.connect(func(z: int) -> void: won.append(z))
	_arena.start_zone(1)
	await _frames(2)
	await _kill_all()
	assert_array(won).is_equal([1])
	assert_bool(_arena.is_wave_pending()).is_false()

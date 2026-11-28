extends GdUnitTestSuite
## Integration: mission A, «Lo que se llevaron» (F10 task 4b, `F10-diseno-misiones.md` §3).
## The woman tells what happened; two clubs at the stores, a scout walking the terraces and
## the porters (a lancer and two clubs) at the pass, one at a time; the three bundles are
## picked up and taken back to the ayllu. A defeat goes back to the last checkpoint. The
## player is teleported and warriors are killed outright: this checks the flow.

const SCENE: String = "res://scenes/levels/mision_provisiones.tscn"
const LANCER: String = "res://scenes/enemies/chanca_lancer.tscn"
const BUNDLES: Array[StringName] = [&"Fardo_maiz", &"Fardo_chuno", &"Fardo_charqui"]

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _arena: ArenaController
var _slice: SliceDirector
var _player: PlayerController
var _health: HealthComponent
var _bundles: PickupProps


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_arena = _runner.find_child("ArenaController") as ArenaController
	_slice = _runner.find_child("SliceDirector") as SliceDirector
	_player = _runner.find_child("Player") as PlayerController
	_health = _player.get_node("Health") as HealthComponent
	_bundles = _runner.find_child("Fardos") as PickupProps
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _kill_zone() -> void:
	for enemy: EnemyController in _arena.alive_enemies():
		enemy.health.apply_damage(enemy.health.get_maximum())
	await _frames(3)


func _go_to(marker: StringName) -> void:
	_player.respawn(_level.marker_position(marker) + Vector3.UP * 0.1, 0.0)
	await _frames(3)


func _finish_step() -> void:
	var step: SliceStep = _slice.flow.current()
	match step.kind:
		SliceStep.Kind.REACH:
			await _go_to(step.marker)
		SliceStep.Kind.ENCOUNTER:
			await _kill_zone()
		SliceStep.Kind.DIALOGUE:
			var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
			while talk.is_playing():
				talk.advance()
			await _frames(2)
		SliceStep.Kind.INTERACT:
			await _go_to(step.marker)
			(_runner.find_child("InteractionPoint") as InteractionPoint).try_interact()
			await _frames(2)
		_:
			assert_bool(false).override_failure_message("unexpected step %s" % step.kind).is_true()


func _play_to_zone(zone: int) -> void:
	while not (
		_slice.flow.current().kind == SliceStep.Kind.ENCOUNTER
		and _slice.flow.current().zone == zone
	):
		await _finish_step()


func test_every_marker_and_zone_of_the_sequence_exists() -> void:
	for step: SliceStep in _slice.sequence.steps:
		if step.marker != &"":
			(
				assert_object(_level.marker_node(step.marker))
				. override_failure_message(step.marker)
				. is_not_null()
			)
		if step.checkpoint != &"":
			(
				assert_object(_level.marker_node(step.checkpoint))
				. override_failure_message(step.checkpoint)
				. is_not_null()
			)
		if step.kind == SliceStep.Kind.ENCOUNTER:
			assert_int(step.zone).is_between(1, _level.layout.encounters.size())


func test_the_woman_tells_what_happened_on_arrival() -> void:
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.REACH)
	assert_int(_arena.alive_enemies().size()).is_equal(0)
	await _finish_step()
	var box := _runner.find_child("DialogueBox") as DialogueBox
	assert_str(box.shown_text()).is_equal(tr(&"DLG_PROV_ARRIVE_1"))
	await _finish_step()
	assert_int(_arena.active_zone).is_equal(1)
	assert_int(_arena.alive_enemies().size()).is_equal(2)
	assert_object(_arena.player_spawn).is_same(_level.marker_node(&"Checkpoint1"))


func test_a_scout_walks_the_terraces() -> void:
	await _play_to_zone(2)
	var alive: Array[EnemyController] = _arena.alive_enemies()
	assert_int(alive.size()).is_equal(1)
	assert_int(alive[0].patrol_points.size()).is_equal(2)
	assert_object(_arena.player_spawn).is_same(_level.marker_node(&"Checkpoint2"))


func test_the_porters_are_a_lancer_and_two_clubs() -> void:
	await _play_to_zone(3)
	var lancers: int = 0
	for enemy: EnemyController in _arena.alive_enemies():
		lancers += 1 if enemy.scene_file_path == LANCER else 0
	assert_int(_arena.alive_enemies().size()).is_equal(3)
	assert_int(lancers).is_equal(1)


func test_a_defeat_at_the_porters_goes_back_to_their_checkpoint() -> void:
	await _play_to_zone(3)
	_health.apply_damage(_health.get_maximum())
	await _frames(10)
	assert_int(_arena.state).is_equal(ArenaController.EncounterState.DEFEATED)
	_arena.reset_encounter()
	await _frames(3)
	var checkpoint: Vector3 = _level.marker_position(&"Checkpoint3")
	assert_float(_player.global_position.distance_to(checkpoint)).is_less(1.0)
	assert_bool(_arena.is_zone_won(2)).is_true()
	assert_int(_arena.alive_enemies().size()).is_equal(3)
	assert_int(_slice.flow.current().zone).is_equal(3)


func test_the_bundles_lie_at_the_camp_until_picked_up() -> void:
	for marker: StringName in BUNDLES:
		assert_bool(_bundles.is_lying(marker)).override_failure_message(marker).is_true()
	while _slice.flow.current().kind != SliceStep.Kind.INTERACT:
		await _finish_step()
	assert_str(String(_slice.flow.current().marker)).is_equal("Fardo_maiz")
	await _finish_step()
	assert_bool(_bundles.is_lying(&"Fardo_maiz")).is_false()
	assert_bool(_bundles.is_lying(&"Fardo_chuno")).is_true()
	assert_str(String(_slice.flow.current().marker)).is_equal("Fardo_chuno")


func test_the_whole_mission_ends_back_at_the_ayllu() -> void:
	var finished: Array[bool] = [false]
	_slice.slice_finished.connect(func() -> void: finished[0] = true)
	for i: int in 20:
		if _slice.is_finished():
			break
		await _finish_step()
	assert_bool(finished[0]).is_true()
	for zone: int in [1, 2, 3]:
		assert_bool(_arena.is_zone_won(zone)).is_true()
	for marker: StringName in BUNDLES:
		assert_bool(_bundles.is_lying(marker)).is_false()
	var woman: Vector3 = _level.marker_position(&"Mujer")
	assert_float(_player.global_position.distance_to(woman)).is_less(5.0)

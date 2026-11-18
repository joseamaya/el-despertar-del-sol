extends GdUnitTestSuite
## Integration: the slice skeleton in Carmenca (F4 task 2). The director starts one zone
## at a time, moves the respawn to each checkpoint, survives a defeat mid-slice and
## reaches the end. The player is teleported and warriors are killed outright: this
## checks the flow, not the fights (tests/world/test_carmenca_combat.gd does those).

const SCENE: String = "res://scenes/levels/carmenca.tscn"

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _arena: ArenaController
var _slice: SliceDirector
var _player: PlayerController
var _health: HealthComponent


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_arena = _runner.find_child("ArenaController") as ArenaController
	_slice = _runner.find_child("SliceDirector") as SliceDirector
	_player = _runner.find_child("Player") as PlayerController
	_health = _player.get_node("Health") as HealthComponent
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)


func after_test() -> void:
	Engine.time_scale = 1.0


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


## Plays the current step to its end (teleporting, killing, waiting or talking).
func _finish_step() -> void:
	var step: SliceStep = _slice.flow.current()
	match step.kind:
		SliceStep.Kind.WAIT:
			await _frames(int(step.seconds * 60.0) + 5)
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
			# Off the marker by a step: the huaca rock stands on it.
			var at: Vector3 = _level.marker_position(step.marker) + Vector3(0.0, 0.1, 3.0)
			_player.respawn(at, 0.0)
			await _frames(3)
			(_runner.find_child("InteractionPoint") as InteractionPoint).try_interact()
			await _frames(2)
		SliceStep.Kind.RITE:
			var rite := _runner.find_child("HuacaRite") as HuacaRite
			Engine.time_scale = 8.0
			while rite.is_playing():
				await _frames(5)
			Engine.time_scale = 1.0
			await _frames(2)


func test_opening_dialogue_holds_the_first_zone_and_the_player() -> void:
	var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
	var box := _runner.find_child("DialogueBox") as DialogueBox
	assert_bool(talk.is_playing()).is_true()
	assert_bool(box.is_showing()).is_true()
	assert_str(box.shown_text()).is_equal(tr(&"DLG_OPENING_1"))
	# Nobody comes while Vicaquirao speaks, and Cusi cannot fight.
	await _frames(300)
	assert_int(_arena.alive_enemies().size()).is_equal(0)
	assert_bool(_player.get_node("Combat").is_physics_processing()).is_false()
	await _finish_step()
	assert_bool(box.is_showing()).is_false()
	assert_bool(_player.get_node("Combat").is_physics_processing()).is_true()
	assert_int(_arena.alive_enemies().size()).is_equal(_level.layout.encounter_enemies[0])


func test_opening_leads_to_the_first_zone_only() -> void:
	assert_int(_slice.flow.index()).is_equal(0)
	assert_int(_arena.alive_enemies().size()).is_equal(0)
	await _finish_step()
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.ENCOUNTER)
	assert_int(_arena.active_zone).is_equal(1)
	assert_int(_arena.alive_enemies().size()).is_equal(_level.layout.encounter_enemies[0])
	assert_object(_arena.player_spawn).is_same(_level.marker_node(&"Checkpoint1"))


func test_whole_slice_reaches_the_end() -> void:
	var acts: Array[int] = []
	var finished: Array[bool] = [false]
	_slice.act_changed.connect(func(act: SliceStep.Act) -> void: acts.append(act))
	_slice.slice_finished.connect(func() -> void: finished[0] = true)
	for i: int in 20:
		if _slice.is_finished():
			break
		await _finish_step()
	assert_bool(finished[0]).is_true()
	# The opening act was announced before the signal could be connected.
	assert_array(acts).is_equal([1, 2, 3, 4])
	for zone: int in [1, 2, 3]:
		assert_bool(_arena.is_zone_won(zone)).is_true()
	assert_int(_arena.alive_enemies().size()).is_equal(0)


func test_defeat_in_the_second_skirmish_respawns_at_its_checkpoint() -> void:
	while not (
		_slice.flow.current().kind == SliceStep.Kind.ENCOUNTER and _slice.flow.current().zone == 2
	):
		await _finish_step()
	assert_int(_arena.alive_enemies().size()).is_equal(_level.layout.encounter_enemies[1])
	_health.apply_damage(_health.get_maximum())
	await _frames(10)
	assert_int(_arena.state).is_equal(ArenaController.EncounterState.DEFEATED)
	_arena.reset_encounter()
	await _frames(3)
	var checkpoint: Vector3 = _level.marker_position(&"Checkpoint3")
	assert_float(_player.global_position.distance_to(checkpoint)).is_less(1.0)
	assert_bool(_health.is_dead()).is_false()
	# Zone 1 stays cleared; zone 2 is back in full; the slice did not move.
	assert_bool(_arena.is_zone_won(1)).is_true()
	assert_int(_arena.alive_enemies().size()).is_equal(_level.layout.encounter_enemies[1])
	assert_int(_slice.flow.current().zone).is_equal(2)

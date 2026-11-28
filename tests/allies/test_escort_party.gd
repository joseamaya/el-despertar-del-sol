extends GdUnitTestSuite
## Integration: the ESCORT step and EscortParty (F10 task 5) in a flat test level
## (`fixtures/escort_level.tscn`): two prisoners sit tied; freed, they follow Cusi; the
## escort is done when everyone is at the marker; they crouch in a fight; a Chanca goes for
## one only while Cusi is far; if one falls, the fight is lost and the retry brings them
## back beside Cusi at the checkpoint, whole.

const SCENE: String = "res://tests/allies/fixtures/escort_level.tscn"

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _arena: ArenaController
var _slice: SliceDirector
var _player: PlayerController
var _party: EscortParty
var _point: InteractionPoint


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_arena = _runner.find_child("ArenaController") as ArenaController
	_slice = _runner.find_child("SliceDirector") as SliceDirector
	_player = _runner.find_child("Player") as PlayerController
	_party = _runner.find_child("EscortParty") as EscortParty
	_point = _runner.find_child("InteractionPoint") as InteractionPoint
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)


func after_test() -> void:
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _go_to(at: Vector3) -> void:
	_player.respawn(at + Vector3.UP * 0.1, 0.0)
	await _frames(3)


func _free_both() -> void:
	for marker: StringName in [&"Preso_1", &"Preso_2"]:
		await _go_to(_level.marker_position(marker) + Vector3(0, 0, 1.0))
		assert_bool(_point.try_interact()).override_failure_message(marker).is_true()
		await _frames(2)


## Moves Cusi to `marker` and lets the party catch up (sped up).
func _lead_to(marker: StringName) -> void:
	await _go_to(_level.marker_position(marker))
	Engine.time_scale = 4.0
	var step: SliceStep = _slice.flow.current()
	for i: int in 900:
		await _frames(1)
		if _slice.flow.current() != step:
			break
	Engine.time_scale = 1.0


func _kill_zone() -> void:
	for enemy: EnemyController in _arena.alive_enemies():
		enemy.health.apply_damage(enemy.health.get_maximum())
	await _frames(3)


func test_they_sit_tied_at_their_markers() -> void:
	assert_int(_party.members().size()).is_equal(2)
	for p: Prisoner in _party.members():
		assert_bool(p.tied).is_true()
		assert_str(String(p.current_clip())).is_equal(String(_party.tuning.tied_clip))
	var first: Prisoner = _party.member_at(&"Preso_1")
	var at: Vector3 = _level.marker_position(&"Preso_1")
	(
		assert_float(
			Vector2(first.global_position.x - at.x, first.global_position.z - at.z).length()
		)
		. is_less(0.5)
	)


func test_every_clip_exists() -> void:
	var anim := (
		_party.members()[0].model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	)
	var t: EscortTuning = _party.tuning
	for clip: StringName in [t.tied_clip, t.idle_clip, t.walk_clip, t.jog_clip, t.crouch_clip]:
		assert_bool(anim.has_animation(clip)).override_failure_message(clip).is_true()


func test_freeing_unties_and_the_escort_waits_for_everyone() -> void:
	var freed: Array[StringName] = []
	_party.freed.connect(func(marker: StringName) -> void: freed.append(marker))
	await _free_both()
	assert_array(freed).contains_exactly([&"Preso_1", &"Preso_2"])
	assert_int(_party.free_members().size()).is_equal(2)
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.ESCORT)
	# Cusi alone at the marker is not enough.
	await _go_to(_level.marker_position(&"Medio"))
	await _frames(2)
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.ESCORT)
	await _lead_to(&"Medio")
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.ENCOUNTER)
	for p: Prisoner in _party.members():
		var to: Vector3 = p.global_position - _level.marker_position(&"Medio")
		assert_float(Vector2(to.x, to.z).length()).is_less_equal(6.0)


func test_they_crouch_while_a_fight_is_on() -> void:
	await _free_both()
	await _lead_to(&"Medio")
	for enemy: EnemyController in _arena.alive_enemies():
		enemy.perception.alert_to(_player.global_position)
	await _frames(5)
	assert_bool(_arena.is_in_combat()).is_true()
	for p: Prisoner in _party.members():
		assert_bool(p.crouched).is_true()
		assert_str(String(p.current_clip())).is_equal(String(_party.tuning.crouch_clip))


func test_a_chanca_goes_for_a_prisoner_only_while_cusi_is_far() -> void:
	await _free_both()
	await _lead_to(&"Medio")
	var p: Prisoner = _party.members()[0]
	var enemy: EnemyController = _arena.alive_enemies()[0]
	enemy.global_position = p.global_position + Vector3(2, 0.2, 0)
	# Cusi far away: the Chanca goes for the prisoner.
	await _go_to(_level.marker_position(&"Fin"))
	await _frames(3)
	assert_object(enemy.perception.target).is_same(p)
	# Cusi back beside them: the Chanca turns on him again.
	await _go_to(p.global_position + Vector3(0, 0, 1.5))
	await _frames(3)
	assert_object(enemy.perception.target).is_same(_player)


func test_if_one_falls_the_fight_is_lost_and_they_come_back_at_the_checkpoint() -> void:
	var fell: Array[bool] = [false]
	_party.member_fell.connect(func() -> void: fell[0] = true)
	await _free_both()
	await _lead_to(&"Medio")
	var p: Prisoner = _party.members()[1]
	p.health.apply_damage(p.health.get_maximum())
	await _frames(3)
	assert_bool(fell[0]).is_true()
	assert_int(_arena.state).is_equal(ArenaController.EncounterState.DEFEATED)
	_arena.reset_encounter()
	await _frames(3)
	var checkpoint: Vector3 = _level.marker_position(&"Checkpoint1")
	assert_float(_player.global_position.distance_to(checkpoint)).is_less(1.0)
	for member: Prisoner in _party.members():
		assert_bool(member.health.is_dead()).is_false()
		assert_bool(member.tied).is_false()
		assert_float(member.global_position.distance_to(checkpoint)).is_less(6.0)
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.ENCOUNTER)


func test_the_whole_escort_reaches_the_end() -> void:
	await _free_both()
	await _lead_to(&"Medio")
	await _kill_zone()
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.ESCORT)
	await _lead_to(&"Fin")
	assert_bool(_slice.is_finished()).is_true()

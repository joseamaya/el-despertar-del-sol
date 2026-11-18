extends GdUnitTestSuite
## Integration: the slice skeleton in Carmenca (F4 task 2). The director starts one zone
## at a time, moves the respawn to each checkpoint, survives a defeat mid-slice and
## reaches the end, whichever answer the player gives the family (F4 task 6). The player
## is teleported and warriors are killed outright: this
## checks the flow, not the fights (tests/world/test_carmenca_combat.gd does those).

const SCENE: String = "res://scenes/levels/carmenca.tscn"

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _arena: ArenaController
var _slice: SliceDirector
var _player: PlayerController
var _health: HealthComponent
## The option CHOICE steps pick.
var _pick: int = 0


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
		SliceStep.Kind.CHOICE:
			var box := _runner.find_child("ChoiceBox") as ChoiceBox
			box.select(_pick)
			box.confirm()
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


func _play_to_end() -> void:
	for i: int in 30:
		if _slice.is_finished():
			break
		await _finish_step()


func test_whole_slice_reaches_the_end() -> void:
	var acts: Array[int] = []
	var finished: Array[bool] = [false]
	_slice.act_changed.connect(func(act: SliceStep.Act) -> void: acts.append(act))
	_slice.slice_finished.connect(func() -> void: finished[0] = true)
	await _play_to_end()
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


func _play_to_choice() -> void:
	while _slice.flow.current().kind != SliceStep.Kind.CHOICE:
		await _finish_step()


func test_family_asks_then_the_choice_holds_the_player() -> void:
	var box := _runner.find_child("ChoiceBox") as ChoiceBox
	await _play_to_choice()
	assert_bool(box.is_asking()).is_true()
	assert_str(box.option_text(0)).contains(tr(&"CHOICE_FAMILY_ACCEPT"))
	assert_bool(_player.get_node("Combat").is_physics_processing()).is_false()
	box.select(5)
	assert_int(box.selected()).is_equal(1)
	box.select(-1)
	assert_int(box.selected()).is_equal(0)


func test_helping_the_family_frees_the_llamas() -> void:
	var pen := _runner.find_child("LlamaPen") as LlamaPen
	var notices: Array[StringName] = []
	_slice.notice_shown.connect(func(key: StringName) -> void: notices.append(key))
	_pick = 0
	await _play_to_choice()
	await _finish_step()
	assert_bool(_slice.has_flag(&"help_family")).is_true()
	var box := _runner.find_child("DialogueBox") as DialogueBox
	assert_str(box.shown_text()).is_equal(tr(&"DLG_FAMILY_YES"))
	while _slice.flow.current().marker != &"Llamas":
		await _finish_step()
	var home: Vector3 = pen.llamas()[0].global_position
	await _finish_step()
	assert_bool(pen.is_free()).is_true()
	assert_bool(_slice.has_flag(&"llamas_freed")).is_true()
	assert_array(notices).contains([&"NOTICE_OFFERING", &"NOTICE_SUPPORT"])
	assert_int(_slice.flow.current().zone).is_equal(3)
	await _frames(int(pen.tuning.trot_time * 60.0) + 40)
	var gone: float = pen.llamas()[0].global_position.distance_to(home)
	assert_float(gone).is_greater(pen.tuning.trot_distance * 0.8)
	await _play_to_end()
	assert_bool(_slice.is_finished()).is_true()


func test_passing_by_leaves_the_llamas_tied() -> void:
	var pen := _runner.find_child("LlamaPen") as LlamaPen
	_pick = 1
	await _play_to_choice()
	await _finish_step()
	assert_bool(_slice.has_flag(&"help_family")).is_false()
	var box := _runner.find_child("DialogueBox") as DialogueBox
	assert_str(box.shown_text()).is_equal(tr(&"DLG_FAMILY_NO"))
	await _play_to_end()
	assert_bool(_slice.is_finished()).is_true()
	assert_bool(pen.is_free()).is_false()
	assert_bool(_slice.has_flag(&"llamas_freed")).is_false()


func test_passing_the_huaca_by_does_not_stall_the_slice() -> void:
	var stamina := _player.get_node(^"Stamina") as StaminaComponent
	var codex := _runner.find_child("Codex") as Codex
	var point := _runner.find_child("InteractionPoint") as InteractionPoint
	assert_object(_level.sector.get_node_or_null(^"HuacaSmoke")).is_not_null()
	while _slice.flow.current().kind != SliceStep.Kind.INTERACT:
		await _finish_step()
	assert_bool(point.is_active()).is_true()
	var notices: Array[StringName] = []
	_slice.notice_shown.connect(func(key: StringName) -> void: notices.append(key))
	# Straight on to the family, without the offering.
	await _go_to(&"Family")
	await _frames(3)
	assert_bool(point.is_active()).is_false()
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.DIALOGUE)
	var box := _runner.find_child("DialogueBox") as DialogueBox
	assert_str(box.shown_text()).is_equal(tr(&"DLG_FAMILY_1"))
	assert_float(stamina.get_maximum()).is_equal(100.0)
	assert_array(codex.unlocked_entries()).is_empty()
	assert_array(notices).not_contains([&"NOTICE_OFFERING"])
	await _play_to_end()
	assert_bool(_slice.is_finished()).is_true()


func test_huaca_waits_dimmed_while_the_skirmish_is_on() -> void:
	var point := _runner.find_child("InteractionPoint") as InteractionPoint
	var prompt := _runner.find_child("InteractionPrompt") as InteractionPrompt
	while _slice.flow.current().kind != SliceStep.Kind.ENCOUNTER:
		await _finish_step()
	assert_bool(point.is_locked()).is_true()
	var at: Vector3 = _level.marker_position(&"Huaca") + Vector3(0.0, 0.1, 3.0)
	_player.respawn(at, 0.0)
	await _frames(3)
	assert_bool(prompt.is_showing()).is_true()
	assert_bool(prompt.is_dimmed()).is_true()
	assert_str(prompt.shown_text()).is_equal(tr(&"PROMPT_ENEMIES_NEAR"))
	assert_bool(point.try_interact()).is_false()
	await _kill_zone()
	await _frames(2)
	assert_bool(point.is_active()).is_true()
	assert_bool(prompt.is_dimmed()).is_false()
	assert_str(prompt.shown_text()).is_equal(tr(&"PROMPT_OFFERING"))


## The HUD reads on _process: on a slow machine several physics frames can pass first.
func _drawn_frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame


func test_objective_counts_the_fight_then_points_onwards() -> void:
	var hud := _runner.find_child("Hud") as Hud
	await _finish_step()
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.ENCOUNTER)
	await _drawn_frames(3)
	assert_bool(hud.is_showing_objective()).is_true()
	var size: int = _level.layout.encounter_enemies[0]
	assert_str(hud.objective_text()).is_equal(tr(&"OBJ_TERRACES").format({"count": size}))
	var enemies: Array[EnemyController] = _arena.alive_enemies()
	enemies[0].health.apply_damage(enemies[0].health.get_maximum())
	await _drawn_frames(3)
	assert_str(hud.objective_text()).is_equal(tr(&"OBJ_TERRACES").format({"count": size - 1}))
	await _kill_zone()
	await _drawn_frames(3)
	assert_str(hud.objective_text()).is_equal(tr(&"OBJ_HUACA"))


func test_the_ending_looks_at_cusco_then_ends() -> void:
	var focus := _runner.find_child("ViewFocus") as ViewFocus
	var rig := _runner.find_child("CameraRig") as CameraController
	var box := _runner.find_child("DialogueBox") as DialogueBox
	var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
	var finished: Array[bool] = [false]
	_slice.slice_finished.connect(func() -> void: finished[0] = true)
	while _slice.flow.current().marker != &"Ending":
		await _finish_step()
	assert_bool(focus.is_focused()).is_false()
	await _finish_step()
	assert_bool(focus.is_focused()).is_true()
	assert_str(box.shown_text()).is_equal(tr(&"DLG_ENDING_1"))
	await _frames(int(focus.turn_time * 60.0) + 10)
	var to: Vector3 = _level.marker_position(&"CuscoView") - _player.global_position
	var yaw: float = atan2(-to.x, -to.z)
	assert_float(absf(wrapf(rig.yaw - yaw, -PI, PI))).is_less(0.05)
	assert_bool(_player.get_node(^"Combat").is_physics_processing()).is_false()
	talk.advance()
	assert_str(box.shown_text()).is_equal(tr(&"DLG_ENDING_2"))
	talk.advance()
	assert_str(box.shown_text()).is_equal(tr(&"DLG_ENDING_3"))
	talk.advance()
	await _frames(2)
	# The quiet look at the valley: still held, not over yet.
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.WAIT)
	assert_bool(focus.is_focused()).is_true()
	assert_bool(_player.get_node(^"Combat").is_physics_processing()).is_false()
	assert_bool(finished[0]).is_false()
	await _frames(int(_slice.flow.current().seconds * 60.0) + 10)
	assert_bool(finished[0]).is_true()
	assert_bool(focus.is_focused()).is_false()

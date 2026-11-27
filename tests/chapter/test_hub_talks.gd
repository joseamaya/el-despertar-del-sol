extends GdUnitTestSuite
## Taking missions by talking in the hub (F9 task 6): each curaca offers his mission and
## asks; accepting asks to play it, "later" does not. Done missions get thanks; Vicaquirao
## waits until 2 of 3 are done. The objective counts the curacas and leads to the nearest
## one, then to Vicaquirao. Apo Mayta speaks on the first visit only.

const SCENE: String = "res://scenes/levels/centro.tscn"
const CHAPTER: String = "res://resources/chapters/capitulo_1.tres"

var _runner: GdUnitSceneRunner
var _talks: HubTalks
var _level: SectorLevel
var _player: PlayerController
var _dialogue: DialoguePlayer
var _choice: ChoiceBox
var _progress: ChapterProgress
var _chosen: Array[StringName] = []


func before_test() -> void:
	_chosen.clear()
	_runner = scene_runner(SCENE)
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	_talks = _runner.find_child("HubTalks") as HubTalks
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_player = _runner.find_child("Player") as PlayerController
	_dialogue = _runner.find_child("DialoguePlayer") as DialoguePlayer
	_choice = _runner.find_child("ChoiceBox") as ChoiceBox
	_progress = ChapterProgress.new(load(CHAPTER) as ChapterData)
	_progress.complete(&"prologo")
	_progress.complete(&"carmenca")
	_talks.progress = _progress
	_talks.mission_chosen.connect(func(id: StringName) -> void: _chosen.append(id))
	await _runner.simulate_frames(5)


func after_test() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## Talks to `marker`, reads every line and answers `answer` if asked. Returns the mission
## accepted.
func _talk(marker: StringName, answer: int = HubTalks.ACCEPT) -> StringName:
	var accepted: Array[StringName] = [&""]
	var done: Array[bool] = [false]
	var run := func() -> void:
		accepted[0] = await _talks.talk_to(marker)
		done[0] = true
	run.call()
	for i: int in 60:
		if done[0]:
			break
		if _dialogue.is_playing():
			_dialogue.advance()
		elif _choice.is_asking():
			_choice.select(answer)
			_choice.confirm()
		await get_tree().process_frame
	assert_bool(done[0]).override_failure_message("the talk did not end").is_true()
	return accepted[0]


func _finish(mission: StringName) -> void:
	_progress.complete(mission)


func test_the_curacas_offer_their_missions_and_there_are_no_doors() -> void:
	assert_array(_talks.open_missions()).contains_exactly([&"provisiones", &"presos", &"disputa"])
	for key: StringName in _level.layout.points:
		(
			assert_bool(String(key).begins_with("Door_"))
			. override_failure_message(String(key))
			. is_false()
		)


func test_near_a_curaca_the_prompt_names_him() -> void:
	_player.global_position = _level.marker_position(&"Curaca_valle") + Vector3(1.5, 0.1, 0)
	await _runner.simulate_frames(3)
	assert_object(_talks.nearest_talk()).is_not_null()
	var prompt := _runner.find_child("InteractionPrompt") as InteractionPrompt
	assert_str(prompt.shown_text()).contains(tr(&"NAME_CURACA_VALLEY"))


func test_accepting_asks_to_play_the_mission() -> void:
	assert_str(String(await _talk(&"Curaca_valle"))).is_equal("provisiones")
	assert_array(_chosen).contains_exactly([&"provisiones"])
	assert_bool(_player.is_held()).is_false()


func test_later_takes_nothing() -> void:
	assert_str(String(await _talk(&"Curaca_camino", 1))).is_equal("")
	assert_array(_chosen).is_empty()
	assert_array(_talks.open_missions()).contains(&"disputa")


func test_a_done_mission_gets_thanks_not_an_offer() -> void:
	_finish(&"presos")
	assert_object(_talks.talk_at(&"Curaca_quilescachis").thanks).is_not_null()
	assert_str(String(await _talk(&"Curaca_quilescachis"))).is_equal("")
	assert_array(_chosen).is_empty()


func test_vicaquirao_waits_for_two_curacas() -> void:
	assert_str(String(await _talk(&"Mentor"))).is_equal("")
	assert_array(_chosen).is_empty()
	_finish(&"provisiones")
	_finish(&"disputa")
	assert_str(String(await _talk(&"Mentor"))).is_equal("combate_visible")


func test_the_objective_counts_the_curacas_then_sends_to_vicaquirao() -> void:
	var curacas: String = tr(&"HUB_OBJECTIVE_CURACAS")
	assert_str(_talks.objective_text()).is_equal(curacas.format({"count": 0, "total": 3}))
	# It leads to the nearest curaca still to see.
	_player.global_position = _level.marker_position(&"Curaca_quilescachis") + Vector3.UP * 0.1
	assert_str(String(_talks.objective_talk().marker)).is_equal("Curaca_quilescachis")
	_finish(&"presos")
	assert_str(_talks.objective_text()).is_equal(curacas.format({"count": 1, "total": 3}))
	assert_str(String(_talks.objective_talk().marker)).is_not_equal("Curaca_quilescachis")
	_finish(&"provisiones")
	assert_str(_talks.objective_text()).is_equal(tr(&"HUB_OBJECTIVE_VICAQUIRAO"))
	var mentor: Vector3 = _level.marker_position(&"Mentor")
	assert_vector(_talks.objective_position() as Vector3).is_equal(mentor)


func test_the_marker_leads_to_the_objective() -> void:
	var marker := _runner.find_child("ObjectiveMarker") as ObjectiveMarker
	_player.global_position = _level.marker_position(&"Curaca_camino") + Vector3(4, 0.1, 0)
	assert_vector(marker.target_position() as Vector3).is_equal(
		_level.marker_position(&"Curaca_camino")
	)


func test_apo_mayta_speaks_on_the_first_visit_only() -> void:
	_talks.arrival_delay = 0.0
	var started: Array[int] = [0]
	_dialogue.line_shown.connect(func(i: int) -> void: started[0] += 1 if i == 0 else 0)
	_talks.start()
	for i: int in 30:
		if _dialogue.is_playing():
			_dialogue.advance()
		await get_tree().process_frame
	assert_int(started[0]).is_equal(1)
	assert_bool(_progress.has_flag(HubTalks.ARRIVAL_FLAG)).is_true()
	_talks.start()
	await _runner.simulate_frames(5)
	assert_bool(_dialogue.is_playing()).is_false()


func test_the_curaca_turns_to_cusi() -> void:
	var npc := _runner.scene().get_node(^"CuracaValle") as SectorNpc
	_player.global_position = npc.global_position + Vector3(2, 0.1, 0)
	await _talk(&"Curaca_valle", 1)
	var front := Vector3(sin(npc.global_rotation.y), 0, cos(npc.global_rotation.y))
	assert_float(front.dot(Vector3.RIGHT)).is_greater(0.95)


## F8 task 11: the hub has no huaca, no llamas and no comunero on the path.
func test_no_huaca_llamas_or_comunero_in_the_hub() -> void:
	assert_object(_level.sector.get_node_or_null(^"HuacaMesh")).is_null()
	assert_array((_runner.find_child("LlamaPen") as LlamaPen).llamas()).is_empty()
	assert_bool((_runner.find_child("Comunero") as Node3D).visible).is_false()


func test_the_hud_shows_the_objective() -> void:
	_talks.arrival_delay = 0.0
	_progress.set_flag(HubTalks.ARRIVAL_FLAG)
	_talks.start()
	await _runner.simulate_frames(3)
	var hud := _runner.find_child("Hud") as Hud
	assert_bool(hud.is_showing_objective()).is_true()
	assert_str(hud.objective_text()).is_equal(_talks.objective_text())

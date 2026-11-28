extends GdUnitTestSuite
## The chapter end to end in rough (F8 tasks 7–8): new game → prologue → Carmenca → hub;
## since F10 task 3 each mission is played in its level and brings Cusi back to the hub,
## next to the curaca, with the Apoyo saved; two open the show of force; a mission can be
## left from the pause menu; the saved game continues in the hub.

const SCENE: String = "res://scenes/game.tscn"
const TEST_PATH: String = "user://test_route_partida.json"

var _save: SaveGame
var _saved_path: String


func before_test() -> void:
	_save = get_node(^"/root/Save") as SaveGame
	_saved_path = _save.path
	_save.path = TEST_PATH
	_save.erase()


func after_test() -> void:
	get_tree().paused = false
	_save.erase()
	_save.path = _saved_path


func _wait_loaded(host: LevelHost) -> void:
	for i: int in 600:
		if not host.is_loading():
			break
		await get_tree().process_frame
	for i: int in 5:
		await get_tree().process_frame


func _finish_level(host: LevelHost) -> void:
	var slice := host.current_level().get_node(^"SliceDirector") as SliceDirector
	slice.slice_finished.emit()
	slice.continue_requested.emit()
	# The shell hears it deferred: let the load start first.
	await get_tree().process_frame
	await get_tree().process_frame
	await _wait_loaded(host)


func _to_hub(shell: GameShell, host: LevelHost) -> void:
	shell.new_game()
	await _wait_loaded(host)
	await _finish_level(host)
	await _finish_level(host)


func test_prologue_carmenca_hub_and_missions() -> void:
	var runner := scene_runner(SCENE)
	var shell := runner.scene() as GameShell
	var host := runner.find_child("LevelHost") as LevelHost
	shell.new_game()
	await _wait_loaded(host)
	assert_str(String(host.current_id())).is_equal("prologo")
	await _finish_level(host)
	assert_bool(shell.progress.is_done(&"prologo")).is_true()
	assert_str(String(host.current_id())).is_equal("carmenca")
	await _finish_level(host)
	assert_str(String(host.current_id())).is_equal("centro")
	var talks := host.current_level().get_node(^"HubTalks") as HubTalks
	assert_array(talks.open_missions()).contains_exactly([&"provisiones", &"presos", &"disputa"])
	# F10 task 3: accepting plays the mission's level (the sketch until it is built).
	talks.accept(&"provisiones")
	await get_tree().process_frame
	await _wait_loaded(host)
	assert_str(String(host.current_id())).is_equal("mision_provisiones")
	assert_str(String(shell.progress.active())).is_equal("provisiones")
	await _finish_level(host)
	assert_str(String(host.current_id())).is_equal("centro")
	assert_bool(shell.progress.is_done(&"provisiones")).is_true()
	assert_int(shell.support.level(&"ayllu_valle")).is_equal(SupportLedger.Level.SYMPATHIZER)
	# Back next to the curaca who gave it, and the Apoyo saved.
	var level := host.current_level().get_node(^"SectorLevel") as SectorLevel
	var player := host.current_level().get_node(^"Player") as Node3D
	await get_tree().process_frame
	var back: Vector3 = level.marker_position(&"Vuelta_valle")
	(
		assert_float(
			Vector2(player.global_position.x - back.x, player.global_position.z - back.z).length()
		)
		. is_less(1.0)
	)
	var data: Dictionary = shell.saves.read()
	assert_int(int((data["support"] as Dictionary)["ayllu_valle"])).is_equal(1)
	# A second mission opens the show of force.
	talks = host.current_level().get_node(^"HubTalks") as HubTalks
	talks.accept(&"disputa")
	await get_tree().process_frame
	await _wait_loaded(host)
	await _finish_level(host)
	talks = host.current_level().get_node(^"HubTalks") as HubTalks
	assert_array(talks.open_missions()).contains(&"combate_visible")
	# The saved game continues in the hub.
	shell.back_to_title()
	assert_bool(shell.continue_game()).is_true()
	await _wait_loaded(host)
	assert_str(String(host.current_id())).is_equal("centro")
	assert_bool(shell.progress.is_done(&"disputa")).is_true()


## F10 task 3: leaving a mission from the pause menu brings Cusi back to the hub with the
## mission undone and open again.
func test_leaving_a_mission_from_the_pause_menu() -> void:
	var runner := scene_runner(SCENE)
	var shell := runner.scene() as GameShell
	var host := runner.find_child("LevelHost") as LevelHost
	await _to_hub(shell, host)
	var talks := host.current_level().get_node(^"HubTalks") as HubTalks
	talks.accept(&"presos")
	await get_tree().process_frame
	await _wait_loaded(host)
	var pause := host.current_level().get_node(^"PauseMenu") as PauseMenu
	var to_hub := pause.find_child("ToHub", true, false) as Button
	assert_bool(to_hub.visible).is_true()
	pause.open()
	to_hub.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	await _wait_loaded(host)
	assert_str(String(host.current_id())).is_equal("centro")
	assert_bool(shell.progress.is_done(&"presos")).is_false()
	assert_str(String(shell.progress.active())).is_equal("")
	assert_int(shell.support.level(&"quilescachis")).is_equal(SupportLedger.Level.NEUTRAL)
	talks = host.current_level().get_node(^"HubTalks") as HubTalks
	assert_array(talks.open_missions()).contains(&"presos")


## F10 task 3: the hub and the prologue have no "back to the hub" in their pause menu.
func test_only_missions_offer_the_way_back() -> void:
	var runner := scene_runner(SCENE)
	var shell := runner.scene() as GameShell
	var host := runner.find_child("LevelHost") as LevelHost
	shell.new_game()
	await _wait_loaded(host)
	var to_hub := host.current_level().find_child("ToHub", true, false) as Button
	assert_bool(to_hub.visible).is_false()
	await _finish_level(host)
	await _finish_level(host)
	to_hub = host.current_level().find_child("ToHub", true, false) as Button
	assert_bool(to_hub.visible).is_false()


## F9 (decision 3 of the backlog): inside the chapter the prologue keeps its opening shots
## and Carmenca starts past them; the slice on its own still has them (other tests).
func test_inside_the_chapter_carmenca_skips_its_opening() -> void:
	var runner := scene_runner(SCENE)
	var shell := runner.scene() as GameShell
	var host := runner.find_child("LevelHost") as LevelHost
	shell.new_game()
	await _wait_loaded(host)
	var prologue := host.current_level().get_node(^"SliceDirector") as SliceDirector
	assert_bool(prologue.is_in_intro()).is_true()
	await _finish_level(host)
	assert_str(String(host.current_id())).is_equal("carmenca")
	var carmenca := host.current_level().get_node(^"SliceDirector") as SliceDirector
	assert_bool(carmenca.is_in_intro()).is_false()
	assert_bool(carmenca.flow.has_flag(SliceDirector.SKIP_INTRO)).is_true()

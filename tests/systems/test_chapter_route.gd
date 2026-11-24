extends GdUnitTestSuite
## The chapter end to end in rough (F8 tasks 7–8): new game → prologue → Carmenca → hub;
## two test doors open the show of force and raise the Apoyo; the saved game continues in
## the hub.

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


func test_prologue_carmenca_hub_and_doors() -> void:
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
	var doors := host.current_level().get_node(^"HubDoors") as HubDoors
	assert_array(doors.open_doors()).contains_exactly([&"llamas", &"prisioneros", &"disputa"])
	doors.choose(&"llamas")
	await get_tree().process_frame
	doors.choose(&"disputa")
	await get_tree().process_frame
	assert_bool(shell.progress.is_done(&"llamas")).is_true()
	assert_int(shell.support.level(&"ayllu_a")).is_equal(SupportLedger.Level.SYMPATHIZER)
	assert_array(doors.open_doors()).contains(&"combate_visible")
	# The saved game continues in the hub.
	shell.back_to_title()
	assert_bool(shell.continue_game()).is_true()
	await _wait_loaded(host)
	assert_str(String(host.current_id())).is_equal("centro")
	assert_bool(shell.progress.is_done(&"disputa")).is_true()

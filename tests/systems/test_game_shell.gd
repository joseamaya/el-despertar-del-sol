extends GdUnitTestSuite
## The game shell (F8 tasks 2–3): opens on the title, "New game" loads Carmenca hosted (its
## pause menu offers going back to the title), and going back unloads it.

const SCENE: String = "res://scenes/game.tscn"

var _runner: GdUnitSceneRunner


func before_test() -> void:
	_runner = scene_runner(SCENE)
	await get_tree().process_frame


func after_test() -> void:
	get_tree().paused = false


func test_new_game_loads_carmenca_and_back_to_title() -> void:
	var title := _runner.find_child("TitleMenu") as TitleMenu
	var host := _runner.find_child("LevelHost") as LevelHost
	assert_bool(title.is_showing()).is_true()
	(_runner.scene() as GameShell).new_game()
	assert_bool(title.is_showing()).is_false()
	for i: int in 600:
		if not host.is_loading():
			break
		await get_tree().process_frame
	assert_str(String(host.current_id())).is_equal("carmenca")
	# The prologue has no level yet (F8 task 8): passed as done.
	var shell := _runner.scene() as GameShell
	assert_bool(shell.progress.is_done(&"prologo")).is_true()
	assert_str(String(shell.progress.active())).is_equal("carmenca")
	var pause := host.current_level().get_node(^"PauseMenu") as PauseMenu
	assert_bool(pause.is_hosted()).is_true()
	assert_bool((pause.find_child("ToTitle", true, false) as Button).visible).is_true()
	(host.current_level().get_node(^"CameraRig") as CameraController).capture_mouse = false
	await get_tree().process_frame
	pause.open()
	(pause.find_child("ToTitle", true, false) as Button).pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_object(host.current_level()).is_null()
	assert_bool(title.is_showing()).is_true()
	assert_bool(get_tree().paused).is_false()
	assert_str(String(shell.progress.active())).is_empty()


func test_the_level_flags_reach_the_chapter() -> void:
	var shell := _runner.scene() as GameShell
	shell.new_game()
	var host := _runner.find_child("LevelHost") as LevelHost
	for i: int in 600:
		if not host.is_loading():
			break
		await get_tree().process_frame
	var entry := host.current_level().get_node(^"LevelEntry") as LevelEntry
	entry.level_finished.emit([&"llamas_freed"] as Array[StringName])
	assert_bool(shell.progress.is_done(&"carmenca")).is_true()
	assert_bool(shell.progress.has_flag(&"llamas_freed")).is_true()

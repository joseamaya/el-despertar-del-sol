extends GdUnitTestSuite
## The game shell and the saved game (F8 task 5): a new game saves as soon as Carmenca
## loads, "Continue" shows then, and continuing puts Carmenca back at the saved step and
## checkpoint with the codex entry and the huaca's stamina.

const SCENE: String = "res://scenes/game.tscn"
const SEQUENCE: String = "res://resources/slice/carmenca_slice.tres"
const TEST_PATH: String = "user://test_shell_partida.json"

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


func test_new_game_saves_and_continue_shows() -> void:
	var runner := scene_runner(SCENE)
	var title := runner.find_child("TitleMenu") as TitleMenu
	assert_bool(title.can_continue()).is_false()
	(runner.scene() as GameShell).new_game()
	await _wait_loaded(runner.find_child("LevelHost") as LevelHost)
	assert_bool(_save.has_save()).is_true()
	var data: Dictionary = _save.read()
	assert_str(str(data["level"])).is_equal("carmenca")
	assert_bool(title.can_continue()).is_true()


func test_continue_resumes_at_the_checkpoint() -> void:
	var sequence := load(SEQUENCE) as SliceSequence
	var step: int = -1
	for i: int in sequence.steps.size():
		if sequence.steps[i].checkpoint == &"Checkpoint2":
			step = i
	assert_int(step).is_greater(0)
	(
		_save
		. write(
			{
				"chapter": {"missions": {"prologo": "done", "carmenca": "active"}},
				"level": "carmenca",
				"level_state":
				{
					"step": step,
					"flags": ["skip_intro", "skip_training"],
					"checkpoint": "Checkpoint2",
				},
				"codex": ["huaca"],
				"offerings": ["Huaca"],
				"support": {"ayllu_carmenca": 1},
			}
		)
	)
	var runner := scene_runner(SCENE)
	var shell := runner.scene() as GameShell
	assert_bool((runner.find_child("TitleMenu") as TitleMenu).can_continue()).is_true()
	assert_bool(shell.continue_game()).is_true()
	var host := runner.find_child("LevelHost") as LevelHost
	await _wait_loaded(host)
	var level: Node = host.current_level()
	var slice := level.get_node(^"SliceDirector") as SliceDirector
	assert_int(slice.flow.index()).is_equal(step)
	assert_str(String(slice.flow.checkpoint())).is_equal("Checkpoint2")
	assert_bool((level.get_node(^"Codex") as Codex).is_unlocked(&"huaca")).is_true()
	var stamina := level.get_node(^"Player/Stamina") as StaminaComponent
	assert_float(stamina.bonus_max).is_greater(0.0)
	assert_str(String(shell.progress.active())).is_equal("carmenca")
	# F8 task 6: the Apoyo comes back and shows in the pause menu.
	assert_int(shell.support.level(&"ayllu_carmenca")).is_equal(SupportLedger.Level.SYMPATHIZER)
	var pause := level.get_node(^"PauseMenu") as PauseMenu
	(level.get_node(^"CameraRig") as CameraController).capture_mouse = false
	pause.open()
	var label := pause.find_child("Support", true, false) as Label
	assert_bool(label.visible).is_true()
	assert_str(label.text).contains(tr(&"AYLLU_CARMENCA"))
	pause.close()
	assert_object((level.get_node(^"SupportAllies") as SupportAllies).support).is_same(
		shell.support
	)


func test_continue_without_a_save_does_nothing() -> void:
	var runner := scene_runner(SCENE)
	var shell := runner.scene() as GameShell
	assert_bool(shell.continue_game()).is_false()
	assert_bool((runner.find_child("TitleMenu") as TitleMenu).is_showing()).is_true()


func test_finishing_carmenca_with_the_llamas_wins_its_ayllu() -> void:
	var runner := scene_runner(SCENE)
	var shell := runner.scene() as GameShell
	shell.new_game()
	var host := runner.find_child("LevelHost") as LevelHost
	await _wait_loaded(host)
	host.current_entry().level_finished.emit([&"llamas_freed"] as Array[StringName])
	assert_int(shell.support.level(&"ayllu_carmenca")).is_equal(SupportLedger.Level.SYMPATHIZER)
	var data: Dictionary = _save.read()
	assert_int(int((data["support"] as Dictionary)["ayllu_carmenca"])).is_equal(1)


## F8 task 7: inside the chapter the end screen says the mission is done, keeps the Apoyo
## notice, and going on leaves Carmenca (the hub does not exist yet: back to the title).
func test_the_end_screen_goes_on() -> void:
	var runner := scene_runner(SCENE)
	var shell := runner.scene() as GameShell
	shell.new_game()
	var host := runner.find_child("LevelHost") as LevelHost
	await _wait_loaded(host)
	var level: Node = host.current_level()
	var slice := level.get_node(^"SliceDirector") as SliceDirector
	slice.flow.set_flag(&"llamas_freed")
	slice.slice_finished.emit()
	var hud := level.get_node(^"Hud") as Hud
	assert_str(hud.message_label.text).is_equal(tr(&"MISSION_DONE"))
	assert_str(hud.hint_label.text).contains(tr(&"NOTICE_SUPPORT_SYMPATHIZER"))
	assert_str(hud.hint_label.text).contains(tr(&"MISSION_GO_ON"))
	slice.continue_requested.emit()
	for i: int in 30:
		await get_tree().process_frame
	assert_bool(host.current_id() != &"carmenca" or host.is_loading()).is_true()

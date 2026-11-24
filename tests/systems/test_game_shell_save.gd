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


func test_continue_without_a_save_does_nothing() -> void:
	var runner := scene_runner(SCENE)
	var shell := runner.scene() as GameShell
	assert_bool(shell.continue_game()).is_false()
	assert_bool((runner.find_child("TitleMenu") as TitleMenu).is_showing()).is_true()

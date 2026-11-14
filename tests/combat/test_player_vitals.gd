extends GdUnitTestSuite
## Integration: health, stamina, sprint cost and the provisional HUD in the greybox scene.

const TEST_SCENE: String = "res://scenes/tests/locomotion_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _health: HealthComponent
var _stamina: StaminaComponent
var _hud: Hud
var _keys: DebugHealthKeys


func before_test() -> void:
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_health = _player.get_node("Health") as HealthComponent
	_stamina = _player.get_node("Stamina") as StaminaComponent
	_hud = _runner.find_child("Hud") as Hud
	_keys = _runner.find_child("DebugHealthKeys") as DebugHealthKeys
	_player.global_position = Vector3(0, 0.05, 8)
	_player.velocity = Vector3.ZERO
	await _frames(5)


func after_test() -> void:
	for action: StringName in [&"move_left", &"move_right", &"sprint"]:
		Input.action_release(action)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_wiring() -> void:
	assert_object(_player.stamina).is_same(_stamina)
	assert_object(_hud.health).is_same(_health)
	assert_object(_hud.stamina).is_same(_stamina)
	assert_object(_keys.health).is_same(_health)


func test_sprinting_spends_stamina_at_tuned_rate() -> void:
	Input.action_press(&"move_left")
	Input.action_press(&"sprint")
	await _frames(60)
	var spent: float = _stamina.get_maximum() - _stamina.current
	assert_float(spent).is_equal_approx(_player.tuning.sprint_stamina_per_second, 0.6)
	await get_tree().process_frame
	await get_tree().process_frame  # the HUD refreshes in its own _process
	assert_float(_hud.stamina_bar.value).is_equal_approx(_stamina.current, 0.2)


func test_running_without_sprint_does_not_spend() -> void:
	Input.action_press(&"move_left")
	await _frames(30)
	assert_float(_stamina.current).is_equal(_stamina.get_maximum())


func test_sprint_stops_when_empty_and_needs_a_new_press() -> void:
	_stamina.drain(_stamina.get_maximum() - 1.0)
	Input.action_press(&"move_right")
	Input.action_press(&"sprint")
	await _frames(20)
	assert_bool(_stamina.is_empty()).is_true()
	assert_bool(_player.is_sprinting).is_false()
	await _frames(60)  # regen kicks in, but sprint stays locked while held
	assert_float(_stamina.current).is_greater(0.0)
	assert_bool(_player.is_sprinting).is_false()
	Input.action_release(&"sprint")
	await _frames(2)
	Input.action_press(&"sprint")
	await _frames(2)
	assert_bool(_player.is_sprinting).is_true()


func test_debug_keys_damage_and_restore_and_hud_follows() -> void:
	assert_bool(_keys.handle_key(KEY_K)).is_true()
	assert_float(_health.current).is_equal(90.0)
	await get_tree().process_frame
	await get_tree().process_frame  # the HUD refreshes in its own _process
	assert_float(_hud.health_bar.value).is_equal(90.0)
	_keys.handle_key(KEY_L)
	assert_float(_health.current).is_equal(100.0)
	assert_bool(_keys.handle_key(KEY_J)).is_false()

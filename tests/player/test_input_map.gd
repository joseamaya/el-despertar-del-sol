extends GdUnitTestSuite
## The controls of GDD §6.2 on a gamepad (F4 task 11): every button and stick of the table
## triggers its action, and the menus answer to the d-pad and A/B. Without a physical pad
## at hand (F5 tests one), this keeps the mapping from breaking unnoticed.


func _button(index: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = index
	event.pressed = true
	return event


func _axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	return event


func _assert_action(event: InputEvent, action: StringName) -> void:
	(
		assert_bool(event.is_action(action))
		. override_failure_message("%s should trigger %s" % [event.as_text(), action])
		. is_true()
	)


func test_sticks_move_and_look() -> void:
	_assert_action(_axis(JOY_AXIS_LEFT_Y, -1.0), &"move_forward")
	_assert_action(_axis(JOY_AXIS_LEFT_Y, 1.0), &"move_back")
	_assert_action(_axis(JOY_AXIS_LEFT_X, -1.0), &"move_left")
	_assert_action(_axis(JOY_AXIS_LEFT_X, 1.0), &"move_right")
	_assert_action(_axis(JOY_AXIS_RIGHT_X, -1.0), &"look_left")
	_assert_action(_axis(JOY_AXIS_RIGHT_X, 1.0), &"look_right")
	_assert_action(_axis(JOY_AXIS_RIGHT_Y, -1.0), &"look_up")
	_assert_action(_axis(JOY_AXIS_RIGHT_Y, 1.0), &"look_down")


func test_combat_buttons_follow_the_gdd() -> void:
	_assert_action(_button(JOY_BUTTON_RIGHT_SHOULDER), &"attack_light")
	_assert_action(_axis(JOY_AXIS_TRIGGER_RIGHT, 1.0), &"attack_heavy")
	_assert_action(_button(JOY_BUTTON_LEFT_SHOULDER), &"block")
	_assert_action(_button(JOY_BUTTON_B), &"dodge")
	_assert_action(_button(JOY_BUTTON_LEFT_STICK), &"sprint")
	_assert_action(_button(JOY_BUTTON_RIGHT_STICK), &"lock_on")


func test_slice_buttons() -> void:
	_assert_action(_button(JOY_BUTTON_A), &"interact")
	_assert_action(_button(JOY_BUTTON_BACK), &"codex")
	_assert_action(_button(JOY_BUTTON_START), &"pause")
	_assert_action(_button(JOY_BUTTON_START), &"restart")


func test_menus_answer_to_the_pad() -> void:
	_assert_action(_button(JOY_BUTTON_A), &"ui_accept")
	_assert_action(_button(JOY_BUTTON_B), &"ui_cancel")
	_assert_action(_button(JOY_BUTTON_DPAD_UP), &"ui_up")
	_assert_action(_button(JOY_BUTTON_DPAD_DOWN), &"ui_down")
	_assert_action(_button(JOY_BUTTON_DPAD_LEFT), &"ui_left")
	_assert_action(_button(JOY_BUTTON_DPAD_RIGHT), &"ui_right")


func test_every_gameplay_action_has_a_pad_binding() -> void:
	# The mouse-wheel target switch (on a pad the right stick flicks) and the testers'
	# frame-rate key.
	var mouse_only: Array[StringName] = [&"lock_switch_left", &"lock_switch_right", &"toggle_fps"]
	for action: StringName in InputMap.get_actions():
		if String(action).begins_with("ui_") or action in mouse_only:
			continue
		var has_pad: bool = false
		for event: InputEvent in InputMap.action_get_events(action):
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				has_pad = true
		assert_bool(has_pad).override_failure_message(String(action)).is_true()


## F4 task 11: F3 shows the frame rate for testers.
func test_f3_toggles_the_frame_rate() -> void:
	var key := InputEventKey.new()
	key.physical_keycode = KEY_F3
	key.pressed = true
	_assert_action(key, &"toggle_fps")
	var overlay := auto_free(FpsOverlay.new()) as FpsOverlay
	add_child(overlay)
	assert_bool(overlay.is_showing()).is_false()
	overlay.toggle()
	assert_bool(overlay.is_showing()).is_true()
	assert_str(overlay.shown_text()).contains("FPS")
	overlay.toggle()
	assert_bool(overlay.is_showing()).is_false()

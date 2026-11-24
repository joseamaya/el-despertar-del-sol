extends GdUnitTestSuite
## The title menu (F8 task 2): "Continue" only with a saved game, its buttons emit the
## shell's signals, the settings page opens and comes back, and every text is translated.

var _title: TitleMenu


func before_test() -> void:
	_title = auto_free(TitleMenu.new())
	add_child(_title)


func test_continue_shows_only_with_a_saved_game() -> void:
	assert_bool(_title.can_continue()).is_false()
	_title.set_can_continue(true)
	assert_bool(_title.can_continue()).is_true()


func test_buttons_emit_the_signals() -> void:
	var got: Array[StringName] = []
	_title.new_game_pressed.connect(func() -> void: got.append(&"new"))
	_title.continue_pressed.connect(func() -> void: got.append(&"continue"))
	(_title.find_child("NewGame", true, false) as Button).pressed.emit()
	(_title.find_child("Continue", true, false) as Button).pressed.emit()
	assert_array(got).contains_exactly([&"new", &"continue"])


func test_settings_page_opens_and_comes_back() -> void:
	_title.show_menu()
	_title.show_options()
	assert_bool(_title.is_showing_options()).is_true()
	(_title.find_child("Back", true, false) as Button).pressed.emit()
	assert_bool(_title.is_showing_options()).is_false()
	_title.hide_menu()
	assert_bool(_title.is_showing()).is_false()


func test_texts_are_translated() -> void:
	for label: Label in _title.find_children("*", "Label", true, false):
		assert_bool(label.text.begins_with("TITLE_")).is_false()
	for button: Button in _title.find_children("*", "Button", true, false):
		assert_bool(button.text.contains("_")).is_false()

extends GdUnitTestSuite
## Unit: the codex screen pauses the game while open, says when there is nothing yet,
## and shows an entry with its label; the notice appears when an entry unlocks.

var _codex: Codex
var _screen: CodexScreen
var _notice: CodexNotice


func before_test() -> void:
	var book := CodexBook.new()
	for i: int in 2:
		var entry := CodexEntry.new()
		entry.id = StringName("e%d" % i)
		entry.title = &"CODEX_HUACA_TITLE"
		entry.body = &"CODEX_HUACA_BODY"
		entry.source = &"CODEX_HUACA_SOURCE" if i == 0 else &""
		entry.tag = CodexEntry.Tag.CHRONICLERS if i == 0 else CodexEntry.Tag.LICENCE
		book.entries.append(entry)
	_codex = auto_free(Codex.new()) as Codex
	_codex.book = book
	add_child(_codex)
	_screen = auto_free(CodexScreen.new()) as CodexScreen
	_screen.codex = _codex
	add_child(_screen)
	_notice = auto_free(CodexNotice.new()) as CodexNotice
	_notice.codex = _codex
	add_child(_notice)


func after_test() -> void:
	_screen.close()
	get_tree().paused = false


func test_open_pauses_and_close_resumes() -> void:
	_screen.open()
	assert_bool(_screen.is_open()).is_true()
	assert_bool(get_tree().paused).is_true()
	_screen.close()
	assert_bool(_screen.is_open()).is_false()
	assert_bool(get_tree().paused).is_false()


func test_does_not_open_over_another_pause() -> void:
	get_tree().paused = true
	_screen.open()
	assert_bool(_screen.is_open()).is_false()


func test_empty_until_something_unlocks() -> void:
	_screen.open()
	assert_bool(_screen.shows_empty()).is_true()
	_screen.close()
	_codex.unlock(&"e1")
	_screen.open()
	assert_bool(_screen.shows_empty()).is_false()
	assert_str(_screen.shown_title()).is_equal(tr(&"CODEX_HUACA_TITLE"))
	assert_str(_screen.shown_tag()).is_equal(tr(&"CODEX_TAG_LICENCE"))


func test_select_shows_the_entry_and_its_label() -> void:
	_codex.unlock(&"e0")
	_codex.unlock(&"e1")
	_screen.open()
	assert_str(_screen.shown_tag()).is_equal(tr(&"CODEX_TAG_CHRONICLERS"))
	assert_str(_screen.shown_body()).is_equal(tr(&"CODEX_HUACA_BODY"))
	_screen.select(1)
	assert_str(_screen.shown_tag()).is_equal(tr(&"CODEX_TAG_LICENCE"))


func test_notice_shows_the_new_entry() -> void:
	assert_bool(_notice.is_showing()).is_false()
	_codex.unlock(&"e0")
	assert_bool(_notice.is_showing()).is_true()
	assert_str(_notice.shown_text()).contains(tr(&"CODEX_HUACA_TITLE"))

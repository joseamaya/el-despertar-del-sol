extends GdUnitTestSuite
## Unit: Codex unlocks each entry of its book once, tells when it does, and lists the
## unlocked ones in book order. The game's book has unique ids and translated texts.

const BOOK: String = "res://resources/codex/codex_book.tres"
const CSV: String = "res://localization/ui.csv"

var _codex: Codex


func before_test() -> void:
	_codex = auto_free(Codex.new()) as Codex
	_codex.book = _book([&"a", &"b", &"c"])
	add_child(_codex)


func _book(ids: Array[StringName]) -> CodexBook:
	var book := CodexBook.new()
	for id: StringName in ids:
		var entry := CodexEntry.new()
		entry.id = id
		entry.title = id
		book.entries.append(entry)
	return book


func test_unlocks_once_and_tells() -> void:
	var told: Array[StringName] = []
	_codex.entry_unlocked.connect(func(e: CodexEntry) -> void: told.append(e.id))
	assert_bool(_codex.is_unlocked(&"b")).is_false()
	assert_bool(_codex.unlock(&"b")).is_true()
	assert_bool(_codex.unlock(&"b")).is_false()
	assert_bool(_codex.is_unlocked(&"b")).is_true()
	assert_array(told).is_equal([&"b"])


func test_lists_unlocked_in_book_order() -> void:
	assert_array(_codex.unlocked_entries()).is_empty()
	_codex.unlock(&"c")
	_codex.unlock(&"a")
	var ids: Array[StringName] = []
	for entry: CodexEntry in _codex.unlocked_entries():
		ids.append(entry.id)
	assert_array(ids).is_equal([&"a", &"c"])


func test_game_book_ids_are_unique_and_texts_translated() -> void:
	var keys: Dictionary = {}
	var file := FileAccess.open(CSV, FileAccess.READ)
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() >= 3:
			keys[row[0]] = row[1] != "" and row[2] != ""
	var book := load(BOOK) as CodexBook
	assert_array(book.entries).is_not_empty()
	var seen: Dictionary = {}
	for entry: CodexEntry in book.entries:
		assert_bool(seen.has(entry.id)).override_failure_message(String(entry.id)).is_false()
		seen[entry.id] = true
		assert_object(book.find(entry.id)).is_same(entry)
		for key: StringName in [entry.title, entry.body, entry.tag_key()]:
			assert_bool(keys.get(String(key), false)).override_failure_message(key).is_true()
		for key: StringName in [entry.source, entry.note]:
			if key != &"":
				assert_bool(keys.get(String(key), false)).override_failure_message(key).is_true()
	assert_object(book.find(&"nope")).is_null()


func test_huaca_rite_unlocks_a_book_entry() -> void:
	var tuning := load("res://resources/tuning/huaca_rite.tres") as HuacaRiteTuning
	assert_object((load(BOOK) as CodexBook).find(tuning.codex_entry)).is_not_null()

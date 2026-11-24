extends GdUnitTestSuite
## SaveGame (F8 task 5): writes and reads the game with its version, gives nothing when
## there is no file, moves an unreadable file aside, leaves a newer one alone, and erases.

const TEST_PATH: String = "user://test_partida.json"

var _save: SaveGame


func before_test() -> void:
	_save = auto_free(SaveGame.new())
	_save.path = TEST_PATH
	_clean()


func after_test() -> void:
	_clean()


func _clean() -> void:
	for suffix: String in ["", ".bak", ".tmp"]:
		var file: String = ProjectSettings.globalize_path(TEST_PATH + suffix)
		if FileAccess.file_exists(file):
			DirAccess.remove_absolute(file)


func _write_raw(text: String) -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_round_trip() -> void:
	assert_bool(_save.has_save()).is_false()
	assert_dict(_save.read()).is_empty()
	assert_int(_save.write({"level": "carmenca", "codex": ["huaca"]})).is_equal(OK)
	assert_bool(_save.has_save()).is_true()
	var data: Dictionary = _save.read()
	assert_str(str(data["level"])).is_equal("carmenca")
	assert_array(data["codex"] as Array).contains_exactly(["huaca"])
	assert_int(int(data["version"])).is_equal(SaveGame.VERSION)
	assert_bool(FileAccess.file_exists(TEST_PATH + ".tmp")).is_false()


func test_unreadable_file_is_moved_aside() -> void:
	_write_raw("{ not json")
	assert_dict(_save.read()).is_empty()
	assert_str(String(_save.last_error)).is_equal(String(SaveGame.ERROR_CORRUPT))
	assert_bool(_save.has_save()).is_false()
	assert_bool(FileAccess.file_exists(TEST_PATH + ".bak")).is_true()


func test_newer_version_is_left_alone() -> void:
	_write_raw(JSON.stringify({"version": SaveGame.VERSION + 1}))
	assert_dict(_save.read()).is_empty()
	assert_str(String(_save.last_error)).is_equal(String(SaveGame.ERROR_NEWER))
	assert_bool(_save.has_save()).is_true()


func test_erase() -> void:
	_save.write({})
	_save.erase()
	assert_bool(_save.has_save()).is_false()

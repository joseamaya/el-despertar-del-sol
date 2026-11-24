class_name SaveGame
extends Node
## The saved game (F8 task 5, `docs/fases/F8-diseno-tecnico.md`), autoloaded as `Save`: one
## game in `user://partida.json`, written whole each time (to a temporary file, then
## renamed, so a crash never leaves half a file). It stores dictionaries and knows nothing
## of missions. A file it cannot read is moved aside to `.bak` and reported; one from a
## newer version of the game is left alone.

const VERSION: int = 1
const ERROR_NONE: StringName = &""
const ERROR_CORRUPT: StringName = &"corrupt"
const ERROR_NEWER: StringName = &"newer"

## Where the game is kept. Tests point it elsewhere.
var path: String = "user://partida.json"
## Why the last `read()` gave nothing (ERROR_*).
var last_error: StringName = ERROR_NONE


func has_save() -> bool:
	return FileAccess.file_exists(path)


## Writes `data` (plus the version) as the saved game.
func write(data: Dictionary) -> Error:
	var out: Dictionary = data.duplicate(true)
	out["version"] = VERSION
	out["saved_at"] = int(Time.get_unix_time_from_system())
	var temp: String = path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(out, "\t"))
	file.close()
	return DirAccess.rename_absolute(_abs(temp), _abs(path))


## The saved game, or an empty dictionary if there is none or it cannot be used (see
## `last_error`).
func read() -> Dictionary:
	last_error = ERROR_NONE
	if not has_save():
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary or not (parsed as Dictionary).has("version"):
		last_error = ERROR_CORRUPT
		DirAccess.rename_absolute(_abs(path), _abs(path + ".bak"))
		push_warning("SaveGame: unreadable save moved to %s.bak." % path)
		return {}
	var data := parsed as Dictionary
	if int(data["version"]) > VERSION:
		last_error = ERROR_NEWER
		push_warning("SaveGame: save from a newer version of the game; left alone.")
		return {}
	return data


func erase() -> void:
	if has_save():
		DirAccess.remove_absolute(_abs(path))


func _abs(file_path: String) -> String:
	return ProjectSettings.globalize_path(file_path)

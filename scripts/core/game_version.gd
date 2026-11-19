class_name GameVersion
extends RefCounted
## The build's version (F5 task 5), from `application/config/version` in project.godot:
## shown in the pause menu and in the playthrough summary, so every report says which build
## it comes from. "dev" when it is not set.


static func current() -> String:
	var version: String = str(ProjectSettings.get_setting("application/config/version", ""))
	return version if version != "" else "dev"

class_name GameShell
extends Node
## The game's main scene (F8 tasks 2–5, `docs/fases/F8-diseno-tecnico.md`): opens on the
## title menu, starts a new game in the chapter's first mission or continues the saved
## one, keeps the chapter's progress, and saves when a new game starts, at every
## checkpoint and when a level ends. Comes back to the title when a level asks; the saved
## game stays at the last checkpoint.

@export var host: LevelHost
@export var title: TitleMenu
@export var chapter: ChapterData

## Null on the title menu, before a game starts.
var progress: ChapterProgress
## The saved game service; the `Save` autoload unless a test sets another first.
var saves: SaveGame

var _save_on_load: bool = false


func _ready() -> void:
	assert(host != null and title != null and chapter != null, "GameShell: parts.")
	if saves == null:
		saves = get_node_or_null(^"/root/Save") as SaveGame
	title.new_game_pressed.connect(new_game)
	title.continue_pressed.connect(continue_game)
	host.title_requested.connect(back_to_title)
	host.level_loaded.connect(_on_level_loaded)
	host.checkpoint_reached.connect(_on_checkpoint_reached)
	host.level_finished.connect(_on_level_finished)
	title.set_can_continue(saves != null and saves.has_save())
	title.show_menu()


## Starts a new game: fresh progress, into the first mission that is open. The saved game
## is replaced as soon as the first level loads.
func new_game() -> void:
	progress = ChapterProgress.new(chapter)
	_save_on_load = true
	play_next()


## Continues the saved game: its progress, and its level from the last checkpoint. False
## (and "Continue" hidden) if there is none or it cannot be read.
func continue_game() -> bool:
	var data: Dictionary = saves.read() if saves != null else {}
	if data.is_empty():
		title.set_can_continue(false)
		return false
	progress = ChapterProgress.new(chapter)
	progress.from_dict(data.get("chapter", {}) as Dictionary)
	var level := StringName(str(data.get("level", "")))
	var mission: MissionData = chapter.mission(progress.active())
	_save_on_load = false
	if mission != null and mission.level == level and host.catalog.has_level(level):
		var resume: Dictionary = {
			"state": data.get("level_state", {}),
			"codex": data.get("codex", []),
			"offerings": data.get("offerings", []),
		}
		if host.load_level(level, &"", resume):
			title.hide_menu()
			return true
	return play_next()


## Starts the first available mission whose level exists. While the chapter is being
## built, open missions whose level does not exist yet are passed as done, with a warning,
## so the game reaches the levels that do. False if nothing can be played.
func play_next() -> bool:
	while true:
		var open: Array[StringName] = progress.available()
		if open.is_empty():
			return false
		for mission_id: StringName in open:
			var level: StringName = chapter.mission(mission_id).level
			if host.catalog.has_level(level) and host.load_level(level):
				progress.start(mission_id)
				title.hide_menu()
				return true
		push_warning("GameShell: no level yet for %s; passed as done." % open[0])
		progress.complete(open[0])
	return false


## Leaves the level and shows the title menu; the saved game stays at the last checkpoint.
func back_to_title() -> void:
	host.unload()
	title.set_can_continue(saves != null and saves.has_save())
	title.show_menu()


## Writes the game as it is now.
func save_now() -> void:
	if saves == null or progress == null:
		return
	var entry: LevelEntry = host.current_entry()
	var data: Dictionary = {
		"chapter": progress.to_dict(),
		"level": String(host.current_id()),
		"level_state": entry.snapshot() if entry != null else {},
		"codex": _strings(entry.codex_ids()) if entry != null else [],
		"offerings": _strings(entry.offerings()) if entry != null else [],
	}
	if saves.write(data) == OK:
		title.set_can_continue(true)


func _on_level_loaded(_id: StringName) -> void:
	if _save_on_load:
		_save_on_load = false
		save_now()


func _on_checkpoint_reached(_id: StringName, _marker: StringName) -> void:
	save_now()


func _on_level_finished(level_id: StringName, flags: Array[StringName]) -> void:
	if progress != null:
		progress.finish_level(level_id, flags)
		save_now()


static func _strings(names: Array[StringName]) -> Array:
	return names.map(func(n: StringName) -> String: return String(n))

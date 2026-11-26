class_name GameShell
extends Node
## The game's main scene (F8 tasks 2–5, `docs/fases/F8-diseno-tecnico.md`): opens on the
## title menu, starts a new game in the chapter's first mission or continues the saved
## one, keeps the chapter's progress and Apoyo, and saves when a new game starts, at every
## checkpoint and when a level ends. Comes back to the title when a level asks; the saved
## game stays at the last checkpoint.

@export var host: LevelHost
@export var title: TitleMenu
@export var chapter: ChapterData

## Null on the title menu, before a game starts.
var progress: ChapterProgress
## The chapter's Apoyo per ayllu (F8 task 6); null before a game starts.
var support: SupportLedger
## The saved game service; the `Save` autoload unless a test sets another first.
var saves: SaveGame

var _save_on_load: bool = false
## Codex entries and offerings of the game, as of the last save (F8 tasks 5 and 8).
var _codex: Array = []
var _offerings: Array = []


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
	host.continue_requested.connect(_on_continue_requested)
	host.mission_chosen.connect(_on_mission_chosen)
	title.set_can_continue(saves != null and saves.has_save())
	title.show_menu()


## Starts a new game: fresh progress, into the first mission that is open. The saved game
## is replaced as soon as the first level loads.
func new_game() -> void:
	_begin_game()
	_save_on_load = true
	play_next()


## Continues the saved game: its progress, and its level from the last checkpoint. False
## (and "Continue" hidden) if there is none or it cannot be read.
func continue_game() -> bool:
	var data: Dictionary = saves.read() if saves != null else {}
	if data.is_empty():
		title.set_can_continue(false)
		return false
	_begin_game()
	progress.from_dict(data.get("chapter", {}) as Dictionary)
	support.from_dict(data.get("support", {}) as Dictionary)
	_codex = data.get("codex", []) as Array
	_offerings = data.get("offerings", []) as Array
	var level := StringName(str(data.get("level", "")))
	var mission: MissionData = chapter.mission(progress.active())
	_save_on_load = false
	var resume: Dictionary = _carry()
	if mission != null and mission.level == level and host.catalog.has_level(level):
		resume["state"] = data.get("level_state", {})
		if host.load_level(level, &"", resume):
			title.hide_menu()
			return true
	if level == chapter.hub_level and _hub_open():
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
			if host.catalog.has_level(level) and host.load_level(level, &"", _carry()):
				progress.start(mission_id)
				title.hide_menu()
				return true
		push_warning("GameShell: no level yet for %s; passed as done." % open[0])
		progress.complete(open[0])
	return false


## After a mission: back to the hub once it is open (after Carmenca), or on to the next
## mission before that. Back to the title when nothing is left to play.
func go_on() -> bool:
	if _hub_open():
		_save_on_load = true
		return host.load_level(chapter.hub_level, &"", _carry())
	if play_next():
		return true
	back_to_title()
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
	if entry != null:
		_codex = _strings(entry.codex_ids())
		_offerings = _strings(entry.offerings())
	var data: Dictionary = {
		"chapter": progress.to_dict(),
		"level": String(host.current_id()),
		"level_state": entry.snapshot() if entry != null else {},
		"codex": _codex,
		"offerings": _offerings,
		"support": support.to_dict(),
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
	if progress == null:
		return
	var done: StringName = progress.finish_level(level_id, flags)
	if done != &"":
		support.apply_mission(chapter.mission(done), flags)
	save_now()


func _on_continue_requested(_id: StringName) -> void:
	go_on()


func _begin_game() -> void:
	progress = ChapterProgress.new(chapter)
	support = SupportLedger.new(chapter.support)
	support.level_raised.connect(_on_support_raised)


## What a level carries from the game into the next: codex, offerings, Apoyo, progress.
func _carry() -> Dictionary:
	var entry: LevelEntry = host.current_entry()
	var out: Dictionary = {
		"support": support, "progress": progress, "codex": _codex, "offerings": _offerings
	}
	if entry != null:
		out["codex"] = _strings(entry.codex_ids())
		out["offerings"] = _strings(entry.offerings())
	return out


## The hub opens once the mission before it is done (Carmenca) and its level exists.
func _hub_open() -> bool:
	var hub: StringName = chapter.hub_level
	if hub == &"" or not host.catalog.has_level(hub):
		return false
	return chapter.hub_after == &"" or progress.is_done(chapter.hub_after)


## A mission accepted in the hub (F9 task 6: by talking): plays the mission's level, or,
## while it is not built, passes it as done (a test mission) and gives its Apoyo.
func _on_mission_chosen(mission_id: StringName) -> void:
	var mission: MissionData = chapter.mission(mission_id)
	if mission == null:
		return
	if host.catalog.has_level(mission.level):
		if host.load_level(mission.level, &"", _carry()):
			progress.start(mission_id)
		return
	if progress.complete(mission_id):
		support.apply_mission(mission, [])
		var entry: LevelEntry = host.current_entry()
		if entry != null:
			entry.announce(test_mission_notice(mission), test_mission_params(mission))
		save_now()


## What the notice of a test mission says (F9 task 6): that it counts as done and which
## Apoyo it gives.
func test_mission_notice(mission: MissionData) -> StringName:
	if mission.support_gain <= 0:
		return &"NOTICE_TEST_MISSION_PLAIN"
	if mission.support_all_won:
		return &"NOTICE_TEST_MISSION_ALL"
	return &"NOTICE_TEST_MISSION" if mission.ayllu != &"" else &"NOTICE_TEST_MISSION_PLAIN"


func test_mission_params(mission: MissionData) -> Dictionary:
	var ayllu: AylluData = chapter.support.ayllu(mission.ayllu) if chapter.support != null else null
	return {
		"mission": tr(mission.title),
		"gain": mission.support_gain,
		"ayllu": tr(ayllu.title) if ayllu != null else "",
	}


func _on_support_raised(_ayllu: StringName, level: SupportLedger.Level) -> void:
	var entry: LevelEntry = host.current_entry()
	if entry == null:
		return
	var tuning: SupportTuning = chapter.support
	entry.announce(
		tuning.ally_notice if level == SupportLedger.Level.ALLY else tuning.sympathizer_notice
	)


static func _strings(names: Array[StringName]) -> Array:
	return names.map(func(n: StringName) -> String: return String(n))

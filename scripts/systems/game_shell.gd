class_name GameShell
extends Node
## The game's main scene (F8 tasks 2–5, `docs/fases/F8-diseno-tecnico.md`): opens on the
## title menu, starts a new game in the chapter's first mission or continues the saved
## one, keeps the chapter's progress and Apoyo, and saves when a new game starts, at every
## checkpoint and when a level ends. Comes back to the title when a level asks; the saved
## game stays at the last checkpoint. From the hub, a mission is played in its level and
## brings Cusi back next to the curaca who gave it, done or abandoned (F10 task 3).

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
## Where Cusi comes back into the hub (a layout marker; empty: the hub's start).
var _hub_entry: StringName = &""
## Apoyo notices raised away from the hub, shown again on arriving there, as [key, params].
var _hub_notices: Array[Array] = []
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
	host.hub_requested.connect(_on_hub_requested)
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
		return host.load_level(chapter.hub_level, _hub_entry, _carry())
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


func _on_level_loaded(id: StringName) -> void:
	if _save_on_load:
		_save_on_load = false
		save_now()
	var entry: LevelEntry = host.current_entry()
	if entry == null or progress == null:
		return
	if id == chapter.hub_level:
		_hub_entry = &""
		for notice: Array in _hub_notices:
			entry.announce(notice[0] as StringName, notice[1] as Dictionary)
		_hub_notices.clear()
	elif progress.active() != &"" and _hub_open():
		entry.offer_hub_return()


func _on_checkpoint_reached(_id: StringName, _marker: StringName) -> void:
	save_now()


func _on_level_finished(level_id: StringName, flags: Array[StringName]) -> void:
	if progress == null:
		return
	var done: StringName = progress.finish_level(level_id, flags)
	if done != &"":
		_hub_entry = chapter.mission(done).hub_return
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


## A mission accepted in the hub (F9 task 6: by talking): plays the mission's level.
## Every mission has one since F10 task 3, if only the sketch level.
func _on_mission_chosen(mission_id: StringName) -> void:
	var mission: MissionData = chapter.mission(mission_id)
	if mission == null:
		return
	if not host.catalog.has_level(mission.level):
		push_warning("GameShell: no level for %s." % mission_id)
		return
	if host.load_level(mission.level, &"", _carry()):
		progress.start(mission_id)


## The player left a mission from the pause menu (F10 task 3): it stays undone and can be
## taken again; Cusi comes back next to whoever gave it.
func _on_hub_requested(_id: StringName) -> void:
	var mission: MissionData = chapter.mission(progress.active()) if progress != null else null
	if mission == null:
		return
	progress.abandon()
	_hub_entry = mission.hub_return
	_hub_notices.clear()
	go_on()


## Says which ayllu moved up (F10 task 3). Raised in a mission, it is said again on
## arriving at the hub, where nothing else is on screen.
func _on_support_raised(ayllu_id: StringName, level: SupportLedger.Level) -> void:
	var tuning: SupportTuning = chapter.support
	var key: StringName = (
		tuning.ally_notice if level == SupportLedger.Level.ALLY else tuning.sympathizer_notice
	)
	var ayllu: AylluData = tuning.ayllu(ayllu_id)
	var params: Dictionary = {"ayllu": tr(ayllu.title) if ayllu != null else String(ayllu_id)}
	var entry: LevelEntry = host.current_entry()
	if entry != null:
		entry.announce(key, params)
	if host.current_id() != chapter.hub_level:
		_hub_notices.append([key, params])


static func _strings(names: Array[StringName]) -> Array:
	return names.map(func(n: StringName) -> String: return String(n))

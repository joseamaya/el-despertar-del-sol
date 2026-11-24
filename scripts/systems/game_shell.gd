class_name GameShell
extends Node
## The game's main scene (F8 tasks 2–4, `docs/fases/F8-diseno-tecnico.md`): opens on the
## title menu, starts a new game in the chapter's first mission, keeps the chapter's
## progress while the game lasts and comes back to the title when a level asks. Saved
## games ("Continue") arrive with SaveGame (F8 task 5).

@export var host: LevelHost
@export var title: TitleMenu
@export var chapter: ChapterData

## Null on the title menu, before a game starts.
var progress: ChapterProgress


func _ready() -> void:
	assert(host != null and title != null and chapter != null, "GameShell: parts.")
	title.new_game_pressed.connect(new_game)
	host.title_requested.connect(back_to_title)
	host.level_finished.connect(_on_level_finished)
	title.show_menu()


## Starts a new game: fresh progress, into the first mission that is open.
func new_game() -> void:
	progress = ChapterProgress.new(chapter)
	play_next()


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


## Leaves the level and shows the title menu.
func back_to_title() -> void:
	if progress != null:
		progress.abandon()
	host.unload()
	title.show_menu()


func _on_level_finished(level_id: StringName, flags: Array[StringName]) -> void:
	if progress != null:
		progress.finish_level(level_id, flags)

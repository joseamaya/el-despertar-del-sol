class_name GameShell
extends Node
## The game's main scene (F8 tasks 2–3, `docs/fases/F8-diseno-tecnico.md`): opens on the
## title menu, starts a new game in the catalog's first level, and comes back to the title
## when a level asks. Saved games ("Continue") arrive with SaveGame (F8 task 5).

@export var host: LevelHost
@export var title: TitleMenu


func _ready() -> void:
	assert(host != null and title != null, "GameShell: parts.")
	title.new_game_pressed.connect(new_game)
	host.title_requested.connect(back_to_title)
	title.show_menu()


## Starts a new game in the first level of the catalog.
func new_game() -> void:
	if host.load_level(host.catalog.first_level):
		title.hide_menu()


## Leaves the level and shows the title menu.
func back_to_title() -> void:
	host.unload()
	title.show_menu()

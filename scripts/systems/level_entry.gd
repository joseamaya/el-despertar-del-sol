class_name LevelEntry
extends Node
## A level's door to the game shell (F8 task 3, `docs/fases/F8-diseno-tecnico.md`). The
## LevelHost finds it among the level's children and calls `host()`: from then on the
## level's pause menu offers going back to the title, and "start again" asks the shell
## instead of reloading the scene. `enter()` puts the player at an entry marker. Without
## a shell (tests, benchmark, the 0.2-slice) the level works as before and this node
## does nothing.

## Restart this level (pause menu or the end screen).
signal restart_requested
## Leave the level for the title menu.
signal title_requested
## The level's sequence is over.
signal level_finished

@export var level: SectorLevel
@export var pause_menu: PauseMenu
@export var slice: SliceDirector

var _hosted: bool = false


## Called by the LevelHost once the level is in the tree.
func host() -> void:
	if _hosted:
		return
	_hosted = true
	if pause_menu != null:
		pause_menu.set_hosted(true)
		pause_menu.restart_requested.connect(restart_requested.emit)
		pause_menu.title_requested.connect(title_requested.emit)
	if slice != null:
		slice.hosted = true
		slice.restart_requested.connect(restart_requested.emit)
		slice.slice_finished.connect(level_finished.emit)


func is_hosted() -> bool:
	return _hosted


## Puts the player at the layout marker `entry`, facing downhill. Empty: the level's own
## start.
func enter(entry: StringName) -> void:
	if entry == &"" or level == null:
		return
	level.place_player_at(entry, Vector3(0.0, 0.0, 1.0))

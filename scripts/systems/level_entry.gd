class_name LevelEntry
extends Node
## A level's door to the game shell (F8 tasks 3–5, `docs/fases/F8-diseno-tecnico.md`). The
## LevelHost finds it among the level's children and calls `host()`: from then on the
## level's pause menu offers going back to the title, "start again" asks the shell instead
## of reloading the scene, and checkpoints and the end are reported so the shell can save.
## `prepare()`, before the level enters the tree, continues a saved game. `enter()` puts the
## player at an entry marker. Without a shell (tests, benchmark, the 0.2-slice) the level
## works as before and this node does nothing.

## Restart this level (pause menu or the end screen).
signal restart_requested
## Leave the level for the title menu.
signal title_requested
## The level's sequence is over, with the flags it set (F8 task 4).
signal level_finished(flags: Array[StringName])
## A checkpoint was reached: a good moment to save (F8 task 5).
signal checkpoint_reached(marker: StringName)

@export var level: SectorLevel
@export var pause_menu: PauseMenu
@export var slice: SliceDirector
## Optional: what the saved game keeps of the level (F8 task 5).
@export var codex: Codex
@export var rite: HuacaRite

var _hosted: bool = false
var _offerings: Array[StringName] = []
var _saved_codex: Array[StringName] = []
var _saved_offerings: Array[StringName] = []


func _ready() -> void:
	# The last child: the codex, the rite and the player are ready by now.
	if codex != null:
		codex.restore(_saved_codex)
	if rite != null:
		rite.restore_offerings(_saved_offerings)
		rite.offering_made.connect(_on_offering_made)
	_offerings.append_array(_saved_offerings)


## Called by the LevelHost before the level enters the tree: continue from `state` (what
## `snapshot()` gave), with the codex entries and offerings the game already has.
func prepare(state: Dictionary, codex_ids: Array[StringName], offerings: Array[StringName]) -> void:
	if slice != null:
		slice.resume = state.duplicate()
	_saved_codex = codex_ids.duplicate()
	_saved_offerings = offerings.duplicate()


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
		slice.slice_finished.connect(_on_slice_finished)
		slice.checkpoint_reached.connect(checkpoint_reached.emit)


func is_hosted() -> bool:
	return _hosted


## Puts the player at the layout marker `entry`, facing downhill. Empty: the level's own
## start.
func enter(entry: StringName) -> void:
	if entry == &"" or level == null:
		return
	level.place_player_at(entry, Vector3(0.0, 0.0, 1.0))


## Where the level is, for the saved game: {step, flags, checkpoint}. Empty before the
## sequence starts.
func snapshot() -> Dictionary:
	if slice == null or slice.flow == null:
		return {}
	return {
		"step": slice.flow.index(),
		"flags": slice.flow.flags().map(func(f: StringName) -> String: return String(f)),
		"checkpoint": String(slice.flow.checkpoint()),
	}


## Codex entries unlocked in the game so far (the saved ones and this level's).
func codex_ids() -> Array[StringName]:
	return codex.unlocked_ids() if codex != null else _saved_codex.duplicate()


## Huaca offerings made in the game so far.
func offerings() -> Array[StringName]:
	return _offerings.duplicate()


func _on_slice_finished() -> void:
	level_finished.emit(slice.flow.flags())


func _on_offering_made(marker: StringName) -> void:
	if not _offerings.has(marker):
		_offerings.append(marker)

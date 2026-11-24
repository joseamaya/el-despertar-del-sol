class_name LevelHost
extends Node
## Loads and unloads the game's levels (F8 task 3, `docs/fases/F8-diseno-tecnico.md`): reads
## the scene in the background while the loading screen shows, swaps it in as its only
## child, puts the player at the entry marker and hosts the level through its LevelEntry
## (the pause menu's "back to title", restarting from the shell). Lives in game.tscn for
## the whole game, so the levels need no autoload to change scenes.

signal level_loaded(id: StringName)
signal level_unloaded
## The level asked to go back to the title menu.
signal title_requested
## The current level's sequence is over.
signal level_finished(id: StringName)

@export var catalog: LevelCatalog
@export var loading: LoadingScreen

## Seconds the last level took from the request to being in the tree.
var last_load_seconds: float = 0.0

var _current: Node
var _current_id: StringName = &""
var _current_entry: StringName = &""
var _pending_path: String = ""
var _pending_id: StringName = &""
var _pending_entry: StringName = &""
var _started_usec: int = 0
var _progress: Array = []


func _ready() -> void:
	assert(catalog != null, "LevelHost needs a catalog.")
	set_process(false)


func _process(_delta: float) -> void:
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(
		_pending_path, _progress
	)
	if loading != null and not _progress.is_empty():
		loading.set_progress(_progress[0] as float)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		_swap_in(ResourceLoader.load_threaded_get(_pending_path) as PackedScene)
	elif status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		set_process(false)
		push_error("LevelHost: could not load %s." % _pending_path)
		_pending_path = ""
		if loading != null:
			loading.hide_loading()


## Starts loading level `id`, to enter at marker `entry` (empty: the level's start).
## Returns false if the id is unknown or a load is already running.
func load_level(id: StringName, entry: StringName = &"") -> bool:
	if not catalog.has_level(id) or is_loading():
		return false
	unload()
	_pending_id = id
	_pending_entry = entry
	_pending_path = catalog.path_of(id)
	_started_usec = Time.get_ticks_usec()
	if loading != null:
		loading.show_loading()
	ResourceLoader.load_threaded_request(_pending_path)
	set_process(true)
	return true


## Loads the current level again from its entry.
func restart() -> bool:
	if _current_id == &"":
		return false
	return load_level(_current_id, _current_entry)


## Removes the current level, if any.
func unload() -> void:
	if _current == null:
		return
	remove_child(_current)
	_current.queue_free()
	_current = null
	_current_id = &""
	get_tree().paused = false
	level_unloaded.emit()


func is_loading() -> bool:
	return _pending_path != ""


func current_level() -> Node:
	return _current


func current_id() -> StringName:
	return _current_id


func _swap_in(scene: PackedScene) -> void:
	_current = scene.instantiate()
	_current_id = _pending_id
	_current_entry = _pending_entry
	_pending_path = ""
	add_child(_current)
	var entry: LevelEntry = _find_entry(_current)
	if entry != null:
		entry.host()
		entry.restart_requested.connect(restart, CONNECT_DEFERRED)
		entry.title_requested.connect(title_requested.emit, CONNECT_DEFERRED)
		entry.level_finished.connect(level_finished.emit.bind(_current_id))
		if _current_entry != &"":
			# After the level has placed the player at its own start (deferred too).
			entry.enter.call_deferred(_current_entry)
	last_load_seconds = (Time.get_ticks_usec() - _started_usec) / 1_000_000.0
	if loading != null:
		loading.hide_loading()
	level_loaded.emit(_current_id)


func _find_entry(level: Node) -> LevelEntry:
	for child: Node in level.get_children():
		if child is LevelEntry:
			return child as LevelEntry
	return null

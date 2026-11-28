extends SceneTree
## Measures the chapter's level loads inside the game shell (F10 task 3, debt 3 of F9):
## plays prologue → Carmenca → hub → a mission → hub by signals and prints, per level, the
## seconds the load took (the loading screen) and the slowest frame in the 90 after it
## (what the player feels once the screen goes). The saved game goes to the file in the
## PROBE_SAVE environment variable, never to the player's `user://partida.json`; without it
## the probe does nothing.
##
##   PROBE_SAVE=/tmp/probe.json godot --path . --resolution 1600x900 \
##       -s res://tools/chapter_load_probe.gd

const FRAMES_AFTER: int = 90

var _shell: GameShell
var _host: LevelHost
var _save: SaveGame
var _frames: int = -1
var _worst: float = 0.0
var _last: int = 0
var _back_in_hub: bool = false
var _done: bool = false
var _results: Array[String] = []


func _initialize() -> void:
	_start.call_deferred()


func _process(_delta: float) -> bool:
	if _host == null:
		return _done
	var now: int = Time.get_ticks_usec()
	var frame: float = (now - _last) / 1000.0
	_last = now
	if _frames >= 0:
		_worst = maxf(_worst, frame)
		_frames += 1
		if _frames >= FRAMES_AFTER:
			_frames = -1
			_results.append(
				(
					"%s: load %.2f s, worst frame after %.0f ms"
					% [_host.current_id(), _host.last_load_seconds, _worst]
				)
			)
			_next()
	return _done


func _start() -> void:
	_save = root.get_node_or_null(^"/root/Save") as SaveGame
	var to: String = OS.get_environment("PROBE_SAVE")
	if _save == null or to == "":
		push_error("chapter_load_probe: set PROBE_SAVE to a scratch file.")
		_done = true
		return
	_save.path = to
	_save.erase()
	var game: Node = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	root.add_child(game)
	_shell = game as GameShell
	_host = game.find_child("LevelHost") as LevelHost
	_host.level_loaded.connect(_on_loaded)
	_last = Time.get_ticks_usec()
	_shell.new_game()


## The swap itself (instancing and building the level) runs in one frame behind the
## loading screen and is in the load time; the frames after start counting from here.
func _on_loaded(_id: StringName) -> void:
	_frames = 0
	_worst = 0.0
	_last = Time.get_ticks_usec()


func _next() -> void:
	if _host.current_id() == &"centro":
		if _back_in_hub:
			for line: String in _results:
				print("CHAPTER_LOAD ", line)
			_save.erase()
			_done = true
			return
		_back_in_hub = true
		(_host.current_level().get_node(^"HubTalks") as HubTalks).accept(&"provisiones")
		return
	var slice := _host.current_level().get_node(^"SliceDirector") as SliceDirector
	slice.slice_finished.emit()
	slice.continue_requested.emit()

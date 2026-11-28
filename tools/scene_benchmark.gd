extends SceneTree
## Measures frame times of any scene while holding input actions (e.g. the player running
## in circles). Renders the 3D at 1920x1080 times --scale3d, vsync off. Prints one line
## prefixed with SCENE_BENCHMARK and writes the same JSON to --out.
## Frame times come from the wall clock: during hitstop Engine.time_scale shrinks `delta`
## and would report impossible frame rates.
##
##   godot --path . -s res://tools/scene_benchmark.gd -- \
##       --scene=res://scenes/tests/locomotion_test.tscn --hold=move_forward,look_right \
##       --seconds=20 --scale3d=0.833 --out=/tmp/bench.json
##
## Combat arena (F2 task 12): --fight keeps the encounter going (ArenaFightDriver) and
## --enemies=N spawns N enemies (3 by default, up to 6).
##
##   godot --path . -s res://tools/scene_benchmark.gd -- \
##       --scene=res://scenes/tests/combat_arena.tscn --fight --enemies=4 --scale3d=0.833
##
## Sector levels (F3 task 10): --walk walks the whole path (SectorWalkDriver) and reports
## per stretch until the end; --fight-zone=N fights at encounter zone N of the sector.
##
##   godot --path . -s res://tools/scene_benchmark.gd -- \
##       --scene=res://scenes/levels/carmenca.tscn --walk --scale3d=0.833
##
## Whole slice (F4 task 12): --playthrough plays it from the opening to the end
## (SlicePlaythroughDriver) and reports per act and the slice's own play time.
##
##   godot --path . -s res://tools/scene_benchmark.gd -- \
##       --scene=res://scenes/levels/carmenca.tscn --playthrough --scale3d=0.833
##
## --slice-flag=NAME sets a slice flag as if the player had earned it (F4 task 6), e.g.
## llamas_freed brings the comuneros to the pass in --fight-zone=3.
##
## Trailer footage (F5): add Godot's --write-movie to any of these and --timeout=SECONDS
## (wall clock) so the slower-than-real-time recording is not taken for a stuck driver.
##
##   godot --path . --resolution 1920x1080 --write-movie build/trailer/full.avi \
##       -s res://tools/scene_benchmark.gd -- --scene=res://scenes/levels/carmenca.tscn \
##       --playthrough --scale3d=1 --timeout=7200

const RENDER_SIZE: Vector2i = Vector2i(1920, 1080)
## A walk takes ~80 s. Past this the walker is stuck (e.g. a broken layout): give up
## with exit code 1 instead of hanging.
const WALK_TIMEOUT: float = 300.0
## A playthrough takes ~8–10 min; past this the bot is stuck.
const PLAYTHROUGH_TIMEOUT: float = 1200.0

var _scene_path: String = "res://scenes/tests/locomotion_test.tscn"
var _hold: PackedStringArray = PackedStringArray()
var _seconds: float = 20.0
var _warmup: float = 3.0
var _scale_3d: float = 1.0
var _out: String = "user://scene_benchmark.json"
var _fight: bool = false
var _enemies: int = 0
var _start_usec: int = 0
var _last_usec: int = 0
var _frames: PackedFloat64Array = PackedFloat64Array()
var _process_ms: PackedFloat64Array = PackedFloat64Array()
var _physics_ms: PackedFloat64Array = PackedFloat64Array()
var _draw_calls: PackedFloat64Array = PackedFloat64Array()
var _primitives: PackedFloat64Array = PackedFloat64Array()
## When each measured frame happened (seconds since start) and in which stretch.
var _times: PackedFloat64Array = PackedFloat64Array()
var _stretch_of: PackedStringArray = PackedStringArray()
## Render pipelines compiled in each measured frame: a compile is a likely stutter.
var _pipelines: PackedFloat64Array = PackedFloat64Array()
var _pipelines_seen: float = 0.0
var _spawned: int = 0
var _walk: bool = false
var _fight_zone: int = 0
var _slice_flag: StringName = &""
var _timeout: float = 0.0
var _walker: SectorWalkDriver
var _playthrough: bool = false
var _player_bot: SlicePlaythroughDriver
var _stuck: String = ""
## Per stretch while walking: name -> {"frames": PackedFloat64Array, "primitives": ...}.
var _stretches: Dictionary = {}


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--scene="):
			_scene_path = arg.trim_prefix("--scene=")
		elif arg.begins_with("--hold="):
			_hold = arg.trim_prefix("--hold=").split(",", false)
		elif arg.begins_with("--seconds="):
			_seconds = arg.trim_prefix("--seconds=").to_float()
		elif arg.begins_with("--warmup="):
			_warmup = arg.trim_prefix("--warmup=").to_float()
		elif arg.begins_with("--scale3d="):
			_scale_3d = clampf(arg.trim_prefix("--scale3d=").to_float(), 0.25, 2.0)
		elif arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		elif arg == "--fight":
			_fight = true
		elif arg.begins_with("--enemies="):
			_enemies = arg.trim_prefix("--enemies=").to_int()
		elif arg == "--playthrough":
			_playthrough = true
		elif arg == "--walk":
			_walk = true
		elif arg.begins_with("--fight-zone="):
			_fight_zone = arg.trim_prefix("--fight-zone=").to_int()
		elif arg.begins_with("--slice-flag="):
			_slice_flag = StringName(arg.trim_prefix("--slice-flag="))
		elif arg.begins_with("--timeout="):
			_timeout = arg.trim_prefix("--timeout=").to_float()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_size = RENDER_SIZE
	root.scaling_3d_scale = _scale_3d
	# The Settings autoload applies the player's 3D scale once it is ready, after this:
	# set the measured one again on the first frame.
	process_frame.connect(func() -> void: root.scaling_3d_scale = _scale_3d, CONNECT_ONE_SHOT)
	var scene: Node = (load(_scene_path) as PackedScene).instantiate()
	_disable_mouse_capture(scene)
	_prepare_arena(scene)
	root.add_child(scene)
	for action: String in _hold:
		Input.action_press(StringName(action))
	_start_usec = Time.get_ticks_usec()
	_last_usec = _start_usec


func _process(_delta: float) -> bool:
	var now: int = Time.get_ticks_usec()
	var frame: float = (now - _last_usec) / 1_000_000.0
	_last_usec = now
	var elapsed: float = (now - _start_usec) / 1_000_000.0
	if elapsed <= _warmup:
		_pipelines_seen = _pipeline_count()
		return false
	_frames.append(frame)
	_process_ms.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	_physics_ms.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
	_draw_calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	_primitives.append(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	_times.append(elapsed)
	_stretch_of.append(_current_stretch())
	var compiled: float = _pipeline_count()
	_pipelines.append(compiled - _pipelines_seen)
	_pipelines_seen = compiled
	if _still_measuring(frame, elapsed - _warmup):
		return false
	_finish()
	return true


## Whether the run goes on. A driver that gets stuck ends it with exit code 1.
func _still_measuring(frame: float, measured: float) -> bool:
	if _player_bot != null:
		_record_stretch(frame)
		var limit: float = _timeout if _timeout > 0.0 else PLAYTHROUGH_TIMEOUT
		if measured > limit:
			_stuck = "no end in %d s" % limit
		if _stuck != "":
			push_error("SCENE_BENCHMARK playthrough stuck: " + _stuck)
			_finish()
			quit(1)
			return true
		return not _player_bot.is_done()
	if _walker != null:
		_record_stretch(frame)
		var walk_limit: float = _timeout if _timeout > 0.0 else WALK_TIMEOUT
		if measured > walk_limit:
			push_error(
				(
					"SCENE_BENCHMARK walk did not finish in %d s (%.0f %% of the path, in %s)"
					% [walk_limit, _walker.progress() * 100.0, _walker.stretch()]
				)
			)
			quit(1)
			return true
		return not _walker.is_done()
	return measured < _seconds


func _finish() -> void:
	var report: Dictionary = {
		"scene": _scene_path,
		"hold": _hold,
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"scale_3d": _scale_3d,
		"frames": _frames.size(),
		"avg_fps": PerfStats.average_fps(_frames),
		"low_1_fps": PerfStats.low_1_percent_fps(_frames),
		"p99_ms": PerfStats.percentile_ms(_frames, 99.0),
		"over_16_7ms": PerfStats.fraction_over_budget(_frames, 1.0 / 60.0),
		"fight": _fight,
		"enemies": _spawned,
		"process_ms_avg": _average(_process_ms),
		"physics_ms_avg": _average(_physics_ms),
		"physics_ms_max": _maximum(_physics_ms),
		"physics_ms_max_at_s": _time_of_max(_physics_ms),
		"draw_calls_avg": _average(_draw_calls),
		"draw_calls_max": _maximum(_draw_calls),
		"primitives_max": _maximum(_primitives),
		"stretches": _stretch_report(),
		"worst_frames": _worst_frames(5),
		"pipelines_compiled": _sum(_pipelines),
	}
	if _player_bot != null:
		var slice: SliceDirector = _player_bot.slice
		report["slice_play_time"] = slice.play_time
		report["slice_finished"] = slice.is_finished()
		report["act_times"] = _player_bot.act_times()
		report["stuck"] = _stuck
	var file: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "  "))
	print("SCENE_BENCHMARK ", JSON.stringify(report))
	for action: String in _hold:
		Input.action_release(StringName(action))


## Optional arena setup: extra enemies and the fight driver. Runs before _ready.
func _prepare_arena(scene: Node) -> void:
	var arena: ArenaController = _find_arena(scene)
	if arena == null:
		return
	_spawned = arena.spawn_points.size()
	if _enemies > 0:
		_spawned = ArenaFightDriver.set_enemy_count(arena, _enemies)
	var level: SectorLevel = scene.find_child("SectorLevel", true, false) as SectorLevel
	if _fight_zone > 0 or _walk:
		# The slice would start its own zones and hold the player in its opening
		# dialogue: the benchmark drives the level instead.
		var slice := scene.find_child("SliceDirector", true, false) as SliceDirector
		if slice != null:
			slice.autostart = false
			if _slice_flag != &"":
				slice.flow = SliceFlow.new(slice.sequence)
				slice.flow.set_flag(_slice_flag)
	if _fight or _fight_zone > 0:
		var driver := ArenaFightDriver.new()
		driver.name = "ArenaFightDriver"
		driver.arena = arena
		driver.level = level
		driver.zone = _fight_zone
		scene.add_child(driver)
	if _playthrough and level != null:
		_player_bot = SlicePlaythroughDriver.new()
		_player_bot.name = "SlicePlaythroughDriver"
		_player_bot.slice = scene.find_child("SliceDirector", true, false) as SliceDirector
		_player_bot.level = level
		_player_bot.arena = arena
		_player_bot.dialogue = scene.find_child("DialoguePlayer", true, false) as DialoguePlayer
		_player_bot.choice = scene.find_child("ChoiceBox", true, false) as ChoiceBox
		_player_bot.interaction = (
			scene.find_child("InteractionPoint", true, false) as InteractionPoint
		)
		_player_bot.drill = scene.find_child("TrainingDrill", true, false) as TrainingDrill
		_player_bot.stuck.connect(func(reason: String) -> void: _stuck = reason)
		scene.add_child(_player_bot)
	if _walk and level != null:
		_walker = SectorWalkDriver.new()
		_walker.name = "SectorWalkDriver"
		_walker.level = level
		_walker.arena = arena
		scene.add_child(_walker)


func _find_arena(node: Node) -> ArenaController:
	if node is ArenaController:
		return node as ArenaController
	for child: Node in node.get_children():
		var found: ArenaController = _find_arena(child)
		if found != null:
			return found
	return null


func _current_stretch() -> String:
	if _player_bot != null:
		return _player_bot.stretch()
	return _walker.stretch() if _walker != null else ""


## The slowest frames: when (seconds since start), where, and how much was physics.
func _worst_frames(count: int) -> Array:
	var order: Array = range(_frames.size())
	order.sort_custom(func(a: int, b: int) -> bool: return _frames[a] > _frames[b])
	var out: Array = []
	for i: int in order.slice(0, count):
		(
			out
			. append(
				{
					"at_s": snappedf(_times[i], 0.01),
					"stretch": _stretch_of[i],
					"frame_ms": snappedf(_frames[i] * 1000.0, 0.1),
					"physics_ms": snappedf(_physics_ms[i], 0.1),
					# The physics monitor reports the step after the frame it slowed down.
					"next_physics_ms":
					snappedf(_physics_ms[mini(i + 1, _physics_ms.size() - 1)], 0.1),
					"process_ms": snappedf(_process_ms[i], 0.1),
					"pipelines": _pipelines[i],
				}
			)
		)
	return out


## When (seconds since start) the largest value was measured.
func _time_of_max(values: PackedFloat64Array) -> float:
	var best: int = 0
	for i: int in values.size():
		if values[i] > values[best]:
			best = i
	return snappedf(_times[best], 0.01) if best < _times.size() else 0.0


## Pipelines compiled so far, of every kind (Godot's rendering monitors).
static func _pipeline_count() -> float:
	return (
		Performance.get_monitor(Performance.PIPELINE_COMPILATIONS_CANVAS)
		+ Performance.get_monitor(Performance.PIPELINE_COMPILATIONS_MESH)
		+ Performance.get_monitor(Performance.PIPELINE_COMPILATIONS_SURFACE)
		+ Performance.get_monitor(Performance.PIPELINE_COMPILATIONS_DRAW)
		+ Performance.get_monitor(Performance.PIPELINE_COMPILATIONS_SPECIALIZATION)
	)


static func _sum(values: PackedFloat64Array) -> float:
	var total: float = 0.0
	for v: float in values:
		total += v
	return total


func _record_stretch(frame: float) -> void:
	var name: String = _current_stretch()
	if not _stretches.has(name):
		_stretches[name] = {"frames": PackedFloat64Array(), "primitives": PackedFloat64Array()}
	# Packed arrays are values: append to a copy and store it back.
	var s: Dictionary = _stretches[name]
	var frames: PackedFloat64Array = s["frames"]
	var prims: PackedFloat64Array = s["primitives"]
	frames.append(frame)
	prims.append(_primitives[_primitives.size() - 1])
	s["frames"] = frames
	s["primitives"] = prims


func _stretch_report() -> Dictionary:
	var out: Dictionary = {}
	for name: String in _stretches.keys():
		var frames: PackedFloat64Array = _stretches[name]["frames"]
		out[name] = {
			"frames": frames.size(),
			"avg_fps": PerfStats.average_fps(frames),
			"low_1_fps": PerfStats.low_1_percent_fps(frames),
			"over_16_7ms": PerfStats.fraction_over_budget(frames, 1.0 / 60.0),
			"primitives_max": _maximum(_stretches[name]["primitives"]),
		}
	return out


static func _average(values: PackedFloat64Array) -> float:
	if values.is_empty():
		return 0.0
	var total: float = 0.0
	for v: float in values:
		total += v
	return total / values.size()


static func _maximum(values: PackedFloat64Array) -> float:
	var top: float = 0.0
	for v: float in values:
		top = maxf(top, v)
	return top


func _disable_mouse_capture(node: Node) -> void:
	var rig: CameraController = node as CameraController
	if rig != null:
		rig.capture_mouse = false
	for child: Node in node.get_children():
		_disable_mouse_capture(child)

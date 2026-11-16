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

const RENDER_SIZE: Vector2i = Vector2i(1920, 1080)

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
var _spawned: int = 0


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
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_size = RENDER_SIZE
	root.scaling_3d_scale = _scale_3d
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
		return false
	_frames.append(frame)
	_process_ms.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	_physics_ms.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
	_draw_calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	_primitives.append(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	if elapsed < _warmup + _seconds:
		return false
	_finish()
	return true


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
		"draw_calls_avg": _average(_draw_calls),
		"draw_calls_max": _maximum(_draw_calls),
		"primitives_max": _maximum(_primitives),
	}
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
	if _fight:
		var driver := ArenaFightDriver.new()
		driver.name = "ArenaFightDriver"
		driver.arena = arena
		scene.add_child(driver)


func _find_arena(node: Node) -> ArenaController:
	if node is ArenaController:
		return node as ArenaController
	for child: Node in node.get_children():
		var found: ArenaController = _find_arena(child)
		if found != null:
			return found
	return null


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

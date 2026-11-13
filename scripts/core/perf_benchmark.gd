class_name PerfBenchmark
extends Node
## Benchmark driver. Inert unless the game is launched with the user argument
## `--benchmark`: then it disables vsync, orbits `camera` around `focus`, records
## frame times, writes a JSON report and quits.
##
##   godot --path . res://scenes/tests/perf_carmenca_proxy.tscn \
##       --rendering-method mobile --resolution 1920x1080 -- --benchmark --out=/tmp/r.json
##
## Extra user args: `--effects` enables Forward+-only effects (volumetric fog, SSAO).
## The 3D is always rendered at `render_size` (scaled to the window), so results do not
## depend on the monitor: the reference screen is 1600x900 but the GDD target is 1080p.

signal finished(report: Dictionary)

@export var camera: Camera3D
@export var environment: WorldEnvironment
@export var focus: Vector3 = Vector3.ZERO
@export_range(5.0, 200.0, 1.0, "suffix:m") var orbit_radius: float = 45.0
@export_range(1.0, 80.0, 0.5, "suffix:m") var orbit_height: float = 14.0
@export_range(1.0, 120.0, 1.0, "suffix:s") var warmup_seconds: float = 3.0
@export_range(1.0, 600.0, 1.0, "suffix:s") var capture_seconds: float = 30.0
@export var render_size: Vector2i = Vector2i(1920, 1080)

var _active: bool = false
var _effects: bool = false
var _out_path: String = "user://benchmark.json"
var _elapsed: float = 0.0
var _frame_times: PackedFloat64Array = PackedFloat64Array()


func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_active = args.has("--benchmark")
	_effects = args.has("--effects")
	for arg: String in args:
		if arg.begins_with("--out="):
			_out_path = arg.trim_prefix("--out=")
	if not _active:
		return
	assert(camera != null, "PerfBenchmark needs a camera.")
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var window: Window = get_tree().root
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	window.content_scale_size = render_size
	camera.current = true
	if _effects and environment != null:
		environment.environment.volumetric_fog_enabled = true
		environment.environment.ssao_enabled = true


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	_place_camera(_elapsed)
	if _elapsed <= warmup_seconds:
		return
	_frame_times.append(delta)
	if _elapsed >= warmup_seconds + capture_seconds:
		_active = false
		_finish()


## True while a benchmark capture is in progress.
func is_running() -> bool:
	return _active


func build_report() -> Dictionary:
	return {
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"render_size": "%dx%d" % [_render_size().x, _render_size().y],
		"window_size": "%dx%d" % [get_tree().root.size.x, get_tree().root.size.y],
		"effects": _effects,
		"frames": _frame_times.size(),
		"avg_fps": PerfStats.average_fps(_frame_times),
		"low_1_fps": PerfStats.low_1_percent_fps(_frame_times),
		"p99_ms": PerfStats.percentile_ms(_frame_times, 99.0),
		"over_16_7ms": PerfStats.fraction_over_budget(_frame_times, 1.0 / 60.0),
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"video_mem_mb": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
	}


func _render_size() -> Vector2i:
	return get_viewport().get_texture().get_size()


func _place_camera(t: float) -> void:
	var angle: float = TAU * t / (warmup_seconds + capture_seconds)
	var offset := Vector3(sin(angle), 0.0, cos(angle)) * orbit_radius
	camera.global_position = focus + offset + Vector3.UP * orbit_height
	camera.look_at(focus, Vector3.UP)


func _finish() -> void:
	var report: Dictionary = build_report()
	var file: FileAccess = FileAccess.open(_out_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "  "))
		file.close()
	print("BENCHMARK ", JSON.stringify(report))
	finished.emit(report)
	get_tree().quit()

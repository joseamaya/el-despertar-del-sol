extends SceneTree
## Measures frame times of any scene while holding input actions (e.g. the player running
## in circles). Renders the 3D at 1920x1080 times --scale3d, vsync off. Prints one line
## prefixed with SCENE_BENCHMARK and writes the same JSON to --out.
##
##   godot --path . -s res://tools/scene_benchmark.gd -- \
##       --scene=res://scenes/tests/locomotion_test.tscn --hold=move_forward,look_right \
##       --seconds=20 --scale3d=0.833 --out=/tmp/bench.json

const RENDER_SIZE: Vector2i = Vector2i(1920, 1080)

var _scene_path: String = "res://scenes/tests/locomotion_test.tscn"
var _hold: PackedStringArray = PackedStringArray()
var _seconds: float = 20.0
var _warmup: float = 3.0
var _scale_3d: float = 1.0
var _out: String = "user://scene_benchmark.json"
var _elapsed: float = 0.0
var _frames: PackedFloat64Array = PackedFloat64Array()


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
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_size = RENDER_SIZE
	root.scaling_3d_scale = _scale_3d
	var scene: Node = (load(_scene_path) as PackedScene).instantiate()
	_disable_mouse_capture(scene)
	root.add_child(scene)
	for action: String in _hold:
		Input.action_press(StringName(action))


func _process(delta: float) -> bool:
	_elapsed += delta
	if _elapsed <= _warmup:
		return false
	_frames.append(delta)
	if _elapsed < _warmup + _seconds:
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
	}
	var file: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "  "))
	print("SCENE_BENCHMARK ", JSON.stringify(report))
	for action: String in _hold:
		Input.action_release(StringName(action))


func _disable_mouse_capture(node: Node) -> void:
	var rig: CameraController = node as CameraController
	if rig != null:
		rig.capture_mouse = false
	for child: Node in node.get_children():
		_disable_mouse_capture(child)

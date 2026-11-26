extends SceneTree
## Saves shots of a sector level from cameras placed in layout coordinates (F9 task 3: the
## hub's blockout, for the developer to judge). Needs a window: the dummy renderer draws
## nothing. Each --shot is name:x,z,height:target_x,target_z (layout frame, -Z uphill).
##
##   godot --path . --resolution 1920x1080 -s res://tools/level_capture.gd -- \
##       --scene=res://scenes/levels/centro.tscn --out=<dir> \
##       --shot=plaza:0,30,6:0,0 --shot=alto:0,70,45:0,0

## Frames to let the level build, bake and settle before the first shot.
const SETTLE_FRAMES: int = 60

var _scene_path: String = "res://scenes/levels/centro.tscn"
var _out: String = "user://capturas"
var _shots: PackedStringArray = PackedStringArray()
var _level: Node


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--scene="):
			_scene_path = arg.trim_prefix("--scene=")
		elif arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		elif arg.begins_with("--shot="):
			_shots.append(arg.trim_prefix("--shot="))
	DirAccess.make_dir_recursive_absolute(_out)
	_level = (load(_scene_path) as PackedScene).instantiate()
	root.add_child(_level)
	_run.call_deferred()


func _run() -> void:
	var sector := _level.find_children("*", "SectorLevel", true, false)[0] as SectorLevel
	var hud: Node = _level.get_node_or_null(^"Hud")
	if hud is CanvasLayer:
		(hud as CanvasLayer).visible = false
	var camera := Camera3D.new()
	camera.far = 2000.0
	root.add_child(camera)
	await _frames(SETTLE_FRAMES)
	for shot: String in _shots:
		var parts: PackedStringArray = shot.split(":")
		var at: PackedFloat64Array = parts[1].split_floats(",")
		var to: PackedFloat64Array = parts[2].split_floats(",")
		var eye: Vector3 = sector.to_global_point(Vector2(at[0], at[1])) + Vector3.UP * at[2]
		var target: Vector3 = sector.to_global_point(Vector2(to[0], to[1])) + Vector3.UP * 1.5
		camera.look_at_from_position(eye, target)
		camera.make_current()
		await _frames(10)
		var path: String = "%s/%s.jpg" % [_out, parts[0]]
		var err: Error = root.get_texture().get_image().save_jpg(path, 0.88)
		print("CAPTURE ", path, " ", error_string(err))
	quit()


func _frames(count: int) -> void:
	for i: int in count:
		await process_frame

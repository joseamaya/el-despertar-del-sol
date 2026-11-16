extends SceneTree
## Renders the style vignette with each palette and saves both shots as JPG (F3 visual
## guide). Needs a window (no --headless): the dummy renderer draws nothing.
##
##   godot --path . -s res://tools/capture_style.gd -- \
##       --out=docs/img/guia-visual --palettes=amanecer_calido,altura_fria,contraste

const SCENE: String = "res://scenes/tests/style_vignette.tscn"
const PALETTE_DIR: String = "res://resources/style/palette_%s.tres"
const SIZE: Vector2i = Vector2i(1600, 900)
## Frames to let shadows, fog and animation settle before each capture.
const SETTLE_FRAMES: int = 20

var _out: String = "user://style"
var _palettes: PackedStringArray = PackedStringArray(["amanecer_calido"])
var _vignette: StyleVignette


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		elif arg.begins_with("--palettes="):
			_palettes = arg.trim_prefix("--palettes=").split(",", false)
	DirAccess.make_dir_recursive_absolute(_out)
	root.size = SIZE
	_vignette = (load(SCENE) as PackedScene).instantiate() as StyleVignette
	root.add_child(_vignette)
	_capture_all.call_deferred()


func _capture_all() -> void:
	for palette_name: String in _palettes:
		_vignette.palette = load(PALETTE_DIR % palette_name) as PaletteTuning
		_vignette.rebuild()
		for shot: StyleVignette.Shot in [StyleVignette.Shot.WIDE, StyleVignette.Shot.DETAIL]:
			_vignette.use_shot(shot)
			for i: int in SETTLE_FRAMES:
				await process_frame
			await RenderingServer.frame_post_draw
			var path: String = "%s/%s-%s.jpg" % [_out, palette_name, _shot_name(shot)]
			var err: Error = root.get_texture().get_image().save_jpg(path, 0.88)
			print("CAPTURE ", path, " ", error_string(err))
	quit()


func _shot_name(shot: StyleVignette.Shot) -> String:
	return "general" if shot == StyleVignette.Shot.WIDE else "detalle"

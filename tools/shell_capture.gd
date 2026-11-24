extends SceneTree
## Opens the game shell, saves a shot of the title menu, the pause menu inside Carmenca and
## the loading screen, and prints how long Carmenca takes to load (F8 tasks 2–3). Needs a
## window (no --headless): the dummy renderer draws nothing, and the load time only means
## something on the reference machine.
##
##   godot --path . --resolution 1920x1080 -s res://tools/shell_capture.gd -- --out=<dir>

const SCENE: String = "res://scenes/game.tscn"
## Frames to let the menu and the level settle before a capture.
const SETTLE_FRAMES: int = 30

var _out: String = "user://shell"
var _shell: GameShell


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(_out)
	_shell = (load(SCENE) as PackedScene).instantiate() as GameShell
	root.add_child(_shell)
	_run.call_deferred()


func _run() -> void:
	await _capture("titulo")
	_shell.new_game()
	await process_frame
	await _capture("carga")
	while _shell.host.is_loading():
		await process_frame
	print("SHELL_LOAD carmenca %.2f s" % _shell.host.last_load_seconds)
	for i: int in 120:
		await process_frame
	var pause := _shell.host.current_level().get_node(^"PauseMenu") as PauseMenu
	pause.open()
	await _capture("pausa")
	quit()


func _capture(shot: String) -> void:
	for i: int in SETTLE_FRAMES:
		await process_frame
	await RenderingServer.frame_post_draw
	var path: String = "%s/%s.jpg" % [_out, shot]
	var err: Error = root.get_texture().get_image().save_jpg(path, 0.88)
	print("CAPTURE ", path, " ", error_string(err))

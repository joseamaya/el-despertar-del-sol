extends SceneTree
## Saves shots of the chapter's rough levels (F8 task 8): the prologue's first caption and
## its street, and the hub with a door's prompt. Needs a window (no --headless).
##
##   godot --path . --resolution 1920x1080 -s res://tools/chapter_capture.gd -- --out=<dir>

const SCENE: String = "res://scenes/game.tscn"
const SETTLE_FRAMES: int = 30

var _out: String = "user://chapter"
var _shell: GameShell


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(_out)
	_shell = (load(SCENE) as PackedScene).instantiate() as GameShell
	# Never the player's own saved game.
	_shell.saves = SaveGame.new()
	_shell.saves.path = "user://capture_partida.json"
	root.add_child(_shell)
	_run.call_deferred()


func _run() -> void:
	_shell.new_game()
	await _loaded()
	await _wait(60)
	await _capture("prologo-rotulo")
	# Past the captions: the street, Cusi walking up it among the people leaving.
	await _wait(1100)
	await _capture("prologo-calle")
	_shell.progress.complete(&"prologo")
	_shell.progress.complete(&"carmenca")
	_shell.go_on()
	await _loaded()
	await _wait(60)
	await _capture("centro")
	var level := _shell.host.current_level().get_node(^"SectorLevel") as SectorLevel
	level.place_player_at(&"Door_llamas", Vector3(0.0, 0.0, -1.0))
	await _wait(20)
	await _capture("centro-puerta")
	_shell.saves.erase()
	quit()


func _loaded() -> void:
	await process_frame
	while _shell.host.is_loading():
		await process_frame


func _wait(frames: int) -> void:
	for i: int in frames:
		await process_frame


func _capture(shot: String) -> void:
	for i: int in SETTLE_FRAMES:
		await process_frame
	await RenderingServer.frame_post_draw
	var path: String = "%s/%s.jpg" % [_out, shot]
	var err: Error = root.get_texture().get_image().save_jpg(path, 0.88)
	print("CAPTURE ", path, " ", error_string(err))

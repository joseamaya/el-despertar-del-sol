extends SceneTree
## Saves fixed shots of Carmenca from the player's camera (F3 task 11, «reconocible
## andino»), so a look change can be compared before and after. Enemies are removed except
## in the combat shot. Needs a window (no --headless): the dummy renderer draws nothing.
##
##   godot --path . -s res://tools/capture_sector.gd -- --out=docs/img/prueba-andina

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const SIZE: Vector2i = Vector2i(1600, 900)
## Frames to let the camera, shadows and fog settle before each capture.
const SETTLE_FRAMES: int = 30
## Frames for the combat shot: the warriors walk in and close the distance.
const FIGHT_FRAMES: int = 150
## [file name, marker, facing (layout frame, +Z downhill), camera pitch (rad)].
const SHOTS: Array = [
	["1_mirador", &"Start", Vector3(0, 0, 1), -0.22],
	["2_terrazas", &"Encounter1", Vector3(0, 0, -1), 0.08],
	["3_huaca", &"Huaca", Vector3(0, 0, -1), -0.05],
	["4_casas", &"Encounter2", Vector3(0, 0, -1), -0.02],
	["5_paso", &"Encounter3", Vector3(0, 0, -1), 0.02],
	["6_paso_al_valle", &"Encounter3", Vector3(0, 0, 1), -0.15],
]
const FIGHT_SHOT: Array = ["7_combate", &"Encounter3", Vector3(0, 0, -1), -0.1]

var _out: String = "user://sector"
var _level: SectorLevel
var _arena: ArenaController
## Warriors are kept for the combat shot and removed for the scenery shots.
var _keep_enemies: bool = true


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(_out)
	root.size = SIZE
	var scene: Node = (load(SCENE) as PackedScene).instantiate()
	# The slice would start its own zones (F4): the tool picks the pass instead.
	var slice := scene.get_node_or_null(^"SliceDirector") as SliceDirector
	if slice != null:
		slice.autostart = false
	root.add_child(scene)
	_level = scene.get_node(^"SectorLevel") as SectorLevel
	_arena = scene.get_node(^"ArenaController") as ArenaController
	_arena.encounter_started.connect(_on_encounter_started)
	_capture_all.call_deferred()


func _capture_all() -> void:
	# The level puts the player at the start on a deferred call: let that happen first.
	for i: int in 5:
		await process_frame
	# The fight first, at the pass.
	_arena.start_zone(3)
	await _capture(FIGHT_SHOT, FIGHT_FRAMES)
	_keep_enemies = false
	_on_encounter_started()
	for shot: Array in SHOTS:
		await _capture(shot, SETTLE_FRAMES)
	quit()


func _capture(shot: Array, frames: int) -> void:
	_level.place_player_at(shot[1], shot[2], shot[3])
	for i: int in frames:
		await process_frame
	await RenderingServer.frame_post_draw
	var path: String = "%s/%s.jpg" % [_out, shot[0]]
	root.get_texture().get_image().save_jpg(path, 0.85)
	print("CAPTURE_SECTOR ", path)


func _on_encounter_started() -> void:
	if _keep_enemies:
		return
	for enemy: EnemyController in _arena.alive_enemies():
		enemy.queue_free()

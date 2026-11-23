extends SceneTree
## Temporary agent-in-the-loop bridge (NOT part of the game, never commit):
## loads the main scene and lets an external script "play" it by writing commands to
## /tmp/opencode/cmd.txt. Each run executes the file's lines in order, then reports.
##
## Commands:
##   press|release <action> | hold <action> <ms> | look <dx> <dy> | wait <ms>
##   click <left|right|middle> | shot <name> | dump | quit
##
## Run:
##   godot --path . --display-driver x11 --resolution 1600x900 --position 0,0 \
##       -s res://tools/agent_bridge.gd

const CMD_PATH: String = "/tmp/opencode/cmd.txt"
const STATUS_PATH: String = "/tmp/opencode/status.json"
const SHOT_DIR: String = "/tmp/opencode/shots/"

var _last_content: String = ""
var _running: bool = false
var _level: SectorLevel
var _slice: SliceDirector
var _hud: Hud
var _arena: ArenaController
var _dialogue: DialoguePlayer
var _choice: ChoiceBox
var _interaction: InteractionPoint
var _drill: TrainingDrill
var _shot_index: int = 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	_last_content = FileAccess.get_file_as_string(CMD_PATH)
	_write_status({"state": "boot"})
	print("AGENT_BRIDGE ready")


func _process(_delta: float) -> bool:
	if _running:
		return false
	var content: String = FileAccess.get_file_as_string(CMD_PATH)
	if content != _last_content:
		_last_content = content
		_run(content)
	return false


func _run(content: String) -> void:
	_running = true
	await process_frame
	_bind()
	for raw: String in content.split("\n", false):
		var line: String = raw.strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var parts: PackedStringArray = line.split(" ", false)
		await _exec(parts)
	_bind()
	_write_status({"state": "idle"})
	_running = false


func _exec(parts: PackedStringArray) -> void:
	var verb: String = parts[0]
	match verb:
		"press":
			Input.action_press(parts[1])
			await process_frame
		"release":
			Input.action_release(parts[1])
			await process_frame
		"hold":
			Input.action_press(parts[1])
			await create_timer(float(parts[2]) / 1000.0).timeout
			Input.action_release(parts[1])
			await process_frame
		"tap":
			var pressed := InputEventAction.new()
			pressed.action = parts[1]
			pressed.pressed = true
			Input.parse_input_event(pressed)
			await create_timer(0.06).timeout
			var released := InputEventAction.new()
			released.action = parts[1]
			released.pressed = false
			Input.parse_input_event(released)
			await process_frame
		"look":
			if _camera() != null:
				_camera().add_look_input(Vector2(float(parts[1]), float(parts[2])))
			await process_frame
		"click":
			var button: int = {"left": MOUSE_BUTTON_LEFT, "right": MOUSE_BUTTON_RIGHT,
				"middle": MOUSE_BUTTON_MIDDLE}.get(parts[1], MOUSE_BUTTON_LEFT)
			var down := InputEventMouseButton.new()
			down.button_index = button
			down.pressed = true
			Input.parse_input_event(down)
			await create_timer(0.05).timeout
			var up := InputEventMouseButton.new()
			up.button_index = button
			up.pressed = false
			Input.parse_input_event(up)
			await process_frame
		"wait":
			await create_timer(float(parts[1]) / 1000.0).timeout
		"shot":
			await RenderingServer.frame_post_draw
			var image: Image = root.get_texture().get_image()
			var name: String = parts[1] if parts.size() > 1 else str(_shot_index)
			_shot_index += 1
			image.save_png(SHOT_DIR + name + ".png")
		"dump":
			_dump()
		"quit":
			quit()
		_:
			push_warning("AGENT_BRIDGE unknown command: " + verb)


func _bind() -> void:
	_level = _find_level(root)
	if _level != null:
		_slice = _find_type(root, "SliceDirector") as SliceDirector
		_hud = _find_type(root, "Hud") as Hud
		_arena = _level.arena
		_dialogue = _find_type(root, "DialoguePlayer") as DialoguePlayer
		_choice = _find_type(root, "ChoiceBox") as ChoiceBox
		_interaction = _find_type(root, "InteractionPoint") as InteractionPoint
		_drill = _find_type(root, "TrainingDrill") as TrainingDrill


func _find_level(node: Node) -> SectorLevel:
	if node is SectorLevel:
		return node as SectorLevel
	for child: Node in node.get_children():
		var found: SectorLevel = _find_level(child)
		if found != null:
			return found
	return null


func _find_type(node: Node, type_name: String) -> Node:
	if node.get_script() != null:
		var script: Script = node.get_script() as Script
		if script.get_global_name() == type_name:
			return node
	for child: Node in node.get_children():
		var found: Node = _find_type(child, type_name)
		if found != null:
			return found
	return null


func _camera() -> CameraController:
	return _level.camera_rig if _level != null else null


func _dump() -> void:
	var state: Dictionary = {
		"fps": Engine.get_frames_per_second(),
		"pos": _vector(_level.player.global_position) if _level != null else null,
		"yaw": _camera().yaw if _camera() != null else 0.0,
		"health": _health("Health"),
		"stamina": _health("Stamina"),
		"step": -1,
		"step_kind": "",
		"objective": _hud.objective_text() if _hud != null else "",
		"objective_visible": _hud.is_showing_objective() if _hud != null else false,
		"dialogue": _dialogue.is_playing() if _dialogue != null else false,
		"choice": _choice.is_asking() if _choice != null else false,
		"prompt": _interaction.is_in_reach() if _interaction != null else false,
		"play_time": _slice.play_time if _slice != null else 0.0,
		"finished": _slice.is_finished() if _slice != null else false,
		"enemies": 0,
		"enemy_hp": [],
		"time_scale": Engine.time_scale,
		"mouse": Input.mouse_mode,
	}
	if _slice != null and _slice.flow != null:
		state["step"] = _slice.flow.index()
		var step: SliceStep = _slice.flow.current()
		if step != null:
			state["step_kind"] = SliceStep.Kind.keys()[step.kind]
			state["step_marker"] = String(step.marker)
			state["drill"] = step.drill
	if _arena != null:
		state["enemies"] = _arena.alive_enemies().size()
		var hp: Array[float] = []
		for enemy: EnemyController in _arena.alive_enemies():
			hp.append(enemy.health.current)
		state["enemy_hp"] = hp
	FileAccess.open("/tmp/opencode/dump.json", FileAccess.WRITE).store_string(
		JSON.stringify(state, " ")
	)
	_write_status({"state": "dumped"})


func _health(node_name: String) -> float:
	if _level == null:
		return 0.0
	var component: Node = _level.player.get_node_or_null(node_name)
	if component is HealthComponent:
		return (component as HealthComponent).current
	if component is StaminaComponent:
		return (component as StaminaComponent).current
	return 0.0


func _vector(v: Vector3) -> Array[float]:
	return [snappedf(v.x, 0.01), snappedf(v.y, 0.01), snappedf(v.z, 0.01)]


func _write_status(state: Dictionary) -> void:
	state["state"] = state.get("state", "playing")
	FileAccess.open(STATUS_PATH, FileAccess.WRITE).store_string(JSON.stringify(state, " "))

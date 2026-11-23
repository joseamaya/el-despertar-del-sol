extends SceneTree
## Block diagnosis (F6 task 2): the player holds block and a BlockProbe counts what every
## blow does and why the ones that land got through. Runs headless at a fixed step, so
## a minute of play takes a few seconds and two runs give the same result.
##
##   godot --headless --fixed-fps 60 --path . -s res://tools/block_diagnosis.gd -- \
##       --mode=arena --enemies=3 [--lock] [--fight] --seconds=120 --out=/tmp/block.json
##   godot --headless --fixed-fps 60 --path . -s res://tools/block_diagnosis.gd -- \
##       --mode=training [--lock] --seconds=120
##
## arena: the F2 combat arena with 1 to 3 warriors. The player stays where they spawn.
## training: Vicaquirao's block drill at the lookout (F4 task 12a), made endless.
## --lock: lock onto the nearest warrior, so the player faces it.
## --fight: a light attack every 2.5 s between guards, like a player trading blows.
## The player cannot die; stamina, guard breaks and stuns are real. Prints one line
## prefixed with BLOCK_DIAGNOSIS and writes the same JSON to --out.

const ARENA: String = "res://scenes/tests/combat_arena.tscn"
const CARMENCA: String = "res://scenes/levels/carmenca.tscn"
const ACTION_BLOCK: StringName = &"block"
const ATTACK_INTERVAL: float = 2.5
const SETTLE_FRAMES: int = 30

var _mode: String = "arena"
var _enemies: int = 3
var _lock: bool = false
var _fight: bool = false
var _seconds: float = 120.0
var _out: String = "user://block_diagnosis.json"
var _scene: Node
var _player: PlayerController
var _probe: BlockProbe


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--mode="):
			_mode = arg.trim_prefix("--mode=")
		elif arg.begins_with("--enemies="):
			_enemies = clampi(int(arg.trim_prefix("--enemies=")), 1, 3)
		elif arg == "--lock":
			_lock = true
		elif arg == "--fight":
			_fight = true
		elif arg.begins_with("--seconds="):
			_seconds = float(arg.trim_prefix("--seconds="))
		elif arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	_scene = (load(CARMENCA if _mode == "training" else ARENA) as PackedScene).instantiate()
	root.add_child(_scene)
	_run.call_deferred()


func _run() -> void:
	_player = _scene.find_child("Player", true, false) as PlayerController
	(_scene.find_child("CameraRig", true, false) as CameraController).capture_mouse = false
	await _frames(SETTLE_FRAMES)
	if _mode == "training":
		await _to_block_drill()
	else:
		_keep_warriors(_enemies)
	_probe = BlockProbe.new()
	_probe.player = _player
	_scene.add_child(_probe)
	var health := _player.get_node(^"Health") as HealthComponent
	var combat := _player.get_node(^"Combat") as CombatComponent
	var lock := _player.get_node(^"LockOn") as LockOnController
	var until_attack: float = ATTACK_INTERVAL
	var step: float = 1.0 / Engine.physics_ticks_per_second
	var elapsed: float = 0.0
	while elapsed < _seconds:
		health.reset()
		if _lock and not lock.is_locked():
			_face_nearest()
			lock.toggle_lock()
		until_attack -= step
		if _fight and until_attack <= 0.0 and not combat.is_attacking():
			until_attack = ATTACK_INTERVAL
			Input.action_release(ACTION_BLOCK)
			combat.request(CombatComponent.Kind.LIGHT)
		elif not combat.is_attacking():
			Input.action_press(ACTION_BLOCK)
		await physics_frame
		elapsed += step
	Input.action_release(ACTION_BLOCK)
	var result: Dictionary = _probe.report()
	result["mode"] = _mode
	result["enemies"] = _enemies if _mode == "arena" else 1
	result["lock"] = _lock
	result["fight"] = _fight
	result["seconds"] = _seconds
	result["block_arc_deg"] = (
		(_player.get_node(^"Defense") as DefenseComponent).tuning.block_arc_deg
	)
	var text: String = JSON.stringify(result)
	print("BLOCK_DIAGNOSIS ", text)
	var file := FileAccess.open(_out, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
	quit()


func _frames(count: int) -> void:
	for i: int in count:
		await physics_frame


## Leaves `count` warriors in the arena (it spawns three).
func _keep_warriors(count: int) -> void:
	var arena := _scene.find_child("ArenaController", true, false) as ArenaController
	var alive: Array[EnemyController] = arena.alive_enemies()
	for i: int in range(count, alive.size()):
		alive[i].queue_free()
	# They spawn facing away: tell them where the player is, as the fight driver does.
	for i: int in mini(count, alive.size()):
		alive[i].perception.alert_to(_player.global_position)


## Plays the opening up to Vicaquirao's block drill and makes it endless.
func _to_block_drill() -> void:
	var slice := _scene.find_child("SliceDirector", true, false) as SliceDirector
	var talk := _scene.find_child("DialoguePlayer", true, false) as DialoguePlayer
	var choice := _scene.find_child("ChoiceBox", true, false) as ChoiceBox
	slice.skip_intro()
	for i: int in 200:
		while talk.is_playing():
			talk.advance()
		if choice.is_asking():
			choice.select(0)
			choice.confirm()
		var step: SliceStep = slice.flow.current()
		if step.kind == SliceStep.Kind.DRILL:
			# Two blocks would end it: let him keep striking for the whole measure.
			step.count = 100000
			return
		await physics_frame


func _face_nearest() -> void:
	var rig := _scene.find_child("CameraRig", true, false) as CameraController
	var nearest: Node3D = null
	for node: Node in _scene.find_children("*", "EnemyController", true, false):
		var enemy := node as EnemyController
		if enemy.is_dead():
			continue
		if (
			nearest == null
			or (
				enemy.global_position.distance_to(_player.global_position)
				< nearest.global_position.distance_to(_player.global_position)
			)
		):
			nearest = enemy
	if nearest == null:
		return
	var to: Vector3 = nearest.global_position - _player.global_position
	rig.yaw = atan2(-to.x, -to.z)
	rig.snap_to_target()

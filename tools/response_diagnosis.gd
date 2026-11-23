extends SceneTree
## Response diagnosis (F6 task 6): a bot fights in the combat arena like a player, pressing
## attack at a steady pace and dodging when a warrior's blow is about to land, and a
## ResponseProbe records what became of every press. Headless at a fixed step.
##
##   godot --headless --fixed-fps 60 --path . -s res://tools/response_diagnosis.gd -- \
##       --enemies=3 --attack-every=0.45 --seconds=120 --out=/tmp/response.json
##
## --attack-every: seconds between attack presses (a player mashing: 0.3; calm: 0.7).
## Every fourth attack press is heavy. Like a player who sees a blow coming, the bot holds
## its attacks for HOLD_BEFORE_DODGE before each dodge. --old-rules takes the player's
## ResponseTuning away (no kept presses, dodge cuts only the recovery), to compare.
## --dodge-cost=N and --regen-delay=S try other stamina values (copies; nothing saved).
## The player cannot die; stamina is real.

const ARENA: String = "res://scenes/tests/combat_arena.tscn"
const SETTLE_FRAMES: int = 30
## A player reacts this long before the warrior's blow turns active.
const REACT_BEFORE: float = 0.2
## Only blows from this close are worth a dodge.
const DODGE_RANGE: float = 3.5
## The bot stops pressing attack this long before a planned dodge.
const HOLD_BEFORE_DODGE: float = 0.4

var _enemies: int = 3
var _attack_every: float = 0.45
var _seconds: float = 120.0
var _out: String = "user://response_diagnosis.json"
var _old_rules: bool = false
var _dodge_cost: float = -1.0
var _regen_delay: float = -1.0
var _scene: Node
var _player: PlayerController
var _probe: ResponseProbe
## Game time at which to press dodge (one per incoming blow).
var _dodge_at: PackedFloat32Array = PackedFloat32Array()
var _clock: float = 0.0


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--enemies="):
			_enemies = clampi(int(arg.trim_prefix("--enemies=")), 1, 3)
		elif arg.begins_with("--attack-every="):
			_attack_every = float(arg.trim_prefix("--attack-every="))
		elif arg.begins_with("--seconds="):
			_seconds = float(arg.trim_prefix("--seconds="))
		elif arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		elif arg == "--old-rules":
			_old_rules = true
		elif arg.begins_with("--dodge-cost="):
			_dodge_cost = float(arg.trim_prefix("--dodge-cost="))
		elif arg.begins_with("--regen-delay="):
			_regen_delay = float(arg.trim_prefix("--regen-delay="))
	_scene = (load(ARENA) as PackedScene).instantiate()
	root.add_child(_scene)
	_run.call_deferred()


func _run() -> void:
	_player = _scene.find_child("Player", true, false) as PlayerController
	(_scene.find_child("CameraRig", true, false) as CameraController).capture_mouse = false
	for i: int in SETTLE_FRAMES:
		await physics_frame
	var arena := _scene.find_child("ArenaController", true, false) as ArenaController
	var alive: Array[EnemyController] = arena.alive_enemies()
	for i: int in range(_enemies, alive.size()):
		alive[i].queue_free()
	for i: int in mini(_enemies, alive.size()):
		alive[i].perception.alert_to(_player.global_position)
		alive[i].combat.attack_started.connect(_on_enemy_attack.bind(alive[i]))
	var defense := _player.get_node(^"Defense") as DefenseComponent
	if _dodge_cost >= 0.0:
		defense.tuning = defense.tuning.duplicate() as DefenseTuning
		defense.tuning.dodge_stamina_cost = _dodge_cost
	var stamina := _player.get_node(^"Stamina") as StaminaComponent
	if _regen_delay >= 0.0:
		stamina.tuning = stamina.tuning.duplicate() as StaminaTuning
		stamina.tuning.regen_delay = _regen_delay
	if _old_rules:
		(_player.get_node(^"Defense") as DefenseComponent).response = null
		(_player.get_node(^"Combat") as CombatComponent).response = null
	_probe = ResponseProbe.new()
	_probe.player = _player
	_scene.add_child(_probe)
	var health := _player.get_node(^"Health") as HealthComponent
	var lock := _player.get_node(^"LockOn") as LockOnController
	var step: float = 1.0 / Engine.physics_ticks_per_second
	var until_attack: float = 0.0
	var attacks: int = 0
	while _clock < _seconds:
		health.reset()
		for enemy: EnemyController in arena.alive_enemies():
			enemy.health.reset()
			enemy.posture.reset()
		if not lock.is_locked():
			lock.toggle_lock()
		if not _dodge_at.is_empty() and _clock >= _dodge_at[0]:
			_dodge_at.remove_at(0)
			_probe.press_dodge()
		until_attack -= step
		var dodge_soon: bool = (
			not _dodge_at.is_empty() and _dodge_at[0] - _clock < HOLD_BEFORE_DODGE
		)
		if until_attack <= 0.0 and not dodge_soon:
			until_attack = _attack_every
			attacks += 1
			var kind := (
				CombatComponent.Kind.HEAVY if attacks % 4 == 0 else CombatComponent.Kind.LIGHT
			)
			_probe.press_attack(kind)
		await physics_frame
		_clock += step
	var result: Dictionary = _probe.report()
	result["enemies"] = _enemies
	result["attack_every"] = _attack_every
	result["seconds"] = _seconds
	result["old_rules"] = _old_rules
	result["dodge_cost"] = _dodge_cost
	result["regen_delay"] = _regen_delay
	var text: String = JSON.stringify(result)
	print("RESPONSE_DIAGNOSIS ", text)
	var file := FileAccess.open(_out, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
	quit()


func _on_enemy_attack(data: AttackData, enemy: EnemyController) -> void:
	if enemy.global_position.distance_to(_player.global_position) > DODGE_RANGE:
		return
	var at: float = _clock + maxf(0.0, AttackRules.real(data.windup_end, data) - REACT_BEFORE)
	var i: int = _dodge_at.bsearch(at)
	_dodge_at.insert(i, at)

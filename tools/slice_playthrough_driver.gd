class_name SlicePlaythroughDriver
extends Node
## Plays the whole vertical slice like a quick player (F4 task 12): walks the path with the
## game camera, reads every line, does Vicaquirao's drills (task 12a), makes the offering,
## helps the ayllu and frees the llamas, fights every skirmish with lock-on and light
## attacks, and reaches the end.
## The player cannot die (it measures the slice, not the bot's skill). Gives up with an
## error if a step takes too long. Not part of the game: tools/scene_benchmark.gd adds it
## (--playthrough).

signal finished
signal stuck(reason: String)

const ACTION_FORWARD: StringName = &"move_forward"
const ACTION_ATTACK: StringName = &"attack_light"
const ACTION_BLOCK: StringName = &"block"
const ACTION_DODGE: StringName = &"dodge"
const REACH: float = 1.2
## Reading pace per dialogue line, and a moment before choosing.
const READ_TIME: float = 2.5
const CHOOSE_TIME: float = 1.5
## The bot goes straight for a warrior this close (same terrace); farther ones it meets
## by following the path to the zone, where they come to it. Straight lines across the
## terraces hit their walls.
const FIGHT_RANGE: float = 6.0
## Once at the zone's centre, it goes for the nearest warrior wherever it is.
const ZONE_REACHED: float = 3.0
const STRIKE_RANGE: float = 1.8
const ATTACK_INTERVAL: float = 0.55
## The bot guards or dodges this long before Vicaquirao's blow turns active.
const REACT_EARLY: float = 0.05
## A parry needs the guard still up when the blow lands.
const GUARD_HOLD: float = 0.4
## Longest a step may take before the bot reports it stuck.
const STEP_TIMEOUT: float = 150.0

@export var slice: SliceDirector
@export var level: SectorLevel
@export var arena: ArenaController
@export var dialogue: DialoguePlayer
@export var choice: ChoiceBox
@export var interaction: InteractionPoint
## Optional: Vicaquirao's drills.
@export var drill: TrainingDrill

var _path: PackedVector2Array = PackedVector2Array()
var _next: int = 1
var _wait: float = 0.0
var _attack_left: float = 0.0
var _step_time: float = 0.0
var _step: SliceStep
var _done: bool = false
var _act_times: Dictionary = {}
var _act: String = ""
var _seen_attack: AttackData
var _attack_elapsed: float = 0.0
var _guard_left: float = 0.0


func _ready() -> void:
	assert(slice != null and level != null and arena != null, "SlicePlaythroughDriver: parts.")
	# Press before the player's components read input this frame: a press made after
	# them is no longer "just pressed" on the next one (the dodge needs that).
	process_physics_priority = -100
	_path = level.layout.path
	slice.step_started.connect(_on_step_started)
	slice.act_changed.connect(_on_act_changed)
	slice.slice_finished.connect(_on_finished)


func _physics_process(delta: float) -> void:
	if _done or slice.flow == null:
		return
	_keep_alive()
	_step_time += delta
	if _step_time > STEP_TIMEOUT:
		_done = true
		_release()
		stuck.emit("step %d (%s) took over %d s" % [slice.flow.index(), _describe(), STEP_TIMEOUT])
		return
	if dialogue.is_playing():
		_release()
		_wait += delta
		if _wait >= READ_TIME:
			_wait = 0.0
			dialogue.advance()
		return
	if choice.is_asking():
		_release()
		_wait += delta
		if _wait >= CHOOSE_TIME:
			_wait = 0.0
			choice.select(0)
			choice.confirm()
		return
	var step: SliceStep = slice.flow.current()
	if step == null:
		_release()
		return
	match step.kind:
		SliceStep.Kind.ENCOUNTER:
			_fight_or_walk(level.layout.encounters[step.zone - 1], delta)
		SliceStep.Kind.INTERACT:
			_interact(step)
		SliceStep.Kind.REACH:
			_walk_towards(_layout_point(level.marker_position(step.marker)))
		SliceStep.Kind.DRILL:
			_train(step, delta)
		_:
			_release()


func is_done() -> bool:
	return _done


## The act being played, to group the benchmark's frames.
func stretch() -> String:
	return _act


## Seconds of play per act.
func act_times() -> Dictionary:
	return _act_times


func _on_step_started(step: SliceStep) -> void:
	_step = step
	_step_time = 0.0
	_wait = 0.0


func _on_act_changed(act: SliceStep.Act) -> void:
	_act = String(SliceStep.Act.keys()[act]).to_lower()


func _on_finished() -> void:
	_done = true
	_release()
	finished.emit()


func _process(delta: float) -> void:
	if not _done and _act != "":
		_act_times[_act] = float(_act_times.get(_act, 0.0)) + delta


func _keep_alive() -> void:
	var health := level.player.get_node(^"Health") as HealthComponent
	if health.current < health.get_maximum() * 0.5:
		health.reset()
	(level.player.get_node(^"Stamina") as StaminaComponent).reset()


## Walks the path forward until its closest point to `goal`, then straight to it.
func _walk_towards(goal: Vector2) -> void:
	var at: Vector2 = _layout_point(level.player.global_position)
	var closest: int = _closest_path_index(goal)
	var target: Vector2 = goal
	if _next <= closest:
		target = _path[_next]
		if at.distance_to(target) < REACH:
			_next += 1
			return
	_head_to(level.to_global_point(target))


func _fight_or_walk(zone: Vector3, delta: float) -> void:
	var enemy: EnemyController = _nearest_enemy()
	var centre := Vector2(zone.x, zone.y)
	var at_zone: bool = (
		_layout_point(level.player.global_position).distance_to(centre) < ZONE_REACHED
	)
	if (
		enemy == null
		or (enemy.distance_to(level.player.global_position) > FIGHT_RANGE and not at_zone)
	):
		_walk_towards(centre)
		return
	var lock := level.player.get_node(^"LockOn") as LockOnController
	if not lock.is_locked():
		lock.toggle_lock()
	var gap: float = enemy.distance_to(level.player.global_position)
	if gap > STRIKE_RANGE:
		_head_to(enemy.global_position)
	else:
		Input.action_release(ACTION_FORWARD)
	_attack_left -= delta
	Input.action_release(ACTION_ATTACK)
	if _attack_left <= 0.0 and gap <= STRIKE_RANGE + 0.6:
		_attack_left = ATTACK_INTERVAL
		Input.action_press(ACTION_ATTACK)


## Faces Vicaquirao and does what the drill asks: guard; guard or dodge just before his
## blow turns active (the parry window is short); or strike.
func _train(step: SliceStep, delta: float) -> void:
	var trainer: EnemyController = drill.trainer() if drill != null else null
	if trainer == null:
		_release()
		return
	var lock := level.player.get_node(^"LockOn") as LockOnController
	if not lock.is_locked():
		lock.toggle_lock()
	var gap: float = trainer.distance_to(level.player.global_position)
	if gap > STRIKE_RANGE + 0.8:
		_head_to(trainer.global_position)
	else:
		Input.action_release(ACTION_FORWARD)
	var attack: AttackData = trainer.combat.get_current()
	var before: float = _attack_elapsed
	if attack != _seen_attack:
		_seen_attack = attack
		_attack_elapsed = 0.0
		before = -1.0
	else:
		_attack_elapsed += delta
	var react_at: float = (
		AttackRules.real(attack.windup_end, attack) - REACT_EARLY if attack != null else INF
	)
	var turned_active: bool = before < react_at and _attack_elapsed >= react_at
	Input.action_release(ACTION_DODGE)
	match step.drill:
		SliceStep.Drill.BLOCK:
			Input.action_press(ACTION_BLOCK)
		SliceStep.Drill.PARRY:
			if turned_active:
				_guard_left = GUARD_HOLD
				Input.action_press(ACTION_BLOCK)
			_guard_left -= delta
			if _guard_left <= 0.0:
				Input.action_release(ACTION_BLOCK)
		SliceStep.Drill.EVADE:
			Input.action_release(ACTION_BLOCK)
			if turned_active:
				Input.action_press(ACTION_DODGE)
		SliceStep.Drill.HIT:
			Input.action_release(ACTION_BLOCK)
			_attack_left -= delta
			Input.action_release(ACTION_ATTACK)
			if _attack_left <= 0.0 and gap <= STRIKE_RANGE + 0.6:
				_attack_left = ATTACK_INTERVAL
				Input.action_press(ACTION_ATTACK)


func _interact(step: SliceStep) -> void:
	if interaction.is_locked():
		# The skirmish before it is still on: fight it first (the zone behind the step).
		_release()
		return
	var marker: Vector2 = _layout_point(level.marker_position(step.marker))
	# In front of it (+Z, where the path comes from): the huaca's pirca opens there.
	var spot: Vector2 = marker + Vector2(0.0, minf(step.radius * 0.7, 3.0))
	if interaction.is_in_reach():
		_release()
		interaction.try_interact()
		return
	_walk_towards(spot)


func _head_to(point: Vector3) -> void:
	var to: Vector3 = point - level.player.global_position
	to.y = 0.0
	var lock := level.player.get_node(^"LockOn") as LockOnController
	if not lock.is_locked():
		level.camera_rig.yaw = atan2(-to.x, -to.z)
	Input.action_press(ACTION_FORWARD)


func _release() -> void:
	Input.action_release(ACTION_FORWARD)
	Input.action_release(ACTION_ATTACK)
	Input.action_release(ACTION_BLOCK)
	Input.action_release(ACTION_DODGE)
	var lock := level.player.get_node(^"LockOn") as LockOnController
	if lock.is_locked() and arena.alive_enemies().is_empty():
		lock.toggle_lock()


func _nearest_enemy() -> EnemyController:
	var best: EnemyController = null
	for enemy: EnemyController in arena.alive_enemies():
		var d: float = enemy.distance_to(level.player.global_position)
		if best == null or d < best.distance_to(level.player.global_position):
			best = enemy
	return best


func _closest_path_index(goal: Vector2) -> int:
	var best: int = 0
	for i: int in _path.size():
		if _path[i].distance_to(goal) < _path[best].distance_to(goal):
			best = i
	return best


func _layout_point(global: Vector3) -> Vector2:
	var local: Vector3 = level.sector.to_local(global)
	return Vector2(local.x, local.z)


func _describe() -> String:
	if _step == null:
		return "-"
	return "%s %s zone %d" % [SliceStep.Kind.keys()[_step.kind], _step.marker, _step.zone]


func _exit_tree() -> void:
	_release()

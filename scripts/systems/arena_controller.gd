class_name ArenaController
extends Node
## Runs a combat encounter (F2 task 10): spawns the enemies, detects defeat and victory
## (GDD §14.4 criterion 6) and restarts everything on request without reloading the scene.
## With `zone_sizes` set (F4 task 2) it runs one zone at a time: nothing spawns until
## start_zone(), a defeat respawns only the active zone, and won zones stay empty. Once a
## zone has noticed the player its warriors keep hunting them, so no straggler is left
## standing far away holding the slice (F4 task 6).

signal encounter_started
signal player_defeated
signal encounter_won
signal combat_changed(in_combat: bool)
## Zone mode only, instead of encounter_won: zone `zone` (1-based) has been cleared.
signal zone_won(zone: int)

enum EncounterState { FIGHTING, DEFEATED, WON }

const ACTION_RESTART: StringName = &"restart"

@export var player: PlayerController
@export var player_spawn: Node3D
@export var enemy_scene: PackedScene
@export var spawn_points: Array[Node3D] = []
## Enemies per zone, in `spawn_points` order. Empty: one encounter with every spawn point,
## started when ready (the F2 arena).
@export var zone_sizes: PackedInt32Array = PackedInt32Array()
@export var enemies_root: Node3D
@export var director: EncounterDirector
## Seconds between the player's fall and the defeat message.
@export_range(0.0, 5.0, 0.1, "suffix:s") var defeat_delay: float = 1.5
@export var death_clip: StringName = &"Death01"
## Zone mode: how often warriors that do not sense the player are told where they are.
@export_range(0.5, 10.0, 0.5, "suffix:s") var hunt_interval: float = 2.0

var state: EncounterState = EncounterState.FIGHTING
## Zone being fought (1-based); 0 before the first one.
var active_zone: int = 0
var _won_zones: Array[int] = []
var _enemies: Array[EnemyController] = []
var _in_combat: bool = false
var _player_health: HealthComponent
var _player_stamina: StaminaComponent
var _engaged: bool = false
var _hunt_left: float = 0.0


func _ready() -> void:
	assert(player != null and player_spawn != null and enemy_scene != null, "Arena: parts.")
	assert(enemies_root != null and not spawn_points.is_empty(), "Arena: enemies.")
	_player_health = player.get_node("Health") as HealthComponent
	_player_stamina = player.get_node("Stamina") as StaminaComponent
	_player_health.died.connect(_on_player_died)
	reset_encounter.call_deferred()


func _physics_process(delta: float) -> void:
	var aware: bool = false
	for enemy: EnemyController in alive_enemies():
		if enemy.perception.has_target():
			aware = true
	if aware != _in_combat:
		_in_combat = aware
		combat_changed.emit(_in_combat)
	if not is_zoned() or state != EncounterState.FIGHTING:
		return
	_engaged = _engaged or aware
	if _engaged:
		_hunt_left -= delta
		if _hunt_left <= 0.0:
			_hunt_left = hunt_interval
			_hunt()


func _unhandled_input(event: InputEvent) -> void:
	# In zone mode a won zone is not the end: only a defeat can be retried.
	var can_retry: bool = (
		state == EncounterState.DEFEATED or (state == EncounterState.WON and not is_zoned())
	)
	if can_retry and event.is_action_pressed(ACTION_RESTART):
		reset_encounter()


## Back to the spawn with full health and stamina and fresh enemies: all of them, or in
## zone mode only those of the active zone if it has not been won.
func reset_encounter() -> void:
	_clear_enemies()
	player.respawn(player_spawn.global_position, player_spawn.global_rotation.y)
	_player_health.reset()
	_player_stamina.reset()
	_set_player_controls(true)
	if not is_zoned():
		for point: Node3D in spawn_points:
			_spawn_enemy(point)
	elif active_zone > 0 and not _won_zones.has(active_zone):
		_spawn_zone(active_zone)
	_disengage()
	state = EncounterState.FIGHTING
	encounter_started.emit()


## Zone mode: spawns the enemies of zone `zone` (1-based), which becomes the active one.
func start_zone(zone: int) -> void:
	assert(is_zoned() and zone >= 1 and zone <= zone_sizes.size(), "Arena: no zone %d." % zone)
	_clear_enemies()
	active_zone = zone
	_spawn_zone(zone)
	_disengage()
	state = EncounterState.FIGHTING
	encounter_started.emit()


func is_zoned() -> bool:
	return not zone_sizes.is_empty()


func is_zone_won(zone: int) -> bool:
	return _won_zones.has(zone)


func alive_enemies() -> Array[EnemyController]:
	var alive: Array[EnemyController] = []
	for enemy: EnemyController in _enemies:
		if is_instance_valid(enemy) and not enemy.is_dead():
			alive.append(enemy)
	return alive


func is_in_combat() -> bool:
	return _in_combat


## Zone mode: the active zone has noticed the player and still has warriors standing.
func is_zone_engaged() -> bool:
	return (
		is_zoned()
		and _engaged
		and state == EncounterState.FIGHTING
		and not alive_enemies().is_empty()
	)


func _disengage() -> void:
	_engaged = false
	_hunt_left = 0.0


## Warriors of the active zone that do not sense their target (the player, or a comunero
## who drew them away, F4 task 6) go to where it is.
func _hunt() -> void:
	for enemy: EnemyController in alive_enemies():
		var sense: PerceptionComponent = enemy.perception
		if is_instance_valid(sense.target) and not sense.can_sense():
			sense.alert_to(sense.target.global_position)


func _clear_enemies() -> void:
	for enemy: EnemyController in _enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_enemies.clear()


func _spawn_zone(zone: int) -> void:
	var first: int = 0
	for i: int in zone - 1:
		first += zone_sizes[i]
	for i: int in range(first, mini(first + zone_sizes[zone - 1], spawn_points.size())):
		_spawn_enemy(spawn_points[i])


func _spawn_enemy(point: Node3D) -> void:
	var enemy := enemy_scene.instantiate() as EnemyController
	enemy.director = director
	(enemy.get_node("Perception") as PerceptionComponent).target = player
	enemies_root.add_child(enemy)
	enemy.global_position = point.global_position
	enemy.rotation.y = point.global_rotation.y
	enemy.home_position = point.global_position
	enemy.health.died.connect(_on_enemy_died)
	_enemies.append(enemy)


func _on_enemy_died() -> void:
	if state != EncounterState.FIGHTING or not alive_enemies().is_empty():
		return
	state = EncounterState.WON
	if is_zoned():
		_won_zones.append(active_zone)
		zone_won.emit(active_zone)
	else:
		encounter_won.emit()


func _on_player_died() -> void:
	if state != EncounterState.FIGHTING:
		return
	state = EncounterState.DEFEATED
	_set_player_controls(false)
	player.begin_action(Vector3.ZERO, false)
	var animator := player.get_node("Animator") as CharacterAnimator
	animator.play_attack(death_clip, 1.0)
	for enemy: EnemyController in alive_enemies():
		enemy.perception.target = null
	await get_tree().create_timer(defeat_delay, false).timeout
	if state == EncounterState.DEFEATED:
		player_defeated.emit()


func _set_player_controls(enabled: bool) -> void:
	for part: String in ["Combat", "Defense"]:
		var node: Node = player.get_node(part)
		node.set_physics_process(enabled)
	var lock := player.get_node("LockOn") as LockOnController
	lock.release(LockOnController.ReleaseReason.TARGET_LOST)

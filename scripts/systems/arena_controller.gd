class_name ArenaController
extends Node
## Runs a combat encounter (F2 task 10): spawns the enemies, detects defeat and victory
## (GDD §14.4 criterion 6) and restarts everything on request without reloading the scene.

signal encounter_started
signal player_defeated
signal encounter_won
signal combat_changed(in_combat: bool)

enum EncounterState { FIGHTING, DEFEATED, WON }

const ACTION_RESTART: StringName = &"restart"

@export var player: PlayerController
@export var player_spawn: Node3D
@export var enemy_scene: PackedScene
@export var spawn_points: Array[Node3D] = []
@export var enemies_root: Node3D
@export var director: EncounterDirector
## Seconds between the player's fall and the defeat message.
@export_range(0.0, 5.0, 0.1, "suffix:s") var defeat_delay: float = 1.5
@export var death_clip: StringName = &"Death01"

var state: EncounterState = EncounterState.FIGHTING
var _enemies: Array[EnemyController] = []
var _in_combat: bool = false
var _player_health: HealthComponent
var _player_stamina: StaminaComponent


func _ready() -> void:
	assert(player != null and player_spawn != null and enemy_scene != null, "Arena: parts.")
	assert(enemies_root != null and not spawn_points.is_empty(), "Arena: enemies.")
	_player_health = player.get_node("Health") as HealthComponent
	_player_stamina = player.get_node("Stamina") as StaminaComponent
	_player_health.died.connect(_on_player_died)
	reset_encounter.call_deferred()


func _physics_process(_delta: float) -> void:
	var aware: bool = false
	for enemy: EnemyController in alive_enemies():
		if enemy.perception.has_target():
			aware = true
	if aware != _in_combat:
		_in_combat = aware
		combat_changed.emit(_in_combat)


func _unhandled_input(event: InputEvent) -> void:
	if state != EncounterState.FIGHTING and event.is_action_pressed(ACTION_RESTART):
		reset_encounter()


## Back to the start: player at the spawn with full health and stamina, fresh enemies.
func reset_encounter() -> void:
	for enemy: EnemyController in _enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_enemies.clear()
	player.respawn(player_spawn.global_position, player_spawn.global_rotation.y)
	_player_health.reset()
	_player_stamina.reset()
	_set_player_controls(true)
	for point: Node3D in spawn_points:
		_spawn_enemy(point)
	state = EncounterState.FIGHTING
	encounter_started.emit()


func alive_enemies() -> Array[EnemyController]:
	var alive: Array[EnemyController] = []
	for enemy: EnemyController in _enemies:
		if is_instance_valid(enemy) and not enemy.is_dead():
			alive.append(enemy)
	return alive


func is_in_combat() -> bool:
	return _in_combat


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
	if state == EncounterState.FIGHTING and alive_enemies().is_empty():
		state = EncounterState.WON
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

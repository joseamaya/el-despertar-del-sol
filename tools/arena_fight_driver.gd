class_name ArenaFightDriver
extends Node
## Benchmark helper (F2 task 12): keeps a combat arena fighting for as long as it is
## measured. The player stands near the enemies guarding, with a light attack every few
## seconds, and nobody can die or be executed, so the encounter never ends mid-capture.
## Not part of the game: only tools/scene_benchmark.gd adds it (--fight).

const ACTION_BLOCK: StringName = &"block"
## Where the player waits for the enemies: in front of all spawns, clear of the pillars.
const FIGHT_SPOT: Vector3 = Vector3(2.0, 0.05, -3.0)
## Extra spawn points for --enemies above the arena's own (inside the pirca ring).
const EXTRA_SPAWNS: Array[Vector3] = [
	Vector3(0.0, 0.05, -14.0),
	Vector3(-11.0, 0.05, -4.0),
	Vector3(11.0, 0.05, -4.0),
]

@export var arena: ArenaController
@export_range(0.5, 10.0, 0.1, "suffix:s") var attack_interval: float = 2.5

var _player_health: HealthComponent
var _player_stamina: StaminaComponent
var _player_combat: CombatComponent
var _until_attack: float = 0.0


func _ready() -> void:
	assert(arena != null, "ArenaFightDriver needs the arena.")
	var player: PlayerController = arena.player
	_player_health = player.get_node("Health") as HealthComponent
	_player_stamina = player.get_node("Stamina") as StaminaComponent
	_player_combat = player.get_node("Combat") as CombatComponent
	arena.encounter_started.connect(_on_encounter_started)
	_until_attack = attack_interval


func _physics_process(delta: float) -> void:
	tick(delta)


func _exit_tree() -> void:
	Input.action_release(ACTION_BLOCK)


## Adds spawn points to `target` so that it spawns `total` enemies. Call before the arena
## enters the tree. Returns how many enemies it will spawn (capped by EXTRA_SPAWNS).
static func set_enemy_count(target: ArenaController, total: int) -> int:
	var root: Node3D = target.spawn_points[0].get_parent() as Node3D
	var extra: int = clampi(total - target.spawn_points.size(), 0, EXTRA_SPAWNS.size())
	for i: int in extra:
		var marker := Marker3D.new()
		marker.name = "BenchmarkEnemy%d" % i
		marker.position = EXTRA_SPAWNS[i]
		marker.rotation.y = PI
		root.add_child(marker)
		target.spawn_points.append(marker)
	return target.spawn_points.size()


## Keeps everyone alive and fresh, and alternates guard and light attacks.
func tick(delta: float) -> void:
	_player_health.reset()
	_player_stamina.reset()
	for enemy: EnemyController in arena.alive_enemies():
		enemy.health.reset()
		enemy.posture.reset()
	_until_attack -= delta
	if _until_attack <= 0.0 and not _player_combat.is_attacking():
		_until_attack = attack_interval
		Input.action_release(ACTION_BLOCK)
		_player_combat.request(CombatComponent.Kind.LIGHT)
	elif not _player_combat.is_attacking():
		Input.action_press(ACTION_BLOCK)


## The player starts at FIGHT_SPOT and every enemy starts looking at it, so all of them
## join the fight at once instead of depending on where each one happens to face.
func _on_encounter_started() -> void:
	arena.player.respawn(FIGHT_SPOT, 0.0)
	for enemy: EnemyController in arena.alive_enemies():
		var to_player: Vector3 = FIGHT_SPOT - enemy.global_position
		enemy.rotation.y = atan2(-to_player.x, -to_player.z)

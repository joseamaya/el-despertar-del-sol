class_name SupportAllies
extends Node3D
## The family's men at the pass (F4 task 6, DECISIONS/0012): if the player freed the
## llamas, when the pass first sees the player a few comuneros run in from behind and
## each draws one chanca away. They are chanca warriors on the player's side with their
## own data: their blows only wear posture down, so the player still finishes every
## fight. When no free chanca is left facing the player, the nearest drawn one comes back.

signal allies_arrived

const HITBOX_PATH: NodePath = ^"Visual/Model/Armature/GeneralSkeleton/RightHandSocket/Mace/Hitbox"
const BODY_PATH: NodePath = ^"Visual/Model/Armature/GeneralSkeleton/Mannequin"

@export var tuning: SupportAlliesTuning
## The warrior scene, configured as a comunero by code.
@export var ally_scene: PackedScene
@export var arena: ArenaController
@export var slice: SliceDirector
@export var level: SectorLevel

var _allies: Array[EnemyController] = []
## Chanca drawn away -> the comunero holding it, and the director it had.
var _pairs: Dictionary[EnemyController, EnemyController] = {}
var _directors: Dictionary[EnemyController, EncounterDirector] = {}
var _arrived: bool = false


func _ready() -> void:
	assert(tuning != null and ally_scene != null, "SupportAllies: tuning and scene.")
	assert(arena != null and slice != null and level != null, "SupportAllies: parts.")
	arena.encounter_started.connect(_on_encounter_started)


func _physics_process(_delta: float) -> void:
	if not _arrived:
		if _should_come():
			_arrive()
		return
	_release_if_alone()


func has_arrived() -> bool:
	return _arrived


func allies() -> Array[EnemyController]:
	return _allies


## The comunero holding `chanca` away from the player, or null.
func holder_of(chanca: EnemyController) -> EnemyController:
	return _pairs.get(chanca, null)


func _should_come() -> bool:
	return (
		tuning.count > 0
		and arena.active_zone == tuning.zone
		and arena.is_zone_engaged()
		and slice.has_flag(tuning.flag)
	)


func _arrive() -> void:
	_arrived = true
	# The one nearest the player stays theirs; the farthest ones are drawn away.
	var chancas: Array[EnemyController] = arena.alive_enemies()
	var player_at: Vector3 = arena.player.global_position
	chancas.sort_custom(
		func(a: EnemyController, b: EnemyController) -> bool:
			return a.distance_to(player_at) > b.distance_to(player_at)
	)
	for i: int in tuning.count:
		var ally: EnemyController = _spawn(i)
		if i < chancas.size() - 1:
			_pair(ally, chancas[i])
	slice.announce(tuning.notice)
	allies_arrived.emit()


func _spawn(index: int) -> EnemyController:
	var ally := ally_scene.instantiate() as EnemyController
	ally.name = "Comunero%d" % index
	var data: EnemyData = tuning.data
	ally.data = data
	(ally.get_node(^"Perception") as PerceptionComponent).data = data
	(ally.get_node(^"Guard") as EnemyGuard).data = data
	var combat := ally.get_node(^"Combat") as EnemyCombat
	combat.data = data
	combat.telegraphs = []
	(ally.get_node(^"AttackTelegraph") as Node3D).visible = false
	(ally.get_node(^"Health") as HealthComponent).tuning = data.health
	(ally.get_node(^"Hurtbox") as Hurtbox).faction = HitRules.Faction.PLAYER
	(ally.get_node(HITBOX_PATH) as Hitbox).faction = HitRules.Faction.PLAYER
	# No "!" over the player's side.
	(ally.get_node(^"AlertMarker") as Node3D).visible = false
	ally.alert_marker = null
	var body := StandardMaterial3D.new()
	body.albedo_color = tuning.body_color
	body.roughness = 0.8
	(ally.get_node(BODY_PATH) as GeometryInstance3D).material_override = body
	ally.director = null
	ally.position = _spawn_point(index)
	add_child(ally)
	# Not a lock-on target (its own _ready sets the layer).
	(ally.get_node(^"LockOnTarget") as Area3D).collision_layer = 0
	ally.health.died.connect(_on_ally_died.bind(ally))
	_allies.append(ally)
	return ally


## Behind the player along the slope (+Z in the layout is downhill), on the navmesh.
func _spawn_point(index: int) -> Vector3:
	var local: Vector3 = level.sector.to_local(arena.player.global_position)
	var side: float = (index - (tuning.count - 1) * 0.5) * tuning.spawn_spread
	var xz := Vector2(local.x + side, local.z + tuning.spawn_behind)
	var at: Vector3 = level.to_global_point(xz)
	var map: RID = get_world_3d().navigation_map
	return NavigationServer3D.map_get_closest_point(map, at) + Vector3.UP * 0.1


func _pair(ally: EnemyController, chanca: EnemyController) -> void:
	if chanca.director != null:
		chanca.director.release_token(chanca)
	_directors[chanca] = chanca.director
	_pairs[chanca] = ally
	chanca.director = null
	chanca.perception.target = ally
	chanca.perception.alert_to(ally.global_position)
	ally.perception.target = chanca
	ally.perception.alert_to(chanca.global_position)


## Sends a drawn chanca back to the player; its comunero stands down.
func _release(chanca: EnemyController) -> void:
	var ally: EnemyController = _pairs[chanca]
	var director: EncounterDirector = _directors[chanca]
	_pairs.erase(chanca)
	_directors.erase(chanca)
	if is_instance_valid(ally):
		ally.perception.target = null
	if not is_instance_valid(chanca):
		return
	chanca.director = director
	if not chanca.is_dead():
		chanca.perception.target = arena.player
		chanca.perception.alert_to(arena.player.global_position)


func _release_if_alone() -> void:
	for chanca: EnemyController in _pairs.keys():
		if not is_instance_valid(chanca) or chanca.is_dead():
			_release(chanca)
	var alive: Array[EnemyController] = arena.alive_enemies()
	if alive.is_empty() or _pairs.is_empty():
		return
	for chanca: EnemyController in alive:
		if not _pairs.has(chanca):
			return
	var player_at: Vector3 = arena.player.global_position
	var nearest: EnemyController = alive[0]
	for chanca: EnemyController in alive:
		if chanca.distance_to(player_at) < nearest.distance_to(player_at):
			nearest = chanca
	_release(nearest)


func _on_ally_died(ally: EnemyController) -> void:
	for chanca: EnemyController in _pairs.keys():
		if _pairs[chanca] == ally:
			_release(chanca)


## A zone starts or restarts after a defeat: the comuneros go, and come again when the
## pass sees the player.
func _on_encounter_started() -> void:
	for ally: EnemyController in _allies:
		if is_instance_valid(ally):
			ally.queue_free()
	_allies.clear()
	_pairs.clear()
	_directors.clear()
	_arrived = false

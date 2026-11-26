class_name SliceStaging
extends Node
## Stands the warriors of a zone idle in view while a slice step asks for it
## (SliceStep.stage_zone; F5, build 0.1.1): the opening shows the Chancas on the terraces
## before the fight. Their real spawn points are too far to read on screen, so they stand
## `distance` metres from the player towards the zone, side by side, facing the player.
## They do nothing and are gone when a step without it starts; the fight spawns its own.

@export var slice: SliceDirector
@export var level: SectorLevel
@export var player: Node3D
## The warrior scene the arena spawns.
@export var enemy_scene: PackedScene
@export_range(4.0, 40.0, 0.5, "suffix:m") var distance: float = 10.0
@export_range(0.5, 6.0, 0.1, "suffix:m") var spacing: float = 3.0
## How many stand. 0: as many as the zone fights with.
@export_range(0, 8, 1) var count: int = 4

var _staged: Array[EnemyController] = []


func _ready() -> void:
	assert(slice != null and level != null and player != null, "SliceStaging: parts.")
	assert(enemy_scene != null, "SliceStaging: warrior scene.")
	slice.step_started.connect(_on_step_started)
	slice.slice_finished.connect(clear)


func staged() -> Array[EnemyController]:
	return _staged


## Stands the warriors of `zone` (1-based) between the player and that zone.
func stage(zone: int) -> void:
	clear()
	var many: int = count
	if many == 0 and zone - 1 < level.layout.encounter_enemies.size():
		many = level.layout.encounter_enemies[zone - 1]
	var from: Vector3 = player.global_position
	var to: Vector3 = level.marker_position(StringName("Encounter%d" % zone)) - from
	to.y = 0.0
	if many == 0 or to.length_squared() < 0.01:
		return
	var forward: Vector3 = to.normalized()
	var side: Vector3 = forward.cross(Vector3.UP)
	for k: int in many:
		var offset: float = (k - (many - 1) * 0.5) * spacing
		var spot: Vector3 = from + forward * distance + side * offset
		var local: Vector3 = level.sector.to_local(spot)
		var enemy := enemy_scene.instantiate() as EnemyController
		enemy.director = null
		enemy.name = "Staged%d" % k
		# Placed before entering the tree (this node is not 3D, so it is global): a body
		# moved in its first frame sweeps the ground in its first physics query.
		enemy.position = level.to_global_point(Vector2(local.x, local.z))
		enemy.rotation.y = atan2(-forward.x, -forward.z) + PI
		add_child(enemy)
		# No target: they stand where they are.
		enemy.perception.target = null
		(enemy.get_node(^"AlertMarker") as Node3D).visible = false
		enemy.alert_marker = null
		enemy.home_position = enemy.global_position
		_staged.append(enemy)


func clear() -> void:
	for enemy: EnemyController in _staged:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_staged.clear()


func _on_step_started(step: SliceStep) -> void:
	if step.stage_zone > 0:
		if _staged.is_empty():
			stage(step.stage_zone)
	elif not _staged.is_empty():
		clear()

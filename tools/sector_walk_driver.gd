class_name SectorWalkDriver
extends Node
## Benchmark helper (F3 task 10): walks the player along a sector's whole path with the
## game camera, like a player would, and says which stretch it is in (the nearest point of
## interest), so the benchmark can report costs per stretch. Enemies are removed: the
## walk measures the scenery; fights are measured apart (ArenaFightDriver).
## Not part of the game: only tools/scene_benchmark.gd adds it (--walk).

signal finished

const ACTION_FORWARD: StringName = &"move_forward"
## Name of each stretch, by the marker it is nearest to.
const STRETCHES: Dictionary = {
	&"Start": "mirador",
	&"Encounter1": "terrazas",
	&"Huaca": "huaca",
	&"Encounter2": "casas",
	&"Encounter3": "paso",
}
const REACH: float = 1.2

@export var level: SectorLevel
@export var arena: ArenaController

var _points: PackedVector3Array = PackedVector3Array()
var _next: int = 1
var _done: bool = false


func _ready() -> void:
	assert(level != null, "SectorWalkDriver needs the level.")
	if arena != null:
		arena.encounter_started.connect(_clear_enemies)


func _physics_process(_delta: float) -> void:
	if _done:
		return
	if _points.is_empty():
		for p: Vector2 in level.layout.path:
			_points.append(level.to_global_point(p))
		level.player.respawn(_points[0] + Vector3.UP * 0.1, 0.0)
		return
	var to: Vector3 = _points[_next] - level.player.global_position
	to.y = 0.0
	if to.length() < REACH:
		_next += 1
		if _next >= _points.size():
			_done = true
			Input.action_release(ACTION_FORWARD)
			finished.emit()
			return
		to = _points[_next] - level.player.global_position
		to.y = 0.0
	level.camera_rig.yaw = atan2(-to.x, -to.z)
	Input.action_press(ACTION_FORWARD)


func _exit_tree() -> void:
	Input.action_release(ACTION_FORWARD)


func is_done() -> bool:
	return _done


## Share of the path walked (0..1), by path points reached.
func progress() -> float:
	return 0.0 if _points.is_empty() else float(_next - 1) / (_points.size() - 1)


## The stretch the player is in: the name of the nearest point of interest.
func stretch() -> String:
	var best: String = ""
	var best_d: float = INF
	var at: Vector3 = level.player.global_position
	for marker: StringName in STRETCHES.keys():
		var d: float = level.marker_position(marker).distance_to(at)
		if d < best_d:
			best_d = d
			best = STRETCHES[marker]
	return best


func _clear_enemies() -> void:
	for enemy: EnemyController in arena.alive_enemies():
		enemy.queue_free()

class_name SectorCrowd
extends Node3D
## Puts the people of a sector in it (F4 task 12c): the few who stayed in Carmenca, still
## at their doors, and a family leaving down the path as the slice begins. They are models
## with a looping clip and nothing else: no collision, no lock-on, no AI, no shadows. The
## ones who walk follow the ground along their route and, once at its end, vanish the
## first time the camera does not see them.

signal person_left(index: int)

const RAY_UP: float = 3.0
const RAY_DOWN: float = 6.0
const REACHED: float = 0.15

@export var people: SectorPeople
@export var level: SectorLevel
## The mannequin every character of the slice shares.
@export var model_scene: PackedScene

var _bodies: Array[Node3D] = []
## Per person: index of the route point they walk to (-1: not walking), seconds to wait.
var _next: PackedInt32Array = PackedInt32Array()
var _wait: PackedFloat32Array = PackedFloat32Array()


func _ready() -> void:
	assert(people != null and level != null and model_scene != null, "SectorCrowd: parts.")
	# After the level has built the sector and its collision.
	_spawn_all.call_deferred()


func _physics_process(delta: float) -> void:
	for i: int in _bodies.size():
		var body: Node3D = _bodies[i]
		if body == null or _next[i] < 0:
			continue
		if _wait[i] > 0.0:
			_wait[i] -= delta
			if _wait[i] <= 0.0:
				_play(body, people.walk_clip)
			continue
		var route: PackedVector2Array = people.people[i].route
		if _next[i] >= route.size():
			_leave_if_unseen(i)
			continue
		_walk(i, delta)


## The model of person `index`, or null once they have left.
func body(index: int) -> Node3D:
	return _bodies[index] if index < _bodies.size() else null


func count() -> int:
	return _bodies.size()


func _spawn_all() -> void:
	for i: int in people.people.size():
		var person: SectorPerson = people.people[i]
		var model := model_scene.instantiate() as Node3D
		model.name = "Person%d" % i
		model.scale = Vector3.ONE * person.scale
		add_child(model)
		if person.look != null:
			CharacterOutfit.apply(model, person.look)
		for geometry: Node in model.find_children("*", "GeometryInstance3D", true, false):
			var g := geometry as GeometryInstance3D
			g.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			g.visibility_range_end = people.draw_distance
		var walks: bool = person.route.size() >= 2
		var start: Vector2 = person.route[0] if walks else person.at
		model.global_position = _ground(level.to_global_point(start)) + Vector3.UP * person.lift
		model.global_rotation.y = level.sector.global_rotation.y + deg_to_rad(person.yaw_deg)
		_bodies.append(model)
		_next.append(1 if walks else -1)
		_wait.append(person.delay if walks else 0.0)
		if walks:
			_face(model, level.to_global_point(person.route[1]))
		_play(model, people.walk_clip if walks and person.delay <= 0.0 else person.clip)


func _walk(i: int, delta: float) -> void:
	var body: Node3D = _bodies[i]
	var route: PackedVector2Array = people.people[i].route
	var goal: Vector3 = level.to_global_point(route[_next[i]])
	var flat := Vector3(goal.x - body.global_position.x, 0.0, goal.z - body.global_position.z)
	var step: float = people.walk_speed * delta
	if flat.length() <= maxf(step, REACHED):
		_next[i] += 1
		if _next[i] >= route.size():
			_play(body, people.people[i].clip)
		else:
			_face(body, level.to_global_point(route[_next[i]]))
		return
	var at: Vector3 = body.global_position + flat.normalized() * step
	body.global_position = _ground(at)


func _leave_if_unseen(i: int) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var head: Vector3 = _bodies[i].global_position + Vector3.UP
	if camera != null and camera.is_position_in_frustum(head):
		return
	_bodies[i].queue_free()
	_bodies[i] = null
	_next[i] = -1
	person_left.emit(i)


func _face(body: Node3D, to: Vector3) -> void:
	var d: Vector3 = to - body.global_position
	# The model's front is +Z.
	body.global_rotation.y = atan2(d.x, d.z)


## The ground under `at` (stairs and ramps included), or `at` if there is none.
func _ground(at: Vector3) -> Vector3:
	var query := PhysicsRayQueryParameters3D.create(
		at + Vector3.UP * RAY_UP, at - Vector3.UP * RAY_DOWN, SectorBuilder.WORLD_LAYER
	)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return hit[&"position"] if not hit.is_empty() else at


func _play(body: Node3D, clip: StringName) -> void:
	var anim := body.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if anim == null or not anim.has_animation(clip):
		return
	anim.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	anim.play(clip)

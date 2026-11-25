class_name SectorCrowd
extends Node3D
## Puts the people of a sector in it (F4 task 12c): the few who stayed in Carmenca, still
## at their doors, and a family leaving down to the valley once Vicaquirao's training is
## over (`SectorPeople.start_zone`; before that they are not there). They are models
## with a looping clip, a body Cusi cannot walk through (F8 task 11) and nothing else: no
## lock-on, no AI, no shadows. A walker stops while Cusi stands in their way. The
## ones who walk follow the ground along their route and, once at its end, vanish the
## first time the camera does not see them. Beyond the draw distance a person is hidden
## and their animation stops, so the ones far away cost nothing. Someone with a line says
## it once, in passing, the first time they come near Cusi (F4: the family tells him what
## is happening); a subtitle shows it without stopping the game.

signal person_left(index: int)
signal person_spoke(speaker: StringName, line: StringName)

const RAY_UP: float = 3.0
const RAY_DOWN: float = 6.0
const REACHED: float = 0.15
## Seconds between checks of who is close enough to be drawn and animated.
const CULL_INTERVAL: float = 0.25
## The characters' physics layer (project.godot): the player and the warriors collide with
## it; the ground rays (world layer) do not see it.
const CHARACTER_LAYER: int = 1 << 1

@export var people: SectorPeople
@export var level: SectorLevel
## The mannequin every character of the slice shares.
@export var model_scene: PackedScene
## Optional: says when the walkers set off (`SectorPeople.start_zone`). Without it they
## set off at once.
@export var slice: SliceDirector

var _bodies: Array[Node3D] = []
## Per person: index of the route point they walk to (-1: not walking), seconds to wait.
var _next: PackedInt32Array = PackedInt32Array()
var _wait: PackedFloat32Array = PackedFloat32Array()
var _anims: Array[AnimationPlayer] = []
var _cull_left: float = 0.0
var _spoken: Array[bool] = []
## The walkers wait, hidden, until they set off.
var _held: bool = false


func _ready() -> void:
	assert(people != null and level != null and model_scene != null, "SectorCrowd: parts.")
	_held = people.start_zone > 0 and slice != null
	if _held:
		slice.step_started.connect(_on_step_started)
	# After the level has built the sector and its collision.
	_spawn_all.call_deferred()


func _physics_process(delta: float) -> void:
	_cull_left -= delta
	if _cull_left <= 0.0:
		_cull_left = CULL_INTERVAL
		_cull()
		_talk()
	for i: int in _bodies.size():
		var body: Node3D = _bodies[i]
		if body == null or _next[i] < 0 or _held:
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


## The walkers appear at the start of their routes and set off (their delays count from
## now). Public for tools and tests.
func set_off() -> void:
	_held = false
	for i: int in _bodies.size():
		if _bodies[i] != null and _walks(i):
			_play(_bodies[i], people.walk_clip if _wait[i] <= 0.0 else people.people[i].clip)
	_cull()


func is_held() -> bool:
	return _held


## Whether person `index` is close enough to be drawn and animated.
func is_active(index: int) -> bool:
	var body: Node3D = _bodies[index]
	return body != null and body.visible


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
		_add_body(model)
		_bodies.append(model)
		_anims.append(model.find_child("AnimationPlayer", true, false) as AnimationPlayer)
		_spoken.append(person.line == &"")
		_next.append(1 if walks else -1)
		_wait.append(person.delay if walks else 0.0)
		if walks:
			_face(model, level.to_global_point(person.route[1]))
		var walking: bool = walks and not _held and person.delay <= 0.0
		_play(model, people.walk_clip if walking else person.clip)
		if walks and _held:
			model.visible = false
			if _anims[i] != null:
				_anims[i].active = false


## Hides and stills whoever is beyond the draw distance from the camera.
func _cull() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return
	var eye: Vector3 = camera.global_position
	var reach: float = people.draw_distance * people.draw_distance
	for i: int in _bodies.size():
		var body: Node3D = _bodies[i]
		if body == null:
			continue
		var near: bool = body.global_position.distance_squared_to(eye) <= reach
		near = near and not (_held and _walks(i))
		body.visible = near
		if _anims[i] != null:
			_anims[i].active = near


## Whoever has a line and comes near Cusi for the first time says it.
func _talk() -> void:
	if level.player == null:
		return
	var cusi: Vector3 = level.player.global_position
	for i: int in _bodies.size():
		if _spoken[i] or _bodies[i] == null:
			continue
		if _bodies[i].global_position.distance_to(cusi) <= people.talk_radius:
			_spoken[i] = true
			var person: SectorPerson = people.people[i]
			person_spoke.emit(person.speaker, person.line)


func _walks(i: int) -> bool:
	return people.people[i].route.size() >= 2


func _on_step_started(step: SliceStep) -> void:
	if _held and step.kind == SliceStep.Kind.ENCOUNTER and step.zone == people.start_zone:
		set_off()


func _walk(i: int, delta: float) -> void:
	var body: Node3D = _bodies[i]
	var route: PackedVector2Array = people.people[i].route
	var goal: Vector3 = level.to_global_point(route[_next[i]])
	var flat := Vector3(goal.x - body.global_position.x, 0.0, goal.z - body.global_position.z)
	if _blocked(body, flat):
		_play(body, people.people[i].clip)
		return
	_play(body, people.walk_clip)
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


## Whether Cusi stands close ahead of `body`, walking along `flat`.
func _blocked(body: Node3D, flat: Vector3) -> bool:
	if level.player == null or people.yield_distance <= 0.0:
		return false
	var to: Vector3 = level.player.global_position - body.global_position
	to.y = 0.0
	return to.length() <= people.yield_distance and to.dot(flat) > 0.0


## A capsule on the characters' layer, so Cusi (and the warriors) cannot walk through.
func _add_body(model: Node3D) -> void:
	if people.body_radius <= 0.0:
		return
	var solid := AnimatableBody3D.new()
	solid.name = "Body"
	solid.collision_layer = CHARACTER_LAYER
	solid.collision_mask = 0
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = people.body_radius
	capsule.height = people.body_height
	shape.shape = capsule
	shape.position = Vector3.UP * people.body_height * 0.5
	solid.add_child(shape)
	model.add_child(solid)


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
	if anim == null or not anim.has_animation(clip) or anim.current_animation == clip:
		return
	anim.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	anim.play(clip)

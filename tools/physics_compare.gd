extends SceneTree
## Compares 3D physics engines on what this game needs: fast hit detection, character
## movement edge cases and cost. Prints one JSON line prefixed with PHYSICS_COMPARE.
## Run once per engine (override.cfg selects it) with fixed FPS so physics runs unthrottled:
##   godot --headless --path . --fixed-fps 60 -s res://tools/physics_compare.gd

const DT: float = 1.0 / 60.0
const WALK_SPEED: float = 5.0
const GRAVITY: float = 20.0
const HIT_PAIRS: int = 100
const HIT_ROUNDS: int = 10
const HURTBOX_RADIUS: float = 0.35
const HURTBOX_HEIGHT: float = 1.8
const WEAPON_HALF: float = 0.125
const HURTBOX_LAYER: int = 1 << 3

var _rng := RandomNumberGenerator.new()


func _initialize() -> void:
	_rng.seed = 1438
	_run()


func _run() -> void:
	var report: Dictionary = {"engine": ProjectSettings.get_setting("physics/3d/physics_engine")}
	for speed: float in [10.0, 20.0, 30.0, 45.0]:
		report["hits_%d" % int(speed)] = await _hit_test(speed)
	report["ramp_crest"] = await _ramp_crest()
	report["slope_40"] = await _slope_hold(40.0)
	report["slope_50"] = await _slope_hold(50.0)
	report["step_down"] = await _step_down()
	report["wall_slide"] = await _wall_slide()
	report["cost"] = await _cost()
	print("PHYSICS_COMPARE ", JSON.stringify(report))
	quit()


func _frames(count: int) -> void:
	for i: int in count:
		await physics_frame


# --- Hit detection ---------------------------------------------------------------


func _hit_test(speed: float) -> Dictionary:
	var expected: int = 0
	var detected: int = 0
	var missed: int = 0
	var false_hits: int = 0
	var late_frames: int = 0
	var tunneled: int = 0
	for round_index: int in HIT_ROUNDS:
		var world := Node3D.new()
		get_root().add_child(world)
		var weapons: Array[Area3D] = []
		var hurtboxes: Array[Area3D] = []
		var first_ideal: Array[int] = []
		var first_seen: Array[int] = []
		var swept: Array[bool] = []
		for i: int in HIT_PAIRS:
			var base := Vector3(i * 10.0, 0.0, 0.0)
			hurtboxes.append(_make_hurtbox(world, base))
			var phase: float = _rng.randf() * speed * DT  # random sampling phase
			var offset := Vector3(
				-3.0 - phase, _rng.randf_range(0.2, 1.7), _rng.randf_range(-0.6, 0.6)
			)
			weapons.append(_make_weapon(world, base + offset))
			first_ideal.append(-1)
			first_seen.append(-1)
			swept.append(_sweep_overlaps(offset, speed))
		var steps: int = int(ceil(6.0 / (speed * DT))) + 2
		for step: int in steps:
			for i: int in HIT_PAIRS:
				weapons[i].position.x += speed * DT
			await _frames(1)
			for i: int in HIT_PAIRS:
				var rel: Vector3 = weapons[i].position - hurtboxes[i].position
				if first_ideal[i] < 0 and _box_overlaps_capsule(rel):
					first_ideal[i] = step
				if first_seen[i] < 0 and weapons[i].get_overlapping_areas().has(hurtboxes[i]):
					first_seen[i] = step
		for i: int in HIT_PAIRS:
			if first_ideal[i] >= 0:
				expected += 1
				if first_seen[i] >= 0:
					detected += 1
					late_frames += maxi(0, first_seen[i] - first_ideal[i])
				else:
					missed += 1
			elif first_seen[i] >= 0:
				false_hits += 1
			elif swept[i]:
				tunneled += 1
		world.free()
	return {
		"expected": expected,
		"detected": detected,
		"missed": missed,
		"false_hits": false_hits,
		"tunneled": tunneled,
		"avg_late_frames": float(late_frames) / maxi(1, detected),
	}


func _make_hurtbox(world: Node3D, base: Vector3) -> Area3D:
	var area := Area3D.new()
	area.collision_layer = HURTBOX_LAYER
	area.collision_mask = 0
	area.monitoring = false
	var shape := CapsuleShape3D.new()
	shape.radius = HURTBOX_RADIUS
	shape.height = HURTBOX_HEIGHT
	var col := CollisionShape3D.new()
	col.shape = shape
	area.add_child(col)
	area.position = base + Vector3(0.0, HURTBOX_HEIGHT * 0.5, 0.0)
	world.add_child(area)
	return area


func _make_weapon(world: Node3D, pos: Vector3) -> Area3D:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = HURTBOX_LAYER
	area.monitorable = false
	var shape := BoxShape3D.new()
	shape.size = Vector3.ONE * WEAPON_HALF * 2.0
	var col := CollisionShape3D.new()
	col.shape = shape
	area.add_child(col)
	area.position = pos
	world.add_child(area)
	return area


## True if the weapon's continuous path (sampled finely) touches the hurtbox at all,
## i.e. a hit that per-frame overlap tests can skip at this speed ("tunneling").
func _sweep_overlaps(offset: Vector3, speed: float) -> bool:
	var rel_start := Vector3(offset.x, offset.y - HURTBOX_HEIGHT * 0.5, offset.z)
	var distance: float = 6.0 + speed * DT * 2.0
	var samples: int = int(distance / 0.01)
	for s: int in samples:
		if _box_overlaps_capsule(rel_start + Vector3(s * 0.01, 0.0, 0.0)):
			return true
	return false


## Weapon box (axis-aligned) vs vertical capsule centered at the origin of `rel`.
func _box_overlaps_capsule(rel: Vector3) -> bool:
	var half_segment: float = HURTBOX_HEIGHT * 0.5 - HURTBOX_RADIUS
	var on_axis := Vector3(0.0, clampf(rel.y, -half_segment, half_segment), 0.0)
	var to_box: Vector3 = on_axis - rel
	var clamped := Vector3(
		clampf(to_box.x, -WEAPON_HALF, WEAPON_HALF),
		clampf(to_box.y, -WEAPON_HALF, WEAPON_HALF),
		clampf(to_box.z, -WEAPON_HALF, WEAPON_HALF)
	)
	return (to_box - clamped).length() <= HURTBOX_RADIUS


# --- Character movement ----------------------------------------------------------


func _make_body(world: Node3D, pos: Vector3) -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.floor_snap_length = 0.3
	var shape := CapsuleShape3D.new()
	shape.radius = 0.35
	shape.height = 1.8
	var col := CollisionShape3D.new()
	col.shape = shape
	col.position.y = 0.9
	body.add_child(col)
	body.position = pos
	world.add_child(body)
	return body


func _make_box(world: Node3D, size: Vector3, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> void:
	var body := StaticBody3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	var col := CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)
	body.position = pos
	body.rotation_degrees = rot_deg
	world.add_child(body)


func _step_body(body: CharacterBody3D, dir: Vector3) -> void:
	body.velocity.x = dir.x * WALK_SPEED
	body.velocity.z = dir.z * WALK_SPEED
	if not body.is_on_floor():
		body.velocity.y -= GRAVITY * DT
	body.move_and_slide()


func _ramp_crest() -> Dictionary:
	var world := Node3D.new()
	get_root().add_child(world)
	_make_box(world, Vector3(40, 1, 40), Vector3(0, -0.5, 0))
	_make_box(world, Vector3(4, 0.5, 7), Vector3(0, 1.0, -7), Vector3(20, 0, 0))
	_make_box(world, Vector3(4, 2.46, 6), Vector3(0, 1.23, -13.29))
	var body := _make_body(world, Vector3(0, 0.05, -2))
	await _frames(10)
	var airborne: int = 0
	var max_up: float = 0.0
	for i: int in 150:
		_step_body(body, Vector3.FORWARD)
		await _frames(1)
		if not body.is_on_floor():
			airborne += 1
		max_up = maxf(max_up, body.velocity.y)
	var on_top: bool = body.global_position.y > 2.3
	world.free()
	return {"airborne_frames": airborne, "max_up_velocity": max_up, "reached_top": on_top}


func _slope_hold(angle_deg: float) -> Dictionary:
	var world := Node3D.new()
	get_root().add_child(world)
	_make_box(world, Vector3(10, 0.5, 10), Vector3.ZERO, Vector3(angle_deg, 0, 0))
	var body := _make_body(world, Vector3(0, 1.2, 0))
	for i: int in 30:
		_step_body(body, Vector3.ZERO)
		await _frames(1)
	var start: Vector3 = body.global_position
	for i: int in 180:
		_step_body(body, Vector3.ZERO)
		await _frames(1)
	var slid: float = minf(body.global_position.distance_to(start), 99.0)
	world.free()
	return {"slid_m": slid, "held": slid < 0.05}


func _step_down() -> Dictionary:
	var world := Node3D.new()
	get_root().add_child(world)
	_make_box(world, Vector3(40, 1, 40), Vector3(0, -0.5, 0))
	_make_box(world, Vector3(4, 0.25, 6), Vector3(0, 0.125, 0))
	var body := _make_body(world, Vector3(0, 0.3, 1.5))
	await _frames(10)
	var airborne: int = 0
	for i: int in 60:
		_step_body(body, Vector3.FORWARD)
		await _frames(1)
		if not body.is_on_floor():
			airborne += 1
	world.free()
	return {"airborne_frames": airborne}


func _wall_slide() -> Dictionary:
	var world := Node3D.new()
	get_root().add_child(world)
	_make_box(world, Vector3(40, 1, 40), Vector3(0, -0.5, 0))
	_make_box(world, Vector3(30, 2, 0.5), Vector3(0, 1, -1.0))
	var body := _make_body(world, Vector3(-10, 0.05, 1))
	await _frames(10)
	var dir := Vector3(1, 0, -1).normalized()
	for i: int in 30:
		_step_body(body, dir)
		await _frames(1)
	var x0: float = body.global_position.x
	var max_jitter_z: float = 0.0
	var z_ref: float = body.global_position.z
	for i: int in 60:
		_step_body(body, dir)
		await _frames(1)
		max_jitter_z = maxf(max_jitter_z, absf(body.global_position.z - z_ref))
	var speed_along: float = (body.global_position.x - x0) / (60.0 * DT)
	world.free()
	return {
		"speed_along_wall": speed_along,
		"ideal": WALK_SPEED * sqrt(0.5),
		"max_jitter_m": max_jitter_z
	}


# --- Cost ------------------------------------------------------------------------


func _cost() -> Dictionary:
	var world := Node3D.new()
	get_root().add_child(world)
	_make_box(world, Vector3(60, 1, 60), Vector3(0, -0.5, 0))
	for i: int in 20:
		var p := Vector3(_rng.randf_range(-25, 25), 1.0, _rng.randf_range(-25, 25))
		_make_box(world, Vector3(2, 2, 2), p)
	var bodies: Array[CharacterBody3D] = []
	var dirs: Array[Vector3] = []
	for i: int in 30:
		var p := Vector3(_rng.randf_range(-20, 20), 0.05, _rng.randf_range(-20, 20))
		bodies.append(_make_body(world, p))
		dirs.append(Vector3(_rng.randf_range(-1, 1), 0, _rng.randf_range(-1, 1)).normalized())
	await _frames(10)
	var space: PhysicsDirectSpaceState3D = world.get_world_3d().direct_space_state
	var frame_usec: PackedFloat64Array = PackedFloat64Array()
	var ray_hits: int = 0
	for frame: int in 600:
		var t0: int = Time.get_ticks_usec()
		for b: int in bodies.size():
			if frame % 90 == 0:
				dirs[b] = Vector3(_rng.randf_range(-1, 1), 0, _rng.randf_range(-1, 1)).normalized()
			_step_body(bodies[b], dirs[b])
		for r: int in 300:
			var from := Vector3(_rng.randf_range(-25, 25), 1.5, _rng.randf_range(-25, 25))
			var to: Vector3 = (
				from + Vector3(_rng.randf_range(-15, 15), -1.0, _rng.randf_range(-15, 15))
			)
			if not space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to)).is_empty():
				ray_hits += 1
		var t1: int = Time.get_ticks_usec()
		await _frames(1)
		var t2: int = Time.get_ticks_usec()
		frame_usec.append(float((t1 - t0) + (t2 - t1)))
	world.free()
	frame_usec.sort()
	var total: float = 0.0
	for v: float in frame_usec:
		total += v
	return {
		"avg_frame_ms": total / frame_usec.size() / 1000.0,
		"p95_frame_ms": frame_usec[int(frame_usec.size() * 0.95)] / 1000.0,
		"ray_hits": ray_hits,
	}

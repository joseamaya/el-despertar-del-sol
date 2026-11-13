extends GdUnitTestSuite
## Guards the combat requirement "hits are always detected" (GDD §14.4 criterion 3)
## with the fixed physics engine: a weapon Area3D crossing a hurtbox at swing speed
## must be reported by get_overlapping_areas() on the frame it overlaps.

const HURTBOX_LAYER: int = 1 << 3
const SWING_SPEED: float = 20.0
const PAIRS: int = 40


func test_physics_engine_is_fixed() -> void:
	var engine: String = ProjectSettings.get_setting("physics/3d/physics_engine")
	assert_str(engine).is_equal("GodotPhysics3D")


func test_fast_swings_through_body_are_always_detected() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1438
	var world: Node3D = auto_free(Node3D.new())
	add_child(world)
	var weapons: Array[Area3D] = []
	var hurtboxes: Array[Area3D] = []
	var seen: Array[bool] = []
	for i: int in PAIRS:
		var base := Vector3(i * 10.0, 0.0, 0.0)
		hurtboxes.append(_area(world, _capsule(), base + Vector3(0, 0.9, 0), HURTBOX_LAYER, 0))
		var start := Vector3(
			-3.0 - rng.randf() * 0.3, rng.randf_range(0.4, 1.5), rng.randf_range(-0.2, 0.2)
		)
		weapons.append(_area(world, _box(), base + start, 0, HURTBOX_LAYER))
		seen.append(false)
	var dt: float = 1.0 / Engine.physics_ticks_per_second
	for step: int in int(6.0 / (SWING_SPEED * dt)) + 2:
		for w: Area3D in weapons:
			w.position.x += SWING_SPEED * dt
		await get_tree().physics_frame
		await get_tree().physics_frame
		for i: int in PAIRS:
			if weapons[i].get_overlapping_areas().has(hurtboxes[i]):
				seen[i] = true
	assert_array(seen).not_contains([false])


func _capsule() -> Shape3D:
	var s := CapsuleShape3D.new()
	s.radius = 0.35
	s.height = 1.8
	return s


func _box() -> Shape3D:
	var s := BoxShape3D.new()
	s.size = Vector3.ONE * 0.25
	return s


func _area(world: Node3D, shape: Shape3D, pos: Vector3, layer: int, mask: int) -> Area3D:
	var area := Area3D.new()
	area.collision_layer = layer
	area.collision_mask = mask
	area.monitoring = mask != 0
	area.monitorable = layer != 0
	var col := CollisionShape3D.new()
	col.shape = shape
	area.add_child(col)
	area.position = pos
	world.add_child(area)
	return area

extends GdUnitTestSuite
## Hitbox/Hurtbox in an isolated world: tunneling, once per activation, factions.

const SPEED_FAST: float = 45.0

var _world: Node3D
var _rng := RandomNumberGenerator.new()


func before_test() -> void:
	_rng.seed = 1438
	_world = auto_free(Node3D.new())
	add_child(_world)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _hurtbox(pos: Vector3, faction: HitRules.Faction, health: HealthComponent = null) -> Hurtbox:
	var hb := Hurtbox.new()
	hb.faction = faction
	hb.health = health
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	col.shape = cap
	hb.add_child(col)
	hb.position = pos + Vector3(0, 0.9, 0)
	_world.add_child(hb)
	return hb


func _hitbox(pos: Vector3, faction: HitRules.Faction) -> Hitbox:
	var hb := Hitbox.new()
	var box := BoxShape3D.new()
	box.size = Vector3.ONE * 0.25
	hb.shape = box
	hb.faction = faction
	hb.position = pos
	_world.add_child(hb)
	return hb


func _health(max_health: float) -> HealthComponent:
	var h := HealthComponent.new()
	h.tuning = HealthTuning.new()
	h.tuning.max_health = max_health
	_world.add_child(h)
	return h


func test_fast_swings_never_tunnel() -> void:
	# The DECISIONS/0006 scenario: grazing passes (body edge) with a random sampling phase,
	# where one test per frame skips some hits. Every pass here does touch the body.
	var pairs: int = 60
	var counts: Array[int] = []
	var weapons: Array[Hitbox] = []
	for i: int in pairs:
		var base := Vector3(i * 10.0, 0, 0)
		var hurt := _hurtbox(base, HitRules.Faction.CHANCA)
		counts.append(0)
		hurt.hit_received.connect(func(_info: HitInfo) -> void: counts[i] += 1)
		var phase: float = _rng.randf() * SPEED_FAST / 60.0
		var side: float = _rng.randf_range(0.3, 0.45) * (1.0 if i % 2 == 0 else -1.0)
		var start := Vector3(-3.0 - phase, _rng.randf_range(0.5, 1.3), side)
		weapons.append(_hitbox(base + start, HitRules.Faction.PLAYER))
	await _frames(2)
	for w: Hitbox in weapons:
		w.activate(HitInfo.create(10.0))
	for step: int in 12:
		for w: Hitbox in weapons:
			w.position.x += SPEED_FAST / 60.0
		await _frames(1)
	assert_array(counts).not_contains([0])
	assert_array(counts).not_contains([2])


func test_each_hurtbox_hit_once_per_activation_and_again_after_reactivation() -> void:
	var health := _health(100.0)
	_hurtbox(Vector3.ZERO, HitRules.Faction.CHANCA, health)
	var weapon := _hitbox(Vector3(0, 1.0, 0), HitRules.Faction.PLAYER)
	await _frames(2)
	weapon.activate(HitInfo.create(10.0))
	await _frames(5)
	assert_float(health.current).is_equal(90.0)
	weapon.deactivate()
	weapon.activate(HitInfo.create(10.0))
	await _frames(2)
	assert_float(health.current).is_equal(80.0)


func test_inactive_hitbox_and_allies_do_no_damage() -> void:
	var health := _health(100.0)
	_hurtbox(Vector3.ZERO, HitRules.Faction.PLAYER, health)
	var ally := _hitbox(Vector3(0, 1.0, 0), HitRules.Faction.PLAYER)
	await _frames(3)
	assert_float(health.current).is_equal(100.0)
	ally.activate(HitInfo.create(10.0))
	await _frames(3)
	assert_float(health.current).is_equal(100.0)


func test_hit_info_carries_point_direction_and_attacker() -> void:
	var hurt := _hurtbox(Vector3.ZERO, HitRules.Faction.CHANCA)
	var received: Array[HitInfo] = []
	hurt.hit_received.connect(func(info: HitInfo) -> void: received.append(info))
	var weapon := _hitbox(Vector3(-2, 1.0, 0), HitRules.Faction.PLAYER)
	await _frames(2)
	weapon.activate(HitInfo.create(12.0, 5.0, _world))
	for i: int in 6:
		weapon.position.x += 0.6
		await _frames(1)
	assert_int(received.size()).is_equal(1)
	assert_float(received[0].damage).is_equal(12.0)
	assert_float(received[0].posture_damage).is_equal(5.0)
	assert_object(received[0].attacker).is_same(_world)
	assert_float(received[0].direction.x).is_greater(0.9)


func test_dead_hurtbox_ignores_hits() -> void:
	var health := _health(10.0)
	var hurt := _hurtbox(Vector3.ZERO, HitRules.Faction.CHANCA, health)
	var hits: Array[int] = [0]
	hurt.hit_received.connect(func(_i: HitInfo) -> void: hits[0] += 1)
	health.apply_damage(10.0)
	hurt.receive_hit(HitInfo.create(5.0))
	assert_int(hits[0]).is_equal(0)

extends GdUnitTestSuite
## Integration: the family's men at the pass (F4 task 6). They come only if the llamas
## were freed, once the pass has seen the player; each draws a different chanca away and
## the nearest stays the player's; they cannot hurt the player nor kill anyone; the
## drawn chancas come back one at a time; the zone is won on chancas alone; a defeat
## sends them away until the pass sees the player again.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const TIME_SCALE: float = 2.0
const PASS: int = 3

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _arena: ArenaController
var _slice: SliceDirector
var _allies: SupportAllies
var _player: PlayerController


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_arena = _runner.find_child("ArenaController") as ArenaController
	_slice = _runner.find_child("SliceDirector") as SliceDirector
	_allies = _runner.find_child("SupportAllies") as SupportAllies
	_player = _runner.find_child("Player") as PlayerController
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(20)
	var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
	# Past the opening, without Vicaquirao's training (F4 task 12a).
	(_runner.find_child("SliceDirector") as SliceDirector).flow.set_flag(&"skip_training")
	while talk.is_playing():
		talk.advance()
	await _frames(2)


func after_test() -> void:
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


## Starts the pass with the player at its edge and waits until it has seen them.
func _to_the_pass() -> void:
	Engine.time_scale = TIME_SCALE
	_arena.start_zone(PASS)
	var zone: Vector3 = _level.layout.encounters[PASS - 1]
	_player.respawn(_level.to_global_point(Vector2(zone.x, zone.y + 6.0)) + Vector3.UP * 0.1, 0.0)
	for i: int in 400:
		if _arena.is_zone_engaged():
			break
		await _frames(1)
	await _frames(3)


func _kill(enemy: EnemyController) -> void:
	enemy.health.apply_damage(enemy.health.get_maximum())
	await _frames(3)


func test_nobody_comes_without_the_llamas() -> void:
	await _to_the_pass()
	assert_bool(_arena.is_zone_engaged()).is_true()
	await _frames(60)
	assert_bool(_allies.has_arrived()).is_false()
	assert_array(_allies.allies()).is_empty()


func test_with_the_llamas_freed_two_come_and_each_draws_one_away() -> void:
	var notices: Array[StringName] = []
	_slice.notice_shown.connect(func(key: StringName) -> void: notices.append(key))
	_slice.flow.set_flag(&"llamas_freed")
	await _to_the_pass()
	assert_bool(_allies.has_arrived()).is_true()
	assert_array(notices).contains([&"NOTICE_ALLIES"])
	var allies: Array[EnemyController] = _allies.allies()
	assert_int(allies.size()).is_equal(2)
	var held: Array[EnemyController] = []
	var free: Array[EnemyController] = []
	for chanca: EnemyController in _arena.alive_enemies():
		var holder: EnemyController = _allies.holder_of(chanca)
		if holder == null:
			free.append(chanca)
			continue
		held.append(chanca)
		assert_object(chanca.perception.target).is_same(holder)
		assert_object(holder.perception.target).is_same(chanca)
		assert_object(chanca.director).is_null()
	assert_int(held.size()).is_equal(2)
	assert_int(free.size()).is_equal(1)
	assert_object(free[0].perception.target).is_same(_player)
	for ally: EnemyController in allies:
		assert_int((ally.get_node(^"Hurtbox") as Hurtbox).faction).is_equal(HitRules.Faction.PLAYER)
		assert_int((ally.get_node(SupportAllies.HITBOX_PATH) as Hitbox).faction).is_equal(
			HitRules.Faction.PLAYER
		)
		assert_int((ally.get_node(^"LockOnTarget") as Area3D).collision_layer).is_equal(0)
		var outfit: Node = ally.find_child(CharacterOutfit.PREFIX + "Chest", true, false)
		assert_object(outfit).override_failure_message("comunero outfit").is_not_null()
	# They go after their chancas.
	var gap: float = allies[0].distance_to(_allies.allies()[0].perception.target.global_position)
	await _frames(int(3.0 * 60.0 / TIME_SCALE))
	var now: float = allies[0].distance_to(allies[0].perception.target.global_position)
	assert_float(now).is_less(gap)


func test_comuneros_cannot_hurt_the_player_nor_kill() -> void:
	var data: EnemyData = _allies.tuning.data
	for attack: AttackData in data.attacks:
		assert_float(attack.damage).is_equal(0.0)
		assert_float(attack.posture_damage).is_greater(0.0)
	assert_bool(HitRules.can_hit(HitRules.Faction.PLAYER, HitRules.Faction.PLAYER)).is_false()
	assert_bool(HitRules.can_hit(HitRules.Faction.PLAYER, HitRules.Faction.CHANCA)).is_true()


func test_drawn_chancas_come_back_one_at_a_time_and_the_zone_is_won() -> void:
	_slice.flow.set_flag(&"llamas_freed")
	var won: Array[int] = []
	_arena.zone_won.connect(func(z: int) -> void: won.append(z))
	await _to_the_pass()
	for chanca: EnemyController in _arena.alive_enemies():
		if _allies.holder_of(chanca) == null:
			await _kill(chanca)
	var back: Array[EnemyController] = []
	var held: Array[EnemyController] = []
	for chanca: EnemyController in _arena.alive_enemies():
		if _allies.holder_of(chanca) == null:
			back.append(chanca)
		else:
			held.append(chanca)
	assert_int(back.size()).is_equal(1)
	assert_int(held.size()).is_equal(1)
	assert_object(back[0].perception.target).is_same(_player)
	assert_object(back[0].director).is_not_null()
	await _kill(back[0])
	assert_object(_allies.holder_of(held[0])).is_null()
	assert_object(held[0].perception.target).is_same(_player)
	await _kill(held[0])
	assert_array(won).is_equal([PASS])
	for ally: EnemyController in _allies.allies():
		assert_bool(ally.is_dead()).is_false()


func test_a_defeat_sends_them_away_until_the_pass_sees_the_player_again() -> void:
	_slice.flow.set_flag(&"llamas_freed")
	await _to_the_pass()
	assert_int(_allies.allies().size()).is_equal(2)
	var health := _player.get_node(^"Health") as HealthComponent
	health.apply_damage(health.get_maximum())
	await _frames(10)
	_arena.reset_encounter()
	await _frames(3)
	assert_bool(_allies.has_arrived()).is_false()
	assert_array(_allies.allies()).is_empty()
	await _to_the_pass()
	assert_int(_allies.allies().size()).is_equal(2)

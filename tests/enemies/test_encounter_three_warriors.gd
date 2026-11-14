extends GdUnitTestSuite
## Integration: three warriors on the player with the EncounterDirector (GDD §6.6).

const TEST_SCENE: String = "res://scenes/tests/enemy_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _director: EncounterDirector
var _warriors: Array[EnemyController] = []


func before_test() -> void:
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_director = _runner.find_child("EncounterDirector") as EncounterDirector
	_warriors.clear()
	var spots: Array[Vector3] = [Vector3(-8, 0.05, 1), Vector3(-11, 0.05, 6), Vector3(-5, 0.05, 6)]
	for i: int in 3:
		var w := _runner.find_child("Warrior%d" % (i + 1)) as EnemyController
		w.patrol_points.clear()
		w.global_position = spots[i]
		w.home_position = spots[i]
		_warriors.append(w)
	_player.global_position = Vector3(-8, 0.05, 4.5)
	_player.velocity = Vector3.ZERO
	(_player.get_node("Health") as HealthComponent).tuning = _immortal()
	await _frames(3)


func after_test() -> void:
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _immortal() -> HealthTuning:
	var t := HealthTuning.new()
	t.max_health = 100000.0
	return t


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_never_more_than_two_attack_at_once_and_all_take_turns() -> void:
	(_player.get_node("Health") as HealthComponent).reset()
	var attacked: Dictionary = {}
	var feints: Array[int] = [0]
	for w: EnemyController in _warriors:
		w.combat.attack_started.connect(func(_d: AttackData) -> void: attacked[w.name] = true)
		w.state_machine.state_changed.connect(
			func(_f: StringName, to: StringName) -> void: feints[0] += 1 if to == &"feint" else 0
		)
	var max_attacking: int = 0
	var min_gap: float = INF
	for frame: int in 1200:
		await get_tree().physics_frame
		var attacking: int = 0
		for w: EnemyController in _warriors:
			if w.combat.is_attacking():
				attacking += 1
		max_attacking = maxi(max_attacking, attacking)
		assert_int(_director.token_count()).is_less_equal(2)
		if frame > 240:
			for i: int in 3:
				for j: int in range(i + 1, 3):
					min_gap = minf(min_gap, _warriors[i].distance_to(_warriors[j].global_position))
	assert_int(max_attacking).is_less_equal(2)
	assert_int(attacked.size()).is_equal(3)
	assert_int(feints[0]).is_greater(0)
	assert_float(min_gap).is_greater(1.0)


func test_killing_a_token_holder_frees_its_token() -> void:
	var holder: EnemyController = null
	for frame: int in 900:
		await get_tree().physics_frame
		for w: EnemyController in _warriors:
			if _director.has_token(w):
				holder = w
		if holder != null:
			break
	assert_object(holder).is_not_null()
	holder.health.apply_damage(holder.health.get_maximum())
	await _frames(2)
	assert_bool(_director.has_token(holder)).is_false()

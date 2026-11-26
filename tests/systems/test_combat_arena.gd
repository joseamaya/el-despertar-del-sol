extends GdUnitTestSuite
## Integration: the combat arena loop (spawn, defeat, restart, victory) and its HUD.

const ARENA: String = "res://scenes/tests/combat_arena.tscn"

var _runner: GdUnitSceneRunner
var _arena: ArenaController
var _hud: Hud
var _player: PlayerController
var _health: HealthComponent


func before_test() -> void:
	TranslationServer.set_locale("es")
	_runner = scene_runner(ARENA)
	_arena = _runner.find_child("ArenaController") as ArenaController
	_hud = _runner.find_child("Hud") as Hud
	_player = _runner.find_child("Player") as PlayerController
	_health = _player.get_node("Health") as HealthComponent
	await _frames(3)


func after_test() -> void:
	Engine.time_scale = 1.0
	TranslationServer.set_locale("es")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_spawns_three_wired_warriors() -> void:
	var enemies: Array[EnemyController] = _arena.alive_enemies()
	assert_int(enemies.size()).is_equal(3)
	for enemy: EnemyController in enemies:
		assert_object(enemy.perception.target).is_same(_player)
		assert_object(enemy.director).is_same(_arena.director)


## F9 task 1: a warrior that entered the tree at the origin and was then moved made its
## first physics query sweep the ground in between (0.1–0.2 s each, a stutter in play).
func test_warriors_enter_the_tree_at_their_spawn_point() -> void:
	var at_entry: Array[Vector3] = []
	var root: Node3D = _arena.enemies_root
	var record := func(node: Node) -> void:
		if node is EnemyController:
			at_entry.append((node as EnemyController).global_position)
	root.child_entered_tree.connect(record)
	_arena.reset_encounter()
	await _frames(3)
	root.child_entered_tree.disconnect(record)
	var fresh: Array[EnemyController] = _arena.alive_enemies()
	assert_int(at_entry.size()).is_equal(fresh.size())
	for i: int in fresh.size():
		assert_float(at_entry[i].distance_to(fresh[i].home_position)).is_less(0.01)


func test_defeat_stops_the_player_and_shows_the_message() -> void:
	_health.apply_damage(_health.get_maximum())
	await _frames(2)
	assert_bool(_player.is_in_action()).is_true()
	assert_bool((_player.get_node("Combat") as Node).is_physics_processing()).is_false()
	await _frames(int(_arena.defeat_delay * 60.0) + 10)
	assert_bool(_hud.message_panel.visible).is_true()
	assert_str(_hud.message_label.text).is_equal("Has caído")
	assert_str(_hud.hint_label.text).is_equal("Pulsa R o Start para reintentar")
	for enemy: EnemyController in _arena.alive_enemies():
		assert_object(enemy.perception.target).is_null()


## F5 (build 0.1.1): after the fall the body stays down until the retry; it used to
## stand up again once the death clip ended, while the defeat message waited.
func test_the_fallen_player_stays_down_until_the_retry() -> void:
	var animator := _player.get_node("Animator") as CharacterAnimator
	_health.apply_damage(_health.get_maximum())
	# The death clip lasts 2.4 s; wait well past it.
	await _frames(240)
	assert_bool(animator.is_holding()).is_true()
	assert_bool(animator.is_attack_playing()).is_true()
	_arena.reset_encounter()
	await _frames(2)
	assert_bool(animator.is_holding()).is_false()


func test_restart_restores_player_and_spawns_fresh_warriors() -> void:
	var old: Array[EnemyController] = _arena.alive_enemies()
	old[0].health.apply_damage(30.0)
	_health.apply_damage(_health.get_maximum())
	await _frames(100)
	_arena.reset_encounter()
	await _frames(3)
	assert_float(_health.current).is_equal(_health.get_maximum())
	assert_bool(_player.is_in_action()).is_false()
	assert_bool((_player.get_node("Combat") as Node).is_physics_processing()).is_true()
	var spawn: Vector3 = _arena.player_spawn.global_position
	assert_float(_player.global_position.distance_to(spawn)).is_less(0.3)
	var fresh: Array[EnemyController] = _arena.alive_enemies()
	assert_int(fresh.size()).is_equal(3)
	for enemy: EnemyController in fresh:
		assert_bool(old.has(enemy)).is_false()
		assert_float(enemy.health.current).is_equal(enemy.health.get_maximum())
	assert_bool(_hud.message_panel.visible).is_false()


func test_killing_all_three_wins() -> void:
	var won: Array[bool] = [false]
	_arena.encounter_won.connect(func() -> void: won[0] = true)
	for enemy: EnemyController in _arena.alive_enemies():
		enemy.health.apply_damage(enemy.health.get_maximum())
	await _frames(2)
	assert_bool(won[0]).is_true()
	assert_bool(_hud.message_panel.visible).is_true()
	assert_str(_hud.message_label.text).is_equal("Victoria")


func test_hud_shows_locked_target_posture_and_reticle() -> void:
	var enemy: EnemyController = _arena.alive_enemies()[0]
	_player.global_position = enemy.global_position + Vector3(0, 0, 4)
	var rig := _runner.find_child("CameraRig") as CameraController
	rig.yaw = 0.0
	rig.snap_to_target()
	await _frames(5)
	var lock := _player.get_node("LockOn") as LockOnController
	lock.toggle_lock()
	assert_bool(lock.is_locked()).is_true()
	enemy.posture.apply(30.0)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_bool(_hud.target_panel.visible).is_true()
	assert_float(_hud.target_posture_bar.value).is_equal_approx(enemy.posture.current, 0.5)
	assert_bool(_hud.reticle.visible).is_true()


func test_hud_hides_out_of_combat_and_returns_when_spotted() -> void:
	for i: int in 420:  # physics frames: real time (hides after 3 s + fade)
		await get_tree().physics_frame
		if not _hud.is_shown():
			break
	assert_bool(_hud.is_shown()).is_false()
	var enemy: EnemyController = _arena.alive_enemies()[0]
	_player.global_position = enemy.global_position + Vector3(0, 0, 3)
	for i: int in 120:
		await get_tree().physics_frame
		if _hud.is_shown():
			break
	assert_bool(_arena.is_in_combat()).is_true()
	assert_bool(_hud.is_shown()).is_true()

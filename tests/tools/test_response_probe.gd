extends GdUnitTestSuite
## The response probe of the F6 diagnosis (tasks 6–7): with the player's response tuning,
## a dodge in an attack's windup starts, one in its strike is kept; an attack pressed
## during a dodge is kept; a dodge without enough stamina is dropped for that.

const SCENE: String = "res://scenes/tests/combat_arena.tscn"

var _player: PlayerController
var _probe: ResponseProbe


func before_test() -> void:
	var runner := scene_runner(SCENE)
	_player = runner.find_child("Player") as PlayerController
	(runner.find_child("CameraRig") as CameraController).capture_mouse = false
	for enemy: EnemyController in (
		(runner.find_child("ArenaController") as ArenaController).alive_enemies()
	):
		enemy.queue_free()
	_probe = ResponseProbe.new()
	_probe.player = _player
	_player.add_child(_probe)
	await _frames(5)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_a_dodge_in_the_windup_starts_and_in_the_strike_is_kept() -> void:
	assert_str(_probe.press_attack(CombatComponent.Kind.HEAVY)).is_equal(ResponseProbe.STARTED)
	await _frames(2)
	# F6 task 7: a dodge cuts the windup.
	assert_str(_probe.press_dodge()).is_equal(ResponseProbe.STARTED)
	await _frames(60)
	(_player.get_node(^"Stamina") as StaminaComponent).reset()
	_probe.press_attack(CombatComponent.Kind.HEAVY)
	var combat := _player.get_node(^"Combat") as CombatComponent
	for i: int in 60:
		if combat.get_phase() == AttackRules.Phase.ACTIVE:
			break
		await get_tree().physics_frame
	assert_str(_probe.press_dodge()).is_equal(ResponseProbe.BUFFERED)


func test_an_attack_during_a_dodge_is_kept() -> void:
	assert_str(_probe.press_dodge()).is_equal(ResponseProbe.STARTED)
	await _frames(2)
	assert_str(_probe.press_attack(CombatComponent.Kind.LIGHT)).is_equal(ResponseProbe.BUFFERED)


func test_a_dodge_without_stamina_is_dropped_for_it() -> void:
	var stamina := _player.get_node(^"Stamina") as StaminaComponent
	stamina.drain(stamina.current - 5.0)
	assert_str(_probe.press_dodge()).is_equal("sin_resistencia")
	_probe.queue_free()

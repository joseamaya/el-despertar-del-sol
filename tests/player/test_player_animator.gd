extends GdUnitTestSuite
## Integration tests: the animated mannequin in the greybox scene.

const TEST_SCENE: String = "res://scenes/tests/locomotion_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _animator: CharacterAnimator
var _tree: AnimationTree


func before_test() -> void:
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_animator = _player.get_node("Animator") as CharacterAnimator
	_tree = _player.get_node("AnimationTree") as AnimationTree
	_player.global_position = Vector3(0, 0.05, 8)
	_player.velocity = Vector3.ZERO
	await _frames(5)


func after_test() -> void:
	for action: StringName in [&"move_forward", &"sprint"]:
		Input.action_release(action)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_animator_is_wired_and_tree_active() -> void:
	assert_object(_animator.tuning).is_not_null()
	assert_object(_animator.body).is_same(_player)
	assert_object(_animator.animation_tree).is_same(_tree)
	assert_bool(_tree.active).is_true()
	assert_bool(_tree.has_animation(&"Jog_Fwd")).is_true()


func test_idle_blend_at_rest() -> void:
	await _frames(30)
	assert_float(_animator.get_blend()).is_less(0.05)


func test_blend_follows_run_and_sprint_speed() -> void:
	Input.action_press(&"move_forward")
	await _frames(40)
	assert_float(_animator.get_blend()).is_equal_approx(_player.tuning.run_speed, 0.1)
	Input.action_press(&"sprint")
	await _frames(40)
	assert_float(_animator.get_blend()).is_equal_approx(_player.tuning.sprint_speed, 0.1)
	var blend_param: float = _tree.get(CharacterAnimator.PARAM_BLEND)
	assert_float(blend_param).is_equal_approx(_animator.get_blend(), 0.0001)


func test_model_faces_movement_direction() -> void:
	# Mannequin forward is its +Z; after the 180° turn it must point along the player's -Z.
	var model := _player.get_node("Visual/Model") as Node3D
	var model_forward: Vector3 = model.global_basis * Vector3.BACK
	var player_forward: Vector3 = _player.global_basis * Vector3.FORWARD
	assert_float(model_forward.angle_to(player_forward)).is_less(0.01)

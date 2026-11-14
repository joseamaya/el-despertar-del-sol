extends GdUnitTestSuite
## EncounterDirector on its own: tokens, spacing between grants, recovery and separation.

var _director: EncounterDirector
var _a: Node3D
var _b: Node3D
var _c: Node3D


func before_test() -> void:
	_director = auto_free(EncounterDirector.new())
	_director.tuning = EncounterTuning.new()
	add_child(_director)
	_director.set_physics_process(false)
	_a = _member(Vector3(0, 0, 0))
	_b = _member(Vector3(1, 0, 0))
	_c = _member(Vector3(10, 0, 0))


func after_test() -> void:
	for n: Node3D in [_a, _b, _c]:
		if is_instance_valid(n):
			n.free()


func _member(pos: Vector3) -> Node3D:
	var n := Node3D.new()
	add_child(n)
	n.global_position = pos
	_director.register(n)
	return n


func _wait(seconds: float) -> void:
	_director.tick(seconds)


func test_at_most_two_tokens() -> void:
	assert_bool(_director.request_token(_a)).is_true()
	_wait(1.0)
	assert_bool(_director.request_token(_b)).is_true()
	_wait(1.0)
	assert_bool(_director.request_token(_c)).is_false()
	assert_int(_director.token_count()).is_equal(2)


func test_grants_are_spaced() -> void:
	assert_bool(_director.request_token(_a)).is_true()
	assert_bool(_director.request_token(_b)).is_false()
	_wait(_director.tuning.grant_spacing)
	assert_bool(_director.request_token(_b)).is_true()


func test_holding_counts_as_granted_and_release_frees_a_slot() -> void:
	_director.request_token(_a)
	_wait(1.0)
	_director.request_token(_b)
	assert_bool(_director.request_token(_a)).is_true()
	_director.release_token(_a)
	_wait(1.0)
	assert_bool(_director.request_token(_c)).is_true()


func test_token_of_a_member_that_leaves_is_recovered() -> void:
	_director.request_token(_a)
	_wait(1.0)
	_director.request_token(_b)
	_a.free()  # the member leaves (e.g. a dead enemy is freed)
	_wait(1.0)
	assert_int(_director.token_count()).is_equal(1)
	assert_bool(_director.request_token(_c)).is_true()


func test_separation_pushes_away_from_close_members_only() -> void:
	var push: Vector3 = _director.separation(_a)
	assert_float(push.x).is_less(0.0)  # _b is at +X, 1 m away
	assert_vector(_director.separation(_c)).is_equal(Vector3.ZERO)

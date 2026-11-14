extends GdUnitTestSuite
## Generic node-based state machine.


class Counter:
	extends State
	var entered: int = 0
	var exited: int = 0
	var next: StringName = &""

	func enter(_previous: StringName) -> void:
		entered += 1

	func exit() -> void:
		exited += 1

	func physics_update(_delta: float) -> StringName:
		return next


var _machine: StateMachine
var _a: Counter
var _b: Counter


func before_test() -> void:
	_machine = auto_free(StateMachine.new())
	_a = Counter.new()
	_a.name = "a"
	_b = Counter.new()
	_b.name = "b"
	_machine.add_child(_a)
	_machine.add_child(_b)
	_machine.initial_state = _a
	add_child(_machine)
	_machine.set_physics_process(false)


func test_starts_in_initial_state() -> void:
	assert_str(String(_machine.current_name())).is_equal("a")
	assert_int(_a.entered).is_equal(1)


func test_state_asks_for_transition() -> void:
	var changes: Array[String] = []
	_machine.state_changed.connect(
		func(f: StringName, t: StringName) -> void: changes.append("%s>%s" % [f, t])
	)
	_a.next = &"b"
	_machine.tick(0.016)
	assert_str(String(_machine.current_name())).is_equal("b")
	assert_int(_a.exited).is_equal(1)
	assert_int(_b.entered).is_equal(1)
	assert_array(changes).contains_exactly(["a>b"])


func test_transition_to_same_state_does_nothing() -> void:
	_machine.transition_to(&"a")
	assert_int(_a.entered).is_equal(1)
	assert_int(_a.exited).is_equal(0)


func test_has_state() -> void:
	assert_bool(_machine.has_state(&"b")).is_true()
	assert_bool(_machine.has_state(&"zzz")).is_false()

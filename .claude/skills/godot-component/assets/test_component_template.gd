extends GdUnitTestSuite
## Integration tests for ExampleComponent: wiring, happy path, signals.
## Time is driven with tick() so assertions are exact; physics stays off.

const FRAME: float = 1.0 / 60.0

var _component: ExampleComponent
var _depleted_count: int = 0


func before_test() -> void:
	_depleted_count = 0
	_component = auto_free(ExampleComponent.new())
	_component.tuning = ExampleTuning.new()
	add_child(_component)
	_component.set_physics_process(false)
	_component.depleted.connect(_on_depleted)


func test_starts_full() -> void:
	assert_float(_component.current).is_equal(_component.tuning.max_value)


func test_spend_emits_value_changed() -> void:
	var monitor := monitor_signals(_component)
	assert_bool(_component.try_spend(25.0)).is_true()
	await assert_signal(monitor).is_emitted("value_changed", [75.0, 100.0])


func test_depleted_is_emitted_exactly_once() -> void:
	_component.try_spend(_component.tuning.max_value)
	_component.drain(10.0)  # already empty: must not warn again
	assert_int(_depleted_count).is_equal(1)


func test_cannot_overspend() -> void:
	assert_bool(_component.try_spend(_component.tuning.max_value + 1.0)).is_false()
	assert_float(_component.current).is_equal(_component.tuning.max_value)


func test_regenerates_after_delay() -> void:
	_component.try_spend(50.0)
	_advance(_component.tuning.regen_delay)
	assert_float(_component.current).is_equal_approx(50.0, 0.001)
	_advance(1.0)
	assert_float(_component.current).is_equal_approx(50.0 + _component.tuning.regen_per_second, 0.6)


func _advance(seconds: float) -> void:
	for i: int in roundi(seconds / FRAME):
		_component.tick(FRAME)


func _on_depleted() -> void:
	_depleted_count += 1

# For physics-driven nodes (CharacterBody3D, areas), use a test scene instead:
#   var runner := scene_runner("res://scenes/tests/<scene>.tscn")
#   var node := runner.find_child("Name") as YourNode
#   Input.action_press(&"action"); for i: int in 30: await get_tree().physics_frame
# and release every pressed action in after_test().

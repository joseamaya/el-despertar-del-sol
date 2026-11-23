extends GdUnitTestSuite
## F6 task 7: when a dodge is refused for lack of stamina, the HUD blinks the stamina bar.


func test_a_dodge_refused_for_stamina_blinks_the_bar() -> void:
	var runner := scene_runner("res://scenes/tests/combat_arena.tscn")
	var hud := runner.find_child("Hud") as Hud
	var player := runner.find_child("Player") as PlayerController
	var defense := player.get_node(^"Defense") as DefenseComponent
	var stamina := player.get_node(^"Stamina") as StaminaComponent
	await get_tree().process_frame
	assert_object(hud.defense).is_same(defense)
	stamina.drain(stamina.current - 5.0)
	defense.press_dodge()
	assert_int(hud.stamina_warnings).is_equal(1)
	assert_float(hud.root.modulate.a).is_equal(1.0)
	# A refusal for another reason (already dodging) does not warn.
	stamina.reset()
	assert_bool(defense.request_dodge()).is_true()
	defense.dodge_refused.emit(&"dodging")
	assert_int(hud.stamina_warnings).is_equal(1)

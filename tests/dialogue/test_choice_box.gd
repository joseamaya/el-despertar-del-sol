extends GdUnitTestSuite
## Unit: ChoiceBox shows the options, moves the highlight within them, holds the player
## while asking and tells which one was picked.

const PLAYER: String = "res://scenes/player/player.tscn"

var _player: PlayerController
var _box: ChoiceBox


func before_test() -> void:
	_player = auto_free((load(PLAYER) as PackedScene).instantiate()) as PlayerController
	add_child(_player)
	_box = auto_free(ChoiceBox.new()) as ChoiceBox
	_box.player = _player
	_box.frozen = [_player.get_node(^"Combat")]
	add_child(_box)


func _choice() -> DialogueChoice:
	var choice := DialogueChoice.new()
	choice.speaker = &"NAME_CUSI"
	for key: StringName in [&"CHOICE_FAMILY_ACCEPT", &"CHOICE_FAMILY_DECLINE"]:
		var option := DialogueOption.new()
		option.text = key
		choice.options.append(option)
	return choice


func test_asks_moves_and_confirms() -> void:
	var picked: Array[int] = []
	_box.chosen.connect(func(i: int) -> void: picked.append(i))
	_box.ask(_choice())
	assert_bool(_box.is_asking()).is_true()
	assert_bool(_player.get_node(^"Combat").is_physics_processing()).is_false()
	assert_str(_box.option_text(0)).is_equal("› " + tr(&"CHOICE_FAMILY_ACCEPT"))
	_box.select(1)
	assert_str(_box.option_text(1)).is_equal("› " + tr(&"CHOICE_FAMILY_DECLINE"))
	assert_str(_box.option_text(0)).not_contains("›")
	_box.confirm()
	assert_bool(_box.is_asking()).is_false()
	assert_array(picked).is_equal([1])
	assert_bool(_player.get_node(^"Combat").is_physics_processing()).is_true()


func test_confirm_without_a_question_does_nothing() -> void:
	var picked: Array[int] = []
	_box.chosen.connect(func(i: int) -> void: picked.append(i))
	_box.confirm()
	assert_array(picked).is_empty()


func test_every_choice_resource_is_translated() -> void:
	var keys: Dictionary = {}
	var file := FileAccess.open("res://localization/ui.csv", FileAccess.READ)
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() >= 3:
			keys[row[0]] = row[1] != "" and row[2] != ""
	var choice := load("res://resources/dialogue/carmenca_family_choice.tres") as DialogueChoice
	for key: StringName in [choice.speaker, &"CHOICE_CONFIRM"]:
		assert_bool(keys.get(String(key), false)).override_failure_message(key).is_true()
	for option: DialogueOption in choice.options:
		(
			assert_bool(keys.get(String(option.text), false))
			. override_failure_message(option.text)
			. is_true()
		)

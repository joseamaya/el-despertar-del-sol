extends GdUnitTestSuite
## Unit: DialoguePlayer shows a conversation line by line on a DialogueBox, holds the
## player still and out of combat while it lasts, and gives control back at the end.
## Every dialogue resource uses translation keys that exist.

const PLAYER: String = "res://scenes/player/player.tscn"
const CSV: String = "res://localization/ui.csv"
const DIALOGUE_DIR: String = "res://resources/dialogue"

var _player: PlayerController
var _box: DialogueBox
var _talk: DialoguePlayer


func before_test() -> void:
	_player = auto_free((load(PLAYER) as PackedScene).instantiate()) as PlayerController
	add_child(_player)
	_box = auto_free(DialogueBox.new()) as DialogueBox
	add_child(_box)
	_talk = auto_free(DialoguePlayer.new()) as DialoguePlayer
	_talk.box = _box
	_talk.player = _player
	_talk.frozen = [_player.get_node(^"Combat"), _player.get_node(^"Defense")]
	add_child(_talk)


func _two_lines() -> DialogueScript:
	var script := DialogueScript.new()
	for key: StringName in [&"DLG_OPENING_1", &"DLG_OPENING_4"]:
		var line := DialogueLine.new()
		line.speaker = &"NAME_VICAQUIRAO"
		line.text = key
		script.lines.append(line)
	return script


func test_plays_line_by_line_and_finishes() -> void:
	var shown: Array[int] = []
	var finished: Array[bool] = [false]
	_talk.line_shown.connect(func(i: int) -> void: shown.append(i))
	_talk.dialogue_finished.connect(func() -> void: finished[0] = true)
	_talk.play(_two_lines())
	assert_bool(_box.is_showing()).is_true()
	assert_str(_box.shown_text()).is_equal(tr(&"DLG_OPENING_1"))
	_talk.advance()
	assert_str(_box.shown_text()).is_equal(tr(&"DLG_OPENING_4"))
	assert_bool(finished[0]).is_false()
	_talk.advance()
	assert_bool(finished[0]).is_true()
	assert_bool(_box.is_showing()).is_false()
	assert_bool(_talk.is_playing()).is_false()
	assert_array(shown).is_equal([0, 1])


func test_interact_moves_to_the_next_line() -> void:
	_talk.play(_two_lines())
	var press := InputEventAction.new()
	press.action = &"interact"
	press.pressed = true
	_talk._unhandled_input(press)
	assert_str(_box.shown_text()).is_equal(tr(&"DLG_OPENING_4"))


func test_player_is_held_while_talking() -> void:
	var combat: Node = _player.get_node(^"Combat")
	var defense: Node = _player.get_node(^"Defense")
	_talk.play(_two_lines())
	assert_bool(combat.is_physics_processing()).is_false()
	assert_bool(defense.is_physics_processing()).is_false()
	# Movement input is ignored: the speed cap is zero.
	Input.action_press(&"move_forward")
	for i: int in 20:
		await get_tree().physics_frame
	Input.action_release(&"move_forward")
	assert_float(_player.get_horizontal_speed()).is_equal_approx(0.0, 0.01)
	_talk.advance()
	_talk.advance()
	assert_bool(combat.is_physics_processing()).is_true()
	assert_bool(defense.is_physics_processing()).is_true()


func test_every_dialogue_key_is_translated() -> void:
	var keys: Dictionary = {}
	var file := FileAccess.open(CSV, FileAccess.READ)
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() >= 3:
			keys[row[0]] = row[1] != "" and row[2] != ""
	for name: String in DirAccess.get_files_at(DIALOGUE_DIR):
		if not name.ends_with(".tres"):
			continue
		var dialogue := load(DIALOGUE_DIR.path_join(name)) as DialogueScript
		if dialogue == null:
			continue  # a DialogueChoice: test_choice_box checks those
		for line: DialogueLine in dialogue.lines:
			for key: StringName in [line.speaker, line.text]:
				(
					assert_bool(keys.get(String(key), false))
					. override_failure_message("%s: missing key %s" % [name, key])
					. is_true()
				)

extends GdUnitTestSuite
## Unit: SliceFlow walks a SliceSequence in order, tracks the act and the checkpoint in
## force, sets flags and skips the steps whose condition does not hold (F4 task 6), and
## ends after the last step.

const CARMENCA: String = "res://resources/slice/carmenca_slice.tres"


func _step(act: SliceStep.Act, checkpoint: StringName = &"") -> SliceStep:
	var s := SliceStep.new()
	s.act = act
	s.checkpoint = checkpoint
	return s


func _sequence(steps: Array[SliceStep]) -> SliceSequence:
	var seq := SliceSequence.new()
	seq.steps = steps
	return seq


func test_walks_the_steps_in_order_and_ends() -> void:
	var a := _step(SliceStep.Act.OPENING)
	var b := _step(SliceStep.Act.COMBAT)
	var flow := SliceFlow.new(_sequence([a, b]))
	assert_object(flow.current()).is_same(a)
	assert_object(flow.advance()).is_same(b)
	assert_int(flow.act()).is_equal(SliceStep.Act.COMBAT)
	assert_bool(flow.is_finished()).is_false()
	assert_object(flow.advance()).is_null()
	assert_bool(flow.is_finished()).is_true()
	assert_object(flow.advance()).is_null()
	assert_int(flow.index()).is_equal(2)


func test_checkpoint_is_the_latest_one_started() -> void:
	var flow := (
		SliceFlow
		. new(
			_sequence(
				[
					_step(SliceStep.Act.OPENING, &"Start"),
					_step(SliceStep.Act.EXPLORATION),
					_step(SliceStep.Act.COMBAT, &"Checkpoint1"),
				]
			)
		)
	)
	assert_str(flow.checkpoint()).is_equal("Start")
	flow.advance()
	assert_str(flow.checkpoint()).is_equal("Start")
	flow.advance()
	assert_str(flow.checkpoint()).is_equal("Checkpoint1")
	flow.advance()
	assert_str(flow.checkpoint()).is_equal("Checkpoint1")


func _conditional(only_if: StringName, unless: StringName, flag: StringName = &"") -> SliceStep:
	var s := _step(SliceStep.Act.SUPPORT)
	s.only_if = only_if
	s.unless = unless
	s.flag = flag
	return s


func test_flags_choose_which_steps_play() -> void:
	var ask := _step(SliceStep.Act.SUPPORT)
	var yes := _conditional(&"help", &"", &"done")
	var no := _conditional(&"", &"help")
	var after := _conditional(&"done", &"")
	var end := _step(SliceStep.Act.ENDING)
	var steps: Array[SliceStep] = [ask, yes, no, after, end]
	var helped := SliceFlow.new(_sequence(steps))
	assert_object(helped.advance(&"help")).is_same(yes)
	assert_bool(helped.has_flag(&"help")).is_true()
	assert_object(helped.advance()).is_same(after)
	assert_bool(helped.has_flag(&"done")).is_true()
	assert_object(helped.advance()).is_same(end)
	var passed := SliceFlow.new(_sequence(steps))
	assert_object(passed.advance()).is_same(no)
	assert_object(passed.advance()).is_same(end)
	assert_bool(passed.has_flag(&"help")).is_false()
	assert_bool(passed.has_flag(&"done")).is_false()


func test_optional_steps_can_be_left_undone() -> void:
	var start := _step(SliceStep.Act.OPENING)
	var offer := _conditional(&"", &"", &"offered")
	offer.optional = true
	var vision := _conditional(&"", &"", &"seen")
	vision.optional = true
	var family := _step(SliceStep.Act.SUPPORT)
	var flow := SliceFlow.new(_sequence([start, offer, vision, family]))
	assert_object(flow.next_required()).is_null()
	flow.advance()
	assert_object(flow.next_required()).is_same(family)
	assert_object(flow.skip_optional()).is_same(family)
	assert_bool(flow.has_flag(&"offered")).is_false()
	assert_bool(flow.has_flag(&"seen")).is_false()
	assert_object(flow.skip_optional()).is_same(family)


func test_skipped_steps_neither_start_nor_set_a_checkpoint() -> void:
	var skipped := _conditional(&"never", &"")
	skipped.checkpoint = &"Nowhere"
	var flow := SliceFlow.new(
		_sequence([skipped, _step(SliceStep.Act.COMBAT, &"Checkpoint1"), skipped])
	)
	assert_int(flow.index()).is_equal(1)
	assert_str(flow.checkpoint()).is_equal("Checkpoint1")
	assert_object(flow.advance()).is_null()
	assert_bool(flow.is_finished()).is_true()
	assert_str(flow.checkpoint()).is_equal("Checkpoint1")


func test_empty_sequence_is_finished() -> void:
	var flow := SliceFlow.new(_sequence([]))
	assert_bool(flow.is_finished()).is_true()
	assert_object(flow.current()).is_null()
	assert_str(flow.checkpoint()).is_equal("")


## The Carmenca slice follows the acts of GDD §14.1 in order and fights every zone once.
func test_carmenca_slice_visits_every_act_and_zone() -> void:
	var seq := load(CARMENCA) as SliceSequence
	var acts: Array[int] = []
	var zones: Array[int] = []
	for s: SliceStep in seq.steps:
		if acts.is_empty() or acts[-1] != s.act:
			acts.append(s.act)
		if s.kind == SliceStep.Kind.ENCOUNTER:
			zones.append(s.zone)
	assert_array(acts).is_equal([0, 1, 2, 3, 4])
	assert_array(zones).is_equal([1, 2, 3])
	assert_str(seq.steps[0].checkpoint).is_equal("Start")
	# Three opening shots (F5, build 0.1.1), then Vicaquirao speaks (F4 task 3).
	for i: int in 3:
		assert_int(seq.steps[i].kind).is_equal(SliceStep.Kind.WAIT)
		assert_str(String(seq.steps[i].caption)).is_not_empty()
	assert_int(seq.steps[3].kind).is_equal(SliceStep.Kind.DIALOGUE)
	assert_object(seq.steps[3].dialogue).is_not_null()


## Places with nothing to see yet (the family, the ending) must trigger from the path
## itself, or the slice stalls for a player who does not know where they are.
func test_carmenca_unmarked_places_are_reached_from_the_path() -> void:
	var seq := load(CARMENCA) as SliceSequence
	var layout := load("res://resources/levels/carmenca_layout.tres") as SectorLayout
	var places: Dictionary = {&"Family": layout.family, &"Ending": layout.ending}
	for s: SliceStep in seq.steps:
		if places.has(s.marker):
			assert_float(layout.distance_to_path(places[s.marker])).is_less(s.radius)


## Every condition of the Carmenca slice reads a flag that an earlier step or choice sets,
## and the Apoyo choice can set it (F4 task 6).
func test_carmenca_conditions_read_flags_set_earlier() -> void:
	var seq := load(CARMENCA) as SliceSequence
	# skip_training comes from the training choice, or from outside (tests); skip_intro
	# from the skip button.
	var set_so_far: Array[StringName] = [&"skip_training", &"skip_intro"]
	var choices: int = 0
	for s: SliceStep in seq.steps:
		for flag: StringName in [s.only_if, s.unless]:
			if flag != &"":
				assert_array(set_so_far).override_failure_message(flag).contains([flag])
		if s.flag != &"":
			set_so_far.append(s.flag)
		if s.kind == SliceStep.Kind.CHOICE:
			choices += 1
			assert_int(s.choice.options.size()).is_greater_equal(2)
			for option: DialogueOption in s.choice.options:
				if option.flag != &"":
					set_so_far.append(option.flag)
	# The training offer (F5, build 0.1.1) and the Apoyo.
	assert_int(choices).is_equal(2)
	# The huaca can be passed by; nothing else can.
	var optional: Array[StringName] = []
	for s: SliceStep in seq.steps:
		if s.optional:
			optional.append(s.marker)
	assert_array(optional).is_equal([&"Huaca", &"Huaca", &""])
	assert_array(set_so_far).contains([&"help_family", &"llamas_freed"])


## Every step where the player acts has an objective, translated; fights count warriors.
func test_carmenca_objectives_are_set_and_translated() -> void:
	var keys: Dictionary = {}
	var file := FileAccess.open("res://localization/ui.csv", FileAccess.READ)
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() >= 3:
			keys[row[0]] = row[1] != "" and row[2] != ""
	var quiet: Array[SliceStep.Kind] = [
		SliceStep.Kind.DIALOGUE, SliceStep.Kind.CHOICE, SliceStep.Kind.RITE, SliceStep.Kind.WAIT
	]
	for s: SliceStep in (load(CARMENCA) as SliceSequence).steps:
		if s.kind in quiet:
			assert_str(s.objective).is_empty()
			continue
		(
			assert_bool(keys.get(String(s.objective), false))
			. override_failure_message("Step %s %s" % [s.kind, s.objective])
			. is_true()
		)
		if s.kind == SliceStep.Kind.ENCOUNTER:
			assert_str(tr(s.objective)).contains("{count}")


## The slice ends looking at Cusco (F4 task 7): the last steps, after reaching the top of
## the pass, turn the view there.
func test_carmenca_ends_looking_at_cusco() -> void:
	var steps: Array[SliceStep] = (load(CARMENCA) as SliceSequence).steps
	var reach: int = -1
	for i: int in steps.size():
		if steps[i].marker == &"Ending":
			reach = i
	assert_int(reach).is_greater(0)
	assert_int(steps.size() - 1 - reach).is_equal(2)
	for i: int in range(reach + 1, steps.size()):
		assert_str(steps[i].look_at).is_equal("CuscoView")
		assert_int(steps[i].act).is_equal(SliceStep.Act.ENDING)
	assert_int(steps[-1].kind).is_equal(SliceStep.Kind.WAIT)


## The opening is skipped by setting its flag mid-way (F5, build 0.1.1).
func test_skip_with_leaves_the_steps_it_turns_off() -> void:
	var seq := SliceSequence.new()
	for unless: StringName in [&"skip_intro", &"skip_intro", &""]:
		var step := SliceStep.new()
		step.unless = unless
		seq.steps.append(step)
	var flow := SliceFlow.new(seq)
	assert_int(flow.index()).is_equal(0)
	assert_object(flow.skip_with(&"skip_intro")).is_same(seq.steps[2])
	assert_int(flow.index()).is_equal(2)


## F8 task 5: a saved game puts the flow back at its step, flags and checkpoint.
func test_restore_puts_the_flow_back() -> void:
	var steps: Array[SliceStep] = [
		_step(SliceStep.Act.OPENING, &"Start"),
		_step(SliceStep.Act.EXPLORATION),
		_step(SliceStep.Act.COMBAT, &"Checkpoint2"),
		_step(SliceStep.Act.ENDING),
	]
	var flow := SliceFlow.new(_sequence(steps))
	flow.restore(3, [&"llamas_freed"] as Array[StringName], &"Checkpoint2")
	assert_int(flow.index()).is_equal(3)
	assert_bool(flow.has_flag(&"llamas_freed")).is_true()
	assert_str(String(flow.checkpoint())).is_equal("Checkpoint2")
	assert_array(flow.flags()).contains_exactly([&"llamas_freed"])
	flow.restore(99, [] as Array[StringName], &"")
	assert_bool(flow.is_finished()).is_true()

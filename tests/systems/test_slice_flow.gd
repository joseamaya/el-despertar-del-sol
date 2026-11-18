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
	# Vicaquirao opens the slice (F4 task 3).
	assert_int(seq.steps[0].kind).is_equal(SliceStep.Kind.DIALOGUE)
	assert_object(seq.steps[0].dialogue).is_not_null()


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
	var set_so_far: Array[StringName] = []
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
	assert_int(choices).is_equal(1)
	assert_array(set_so_far).contains([&"help_family", &"llamas_freed"])

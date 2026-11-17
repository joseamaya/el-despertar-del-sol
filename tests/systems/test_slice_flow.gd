extends GdUnitTestSuite
## Unit: SliceFlow walks a SliceSequence in order, tracks the act and the checkpoint in
## force, and ends after the last step.

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

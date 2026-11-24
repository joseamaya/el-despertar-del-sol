extends GdUnitTestSuite
## SupportLedger (F8 task 6, GDD §8.2): points move an ayllu from Neutral to Sympathizer
## to Ally, a mission gives its points only with its support flag, the show of force
## raises every ayllu already won, and the Apoyo round-trips through a dictionary.

const CHAPTER: String = "res://resources/chapters/capitulo_1.tres"


func _ledger() -> SupportLedger:
	return SupportLedger.new((load(CHAPTER) as ChapterData).support)


func test_points_move_the_level() -> void:
	var s := _ledger()
	var raised: Array[SupportLedger.Level] = []
	s.level_raised.connect(func(_id: StringName, l: SupportLedger.Level) -> void: raised.append(l))
	assert_int(s.level(&"ayllu_a")).is_equal(SupportLedger.Level.NEUTRAL)
	s.gain(&"ayllu_a")
	assert_int(s.level(&"ayllu_a")).is_equal(SupportLedger.Level.SYMPATHIZER)
	s.gain(&"ayllu_a")
	assert_int(s.level(&"ayllu_a")).is_equal(SupportLedger.Level.ALLY)
	s.gain(&"ayllu_a")
	assert_array(raised).contains_exactly(
		[SupportLedger.Level.SYMPATHIZER, SupportLedger.Level.ALLY]
	)
	assert_int(s.total()).is_equal(3)


func test_unknown_ayllus_and_zero_gains_do_nothing() -> void:
	var s := _ledger()
	s.gain(&"nowhere")
	s.gain(&"ayllu_a", 0)
	assert_int(s.total()).is_equal(0)


func test_carmenca_needs_the_llamas() -> void:
	var c := load(CHAPTER) as ChapterData
	var s := SupportLedger.new(c.support)
	assert_array(s.apply_mission(c.mission(&"carmenca"), [])).is_empty()
	(
		assert_array(
			s.apply_mission(c.mission(&"carmenca"), [&"llamas_freed"] as Array[StringName])
		)
		. contains_exactly([&"ayllu_carmenca"])
	)
	assert_int(s.level(&"ayllu_carmenca")).is_equal(SupportLedger.Level.SYMPATHIZER)


func test_show_of_force_raises_every_ayllu_won() -> void:
	var c := load(CHAPTER) as ChapterData
	var s := SupportLedger.new(c.support)
	s.gain(&"ayllu_a")
	s.gain(&"ayllu_b")
	var raised: Array[StringName] = s.apply_mission(c.mission(&"combate_visible"), [])
	assert_array(raised).contains_exactly_in_any_order([&"ayllu_a", &"ayllu_b"])
	assert_int(s.level(&"ayllu_a")).is_equal(SupportLedger.Level.ALLY)
	assert_int(s.level(&"curaca_c")).is_equal(SupportLedger.Level.NEUTRAL)


func test_round_trips_through_a_dictionary() -> void:
	var s := _ledger()
	s.gain(&"ayllu_b", 2)
	var copy := _ledger()
	copy.from_dict(s.to_dict())
	assert_int(copy.points(&"ayllu_b")).is_equal(2)
	copy.from_dict({"ghost": 5, "ayllu_a": -3})
	assert_int(copy.total()).is_equal(0)


func test_summary_names_the_ayllus_won() -> void:
	var s := _ledger()
	s.gain(&"ayllu_carmenca")
	var text: String = SupportText.summary(s)
	assert_str(text).contains(tr(&"AYLLU_CARMENCA"))
	assert_str(text).contains(tr(&"SUPPORT_SYMPATHIZER"))
	assert_str(text).not_contains(tr(&"AYLLU_A"))
	assert_bool(text.contains("PAUSE_")).is_false()

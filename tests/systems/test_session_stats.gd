extends GdUnitTestSuite
## Unit: the playthrough summary of the external test (F5 task 3). Times per act add up to
## the total, defeats go to their zone, choices read as words, and every line is
## translated (no keys left).

const ACTS: Array[StringName] = [
	&"SUMMARY_ACT_OPENING",
	&"SUMMARY_ACT_EXPLORATION",
	&"SUMMARY_ACT_SUPPORT",
	&"SUMMARY_ACT_COMBAT",
	&"SUMMARY_ACT_ENDING",
]
const ZONES: Array[StringName] = [
	&"SUMMARY_ZONE_TERRACES", &"SUMMARY_ZONE_HOUSES", &"SUMMARY_ZONE_PASS"
]


func before() -> void:
	TranslationServer.set_locale("es")


func test_clock_reads_minutes_and_seconds() -> void:
	assert_str(SessionStats.clock(0.0)).is_equal("0:00")
	assert_str(SessionStats.clock(65.4)).is_equal("1:05")
	assert_str(SessionStats.clock(602.0)).is_equal("10:02")


func test_acts_add_up_and_defeats_go_to_their_zone() -> void:
	var stats := SessionStats.new()
	stats.add_act_time(0, 130.0)
	stats.add_act_time(3, 200.0)
	stats.add_act_time(3, 20.0)
	stats.add_act_time(9, 50.0)
	stats.add_defeat(3)
	stats.add_defeat(3)
	stats.add_defeat(1)
	stats.add_defeat(0)
	assert_float(stats.total_seconds()).is_equal_approx(350.0, 0.01)
	assert_array(Array(stats.defeats)).is_equal([1, 0, 2])


func test_text_is_translated_and_complete() -> void:
	var stats := SessionStats.new()
	stats.add_act_time(0, 130.0)
	stats.add_act_time(4, 37.0)
	stats.add_defeat(3)
	stats.helped_ayllu = true
	stats.made_offering = true
	stats.used_gamepad = false
	var text: String = stats.render("0.1-slice", ACTS, ZONES)
	assert_int(text.split("\n").size()).is_equal(4)
	assert_str(text).contains("0.1-slice").contains("2:47").contains("2:10")
	assert_str(text).contains("paso 1").contains("terrazas 0")
	assert_str(text).contains("ayudó").contains("Mando: no")
	assert_bool(text.contains("SUMMARY_")).is_false()
	assert_str(text).contains("apertura 2:10")

extends GdUnitTestSuite
## Unit: where the stone figures of the huaca vision stand (pure, no scene).

const LAYOUT: String = "res://resources/levels/carmenca_layout.tres"
const TUNING: String = "res://resources/tuning/huaca_rite.tres"


func test_figures_stand_in_an_arc_downhill_of_the_huaca() -> void:
	var layout := load(LAYOUT) as SectorLayout
	var t := load(TUNING) as HuacaRiteTuning
	var places: PackedVector2Array = HuacaRite.figure_places(layout, t)
	assert_int(places.size()).is_equal(t.figures)
	for p: Vector2 in places:
		var d: float = p.distance_to(layout.huaca)
		assert_float(d).is_between(t.distance_min - 0.01, t.distance_max + 0.01)
		# Downhill (+Z), over the terraces, and inside the walkable corridor.
		assert_float(p.y).is_greater(layout.huaca.y)
		assert_float(absf(p.x)).is_less(layout.corridor_half_width(p.y))


func test_figure_places_are_deterministic() -> void:
	var layout := load(LAYOUT) as SectorLayout
	var t := load(TUNING) as HuacaRiteTuning
	assert_array(HuacaRite.figure_places(layout, t)).is_equal(HuacaRite.figure_places(layout, t))

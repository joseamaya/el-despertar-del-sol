extends GdUnitTestSuite
## Every house of every sector layout stands on the walkable corridor, not on the steep
## sides, which rise from |x| = the corridor half width (SectorLayout.height_at). F8 task
## 11: the prologue's houses floated, tilted, on the slopes.

const LAYOUTS: Array[String] = [
	"res://resources/levels/carmenca_layout.tres",
	"res://resources/levels/prologo_layout.tres",
	"res://resources/levels/centro_layout.tres",
]
## Half of the house's longest side (4.5 m) plus a margin.
const HOUSE_REACH: float = 2.5


func test_houses_stand_inside_the_corridor() -> void:
	for path: String in LAYOUTS:
		var layout := load(path) as SectorLayout
		for h: Vector3 in layout.houses:
			var room: float = layout.corridor_half_width(h.y)
			(
				assert_float(absf(h.x) + HOUSE_REACH)
				. override_failure_message("%s: house at (%.0f, %.0f)" % [path, h.x, h.y])
				. is_less_equal(room)
			)

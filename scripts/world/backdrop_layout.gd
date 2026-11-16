class_name BackdropLayout
extends Resource
## What lies beyond a sector (F3 task 6), in the sector's local frame (+Z downhill): the
## valley floor with its fields, the town in it, the hills and apus around and the smoke
## columns on the horizon. Generic silhouettes: no named apu (licence of the game).

## Valley floor height and how far the slope below the sector takes to reach it.
@export_range(-1000.0, 0.0, 1.0, "suffix:m") var floor_height: float = -110.0
@export var slope_start_z: float = 170.0
@export var slope_end_z: float = 420.0
## Size of the valley ground mesh (x, z) and its cell size.
@export var size: Vector2 = Vector2(5200, 5200)
@export_range(10.0, 200.0, 1.0, "suffix:m") var cell: float = 40.0
## Distance from the town centre where the surrounding hills start to rise, and their
## grade and maximum height above the floor.
@export_range(100.0, 4000.0, 10.0, "suffix:m") var hills_start: float = 1300.0
@export_range(0.0, 1.0, 0.01) var hills_grade: float = 0.22
@export_range(0.0, 1500.0, 10.0, "suffix:m") var hills_max: float = 380.0
## Size of the field plots in the valley floor.
@export_range(10.0, 400.0, 1.0, "suffix:m") var plot: float = 80.0

## The town: centre (x, z), radius, neighbourhoods and houses in total.
@export var town_centre: Vector2 = Vector2(80, 900)
@export_range(50.0, 1000.0, 5.0, "suffix:m") var town_radius: float = 330.0
@export_range(1, 20, 1) var neighbourhoods: int = 7
@export_range(0, 2000, 1) var houses: int = 320

## Apus: (direction in degrees from local -Z towards +X, distance, base radius, height).
@export var apus: PackedVector4Array = PackedVector4Array()
## Smoke columns: (x, z, height). Base at the ground below them.
@export var smoke: PackedVector3Array = PackedVector3Array()

## Aerial perspective baked into far colours (no fog on the backdrop): share of the fog
## colour per metre, as 1 - exp(-distance * haze).
@export_range(0.0, 0.01, 0.00005) var haze: float = 0.00045
## Camera far plane needed to see the whole backdrop.
@export_range(1000.0, 20000.0, 100.0, "suffix:m") var view_distance: float = 7000.0
@export var seed: int = 11


## Height of the open valley at a local point: the floor plus the hills around the town.
## Near the sector the builder blends it with the sector's own ground.
func valley_at(x: float, z: float) -> float:
	var r: float = Vector2(x, z).distance_to(town_centre)
	var hills: float = clampf((r - hills_start) * hills_grade, 0.0, hills_max)
	var ripple: float = sin(x * 0.004 + seed) * cos(z * 0.0035) * 12.0
	return floor_height + hills + ripple * smoothstep(hills_start * 0.5, hills_start, r)

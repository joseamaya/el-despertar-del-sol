class_name ObjectiveMarkerTuning
extends Resource
## How the objective marker looks (F6 task 8: players did not know where to go).

## A mark over the place, held at the screen edge, pointing the way, when it is out of
## view (chosen over a compass bar by the developer).
## Closer than this, the marker fades out: the player is there.
@export_range(0.0, 30.0, 0.5, "suffix:m") var hide_within: float = 6.0
## Over this distance it fades in.
@export_range(0.1, 10.0, 0.1, "suffix:m") var fade_span: float = 3.0
## Height of the mark above the place.
@export_range(0.0, 5.0, 0.1, "suffix:m") var lift: float = 2.2
@export_range(4.0, 64.0, 1.0, "suffix:px") var size: float = 20.0
@export var color: Color = Color(0.98, 0.8, 0.35)

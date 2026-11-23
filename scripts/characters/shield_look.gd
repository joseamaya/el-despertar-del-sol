class_name ShieldLook
extends Resource
## How a shield looks and sits on the forearm (F6 task 4). The Inca Garcilaso calls the
## Inca shields huallcanca, «rodelas o paveses» (HISTORICAL_REFERENCES.md); the shape,
## colours and pattern here are a licence of the game until checked against Guaman Poma.

enum Shape { ROUND, RECT }

@export var shape: Shape = Shape.ROUND
## ROUND: diameter. RECT: width.
@export_range(0.1, 1.5, 0.01, "suffix:m") var width: float = 0.5
## RECT only.
@export_range(0.1, 1.5, 0.01, "suffix:m") var height: float = 0.62
@export_range(0.005, 0.1, 0.005, "suffix:m") var thickness: float = 0.03
## Rim width, around the face.
@export_range(0.0, 0.1, 0.005, "suffix:m") var rim: float = 0.03
## Cloth hanging from the lower edge (0: none).
@export_range(0.0, 0.6, 0.01, "suffix:m") var fringe_length: float = 0.0

@export_group("Colores")
@export var face_color: Color = Color(0.82, 0.72, 0.5)
@export var rim_color: Color = Color(0.32, 0.2, 0.12)
@export var motif_color: Color = Color(0.62, 0.12, 0.1)
@export var motif_dark: Color = Color(0.1, 0.08, 0.07)
@export var fringe_color: Color = Color(0.62, 0.12, 0.1)

@export_group("Sujeción al antebrazo")
@export var mount_position: Vector3 = Vector3.ZERO
@export var mount_rotation_deg: Vector3 = Vector3.ZERO

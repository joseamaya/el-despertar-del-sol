class_name Shield
extends Node3D
## A shield built from simple shapes, like the champi (F6 task 4): a board with a rim, a
## band of small squares across the face and, if set, a cloth hanging below. Its face
## looks along local +Z. Placed on the forearm by `look.mount_*`.

const MOTIF_SQUARES: int = 4

@export var look: ShieldLook


func _ready() -> void:
	assert(look != null, "Shield needs a ShieldLook.")
	rebuild()


## Builds the meshes again from `look` (after changing it).
func rebuild() -> void:
	for child: Node in get_children():
		child.free()
	position = look.mount_position
	rotation_degrees = look.mount_rotation_deg
	var half_h: float = (look.width if look.shape == ShieldLook.Shape.ROUND else look.height) * 0.5
	_part("Rim", _board(0.0), look.rim_color, Vector3(0, 0, -look.thickness * 0.5))
	_part("Face", _board(look.rim), look.face_color, Vector3.ZERO)
	var square: float = (look.width - look.rim * 2.0) / (MOTIF_SQUARES + 2)
	for i: int in MOTIF_SQUARES:
		var box := BoxMesh.new()
		box.size = Vector3(square * 0.9, square * 0.9, 0.004)
		var x: float = (i - (MOTIF_SQUARES - 1) * 0.5) * square
		var colour: Color = look.motif_color if i % 2 == 0 else look.motif_dark
		_part("Motif%d" % i, box, colour, Vector3(x, 0, look.thickness * 0.5 + 0.002))
	if look.fringe_length > 0.0:
		var cloth := BoxMesh.new()
		cloth.size = Vector3(look.width * 0.85, look.fringe_length, 0.006)
		_part("Fringe", cloth, look.fringe_color, Vector3(0, -half_h - look.fringe_length * 0.5, 0))


## Centre of the face, where a blocked blow is shown.
func face_point() -> Vector3:
	return global_transform * Vector3(0, 0, look.thickness)


## The board shape, shrunk by `inset` on every side (the face inside the rim).
func _board(inset: float) -> Mesh:
	if look.shape == ShieldLook.Shape.ROUND:
		var disc := CylinderMesh.new()
		disc.top_radius = look.width * 0.5 - inset
		disc.bottom_radius = disc.top_radius
		disc.height = look.thickness
		disc.radial_segments = 24
		return disc
	var board := BoxMesh.new()
	board.size = Vector3(look.width - inset * 2.0, look.height - inset * 2.0, look.thickness)
	return board


func _part(part_name: String, mesh: Mesh, colour: Color, at: Vector3) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = 0.9
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.material_override = material
	part.position = at
	# A cylinder stands along Y: lay the round board flat on the shield's XY plane.
	if mesh is CylinderMesh:
		part.rotation_degrees = Vector3(90, 0, 0)
	add_child(part)

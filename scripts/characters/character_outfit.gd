class_name CharacterOutfit
extends Node
## Dresses a UAL mannequin model with a CharacterLook (F4 task 10): tints its body and
## joint surfaces and hangs the look's pieces from their bones. Static `apply` is also
## used by code that builds characters (the comuneros at the pass).

const SKELETON: String = "GeneralSkeleton"
const BODY: String = "Mannequin"
const PREFIX: String = "Outfit_"

@export var look: CharacterLook
## The imported model (the node holding the skeleton).
@export var model: Node3D


func _ready() -> void:
	assert(look != null and model != null, "CharacterOutfit: look and model.")
	apply(model, look)


## Dresses `model`; dressing again replaces the previous outfit.
static func apply(model: Node3D, look: CharacterLook) -> void:
	var skeleton := model.find_child(SKELETON, true, false) as Skeleton3D
	assert(skeleton != null, "CharacterOutfit: no skeleton in %s." % model.name)
	var body := skeleton.find_child(BODY, false, false) as MeshInstance3D
	if body != null:
		body.set_surface_override_material(0, _material(look.skin))
		body.set_surface_override_material(1, _material(look.joints))
	for child: Node in skeleton.get_children():
		if child.name.begins_with(PREFIX):
			skeleton.remove_child(child)
			child.queue_free()
	var by_bone: Dictionary[StringName, BoneAttachment3D] = {}
	for part: LookPart in look.parts:
		if not by_bone.has(part.bone):
			var socket := BoneAttachment3D.new()
			socket.name = PREFIX + String(part.bone)
			socket.bone_name = part.bone
			skeleton.add_child(socket)
			by_bone[part.bone] = socket
		var piece := MeshInstance3D.new()
		piece.name = part.name if part.name != "" else "Piece"
		piece.mesh = mesh_for(part)
		piece.material_override = _material(part.color)
		piece.position = part.offset
		piece.rotation_degrees = part.rotation_deg
		by_bone[part.bone].add_child(piece)


## The mesh of a piece. Pure.
static func mesh_for(part: LookPart) -> Mesh:
	match part.shape:
		LookPart.Shape.CYLINDER, LookPart.Shape.DISC:
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = part.size.x
			cylinder.bottom_radius = part.size.x
			cylinder.height = part.size.y
			cylinder.radial_segments = 12 if part.shape == LookPart.Shape.DISC else 10
			cylinder.rings = 1
			return cylinder
		LookPart.Shape.RING:
			var ring := TorusMesh.new()
			ring.inner_radius = part.size.x
			ring.outer_radius = part.size.y
			ring.rings = 16
			ring.ring_segments = 6
			return ring
	var box := BoxMesh.new()
	box.size = part.size
	return box


static func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	return mat

class_name CharacterOutfit
extends Node
## Dresses a UAL mannequin model with a CharacterLook (F4 task 10): tints its body and
## joint surfaces and hangs the look's pieces from their bones, all in one skinned mesh.
## Static `apply` is also used by code that builds characters (the comuneros at the pass).

const SKELETON: String = "GeneralSkeleton"
const BODY: String = "Mannequin"
const PREFIX: String = "Outfit_"
## The node holding all the pieces.
const PIECES: String = PREFIX + "Pieces"

@export var look: CharacterLook
## The imported model (the node holding the skeleton).
@export var model: Node3D


func _ready() -> void:
	assert(look != null and model != null, "CharacterOutfit: look and model.")
	apply(model, look)


## Dresses `model`; dressing again replaces the previous outfit. All the pieces go in one
## mesh skinned to the skeleton, each vertex bound to its piece's bone, so a character
## costs one draw call for its clothes instead of one per piece (F10 task 1).
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
	if look.parts.is_empty():
		return
	var skin := Skin.new()
	var outfit := MeshInstance3D.new()
	outfit.name = PIECES
	outfit.mesh = outfit_mesh(look, skeleton, skin)
	outfit.material_override = _pieces_material()
	skeleton.add_child(outfit)
	outfit.skin = skin
	outfit.skeleton = outfit.get_path_to(skeleton)


## The pieces of `look` in one mesh, posed at the skeleton's rest, coloured per vertex and
## weighted fully to their bones; fills `skin` with one bind per bone used. Pure apart from
## `skin`.
static func outfit_mesh(look: CharacterLook, skeleton: Skeleton3D, skin: Skin) -> ArrayMesh:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var bones := PackedInt32Array()
	var weights := PackedFloat32Array()
	var indices := PackedInt32Array()
	var bind_of: Dictionary[StringName, int] = {}
	for part: LookPart in look.parts:
		var bone: int = skeleton.find_bone(part.bone)
		assert(bone >= 0, "CharacterOutfit: no bone %s." % part.bone)
		var rest: Transform3D = skeleton.get_bone_global_rest(bone)
		if not bind_of.has(part.bone):
			bind_of[part.bone] = skin.get_bind_count()
			skin.add_named_bind(String(part.bone), rest.affine_inverse())
		var local := Transform3D(Basis.from_euler(part.rotation_deg * (PI / 180.0)), part.offset)
		var xf: Transform3D = rest * local
		var arrays: Array = (mesh_for(part) as PrimitiveMesh).get_mesh_arrays()
		var base: int = verts.size()
		for v: Vector3 in arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array:
			verts.append(xf * v)
			colors.append(part.color)
			bones.append_array([bind_of[part.bone], 0, 0, 0])
			weights.append_array([1.0, 0.0, 0.0, 0.0])
		for n: Vector3 in arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array:
			normals.append((xf.basis * n).normalized())
		for i: int in arrays[Mesh.ARRAY_INDEX] as PackedInt32Array:
			indices.append(base + i)
	var surface: Array = []
	surface.resize(Mesh.ARRAY_MAX)
	surface[Mesh.ARRAY_VERTEX] = verts
	surface[Mesh.ARRAY_NORMAL] = normals
	surface[Mesh.ARRAY_COLOR] = colors
	surface[Mesh.ARRAY_BONES] = bones
	surface[Mesh.ARRAY_WEIGHTS] = weights
	surface[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)
	return mesh


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


static func _pieces_material() -> StandardMaterial3D:
	var mat: StandardMaterial3D = _material(Color.WHITE)
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	return mat


static func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	return mat

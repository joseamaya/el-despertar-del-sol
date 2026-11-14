class_name HitFlash
extends Node
## Flashes a mesh for an instant whenever its Hurtbox takes a hit (damage feedback,
## GDD §14.4 criterion 5), then restores whatever override it had.

@export var hurtbox: Hurtbox
@export var mesh: GeometryInstance3D
@export var color: Color = Color(0.95, 0.95, 0.95)
@export_range(0.01, 1.0, 0.01, "suffix:s") var duration: float = 0.08

var _material: StandardMaterial3D
var _restore: Material
var _flashing: bool = false


func _ready() -> void:
	assert(hurtbox != null and mesh != null, "HitFlash needs hurtbox and mesh.")
	_material = StandardMaterial3D.new()
	_material.albedo_color = color
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hurtbox.hit_received.connect(_on_hit)


func is_flashing() -> bool:
	return _flashing


func _on_hit(_info: HitInfo) -> void:
	if not _flashing:
		_restore = mesh.material_override
	_flashing = true
	mesh.material_override = _material
	await get_tree().create_timer(duration, false).timeout
	if is_instance_valid(mesh):
		mesh.material_override = _restore
	_flashing = false

class_name TrainingDummy
extends Node3D
## Test-scene target: flashes red when hit and disappears when its health runs out.

@export var health: HealthComponent
@export var hurtbox: Hurtbox
@export var mesh: MeshInstance3D
@export var flash_color: Color = Color(0.9, 0.15, 0.1)
@export_range(0.01, 1.0, 0.01, "suffix:s") var flash_time: float = 0.12

var _flash_material: StandardMaterial3D


func _ready() -> void:
	assert(health != null and hurtbox != null, "TrainingDummy needs health and hurtbox.")
	_flash_material = StandardMaterial3D.new()
	_flash_material.albedo_color = flash_color
	_flash_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hurtbox.hit_received.connect(_on_hit)
	health.died.connect(_on_died)


func is_flashing() -> bool:
	return mesh != null and mesh.material_override == _flash_material


func _on_hit(_info: HitInfo) -> void:
	if mesh == null:
		return
	mesh.material_override = _flash_material
	await get_tree().create_timer(flash_time, false).timeout
	if is_instance_valid(mesh):
		mesh.material_override = null


func _on_died() -> void:
	queue_free()

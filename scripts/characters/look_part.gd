class_name LookPart
extends Resource
## One piece of a character's outfit (F4 task 10): a simple shape hung from a bone of the
## UAL mannequin, in the bone's frame (Y along the bone, +Z the front of the body).

enum Shape { BOX, CYLINDER, RING, DISC }

@export var name: String = ""
@export var bone: StringName = &"Chest"
@export var shape: Shape = Shape.BOX
## BOX: width, height, depth. CYLINDER and DISC: radius, height. RING: inner radius,
## outer radius (x, y).
@export var size: Vector3 = Vector3(0.3, 0.3, 0.3)
@export var offset: Vector3 = Vector3.ZERO
@export var rotation_deg: Vector3 = Vector3.ZERO
@export var color: Color = Color.WHITE

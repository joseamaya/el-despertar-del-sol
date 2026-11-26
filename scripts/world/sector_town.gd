class_name SectorTown
extends RefCounted
## The pieces of a town that a hillside sector does not have (F9 task 4): stone posts at
## the gates of the kanchas and the huacas that only stand there, without the slice's
## offering. All in one mesh, each with its collider.

## Thickness of a gate post (a little more than the boundary wall it ends).
const POST_THICKNESS: float = 0.75
## Radius of the pirca ring around a huaca, and the width of its opening.
const RING_RADIUS: float = 2.6
const RING_GAP_DEG: float = 50.0


static func build(root: Node3D, layout: SectorLayout, palette: PaletteTuning) -> void:
	var parts: Array[Array] = []
	var i: int = 0
	for post: Vector3 in layout.gate_posts:
		var xf: Transform3D = _place(layout, post)
		var mesh: ArrayMesh = KitWalls.wall_end(
			layout.gate_post_height, POST_THICKNESS, 300 + i, palette
		)
		parts.append([mesh, xf])
		var size := Vector3(0.8, layout.gate_post_height, POST_THICKNESS)
		var col := SectorBuilder.add_box_collider(root, xf.origin + Vector3.UP * size.y * 0.5, size)
		col.basis = xf.basis
		i += 1
	for shrine: Vector3 in layout.shrines:
		var xf: Transform3D = _place(layout, shrine)
		parts.append([KitBuildings.standing_huaca(400 + i, palette), xf])
		_shrine_colliders(root, xf)
		i += 1
	if parts.is_empty():
		return
	SectorBuilder.add_mesh(root, "Town", KitWalls.merge(parts), palette, Vector3.ZERO)


## Where a piece at (x, z, yaw in degrees) stands on the ground.
static func _place(layout: SectorLayout, at: Vector3) -> Transform3D:
	var ground := Vector3(at.x, layout.height_at(at.x, at.y), at.y)
	return Transform3D(Basis(Vector3.UP, deg_to_rad(at.z)), ground)


## The stone and the ring block the way; the opening of the ring stays walkable.
static func _shrine_colliders(root: Node3D, xf: Transform3D) -> void:
	var stone := SectorBuilder.add_box_collider(
		root, xf.origin + Vector3.UP * 1.5, Vector3(1.4, 3.0, 1.4)
	)
	stone.basis = xf.basis
	for seg: Array in KitWalls.corral_segments(RING_RADIUS, RING_GAP_DEG):
		var s: Transform3D = xf * (seg[0] as Transform3D)
		var length: float = seg[1]
		var mid: Vector3 = s.origin + s.basis.x * length * 0.5 + Vector3.UP * 0.3
		var ring := SectorBuilder.add_box_collider(root, mid, Vector3(length, 0.6, 0.5))
		ring.basis = s.basis

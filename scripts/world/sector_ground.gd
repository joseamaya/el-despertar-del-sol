class_name SectorGround
extends RefCounted
## Ground of a sector (split from SectorBuilder, F3 task 10): faceted mesh plus heightmap
## collision. Optionally coarser on the inaccessible sides and without sun shadows, the
## two biggest costs found when measuring the walk through Carmenca.


static func build(
	root: Node3D, layout: SectorLayout, palette: PaletteTuning, heights: SectorBuilder.HeightGrid
) -> void:
	var sample := func(xz: Vector2) -> float: return heights.at(xz.x, xz.y)
	var shadow: GeometryInstance3D.ShadowCastingSetting = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if layout.ground_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	if layout.side_cell <= SectorBuilder.MESH_CELL.x:
		var cells := Vector2i(
			int(layout.size.x / SectorBuilder.MESH_CELL.x),
			int(layout.size.y / SectorBuilder.MESH_CELL.y)
		)
		var mesh: ArrayMesh = LowPolyTerrain.ground_grid(
			layout.size, cells, sample, palette.earth, palette.dry_grass, 7
		)
		SectorBuilder.add_mesh(root, "Ground", mesh, palette, Vector3.ZERO).cast_shadow = shadow
	else:
		# Fine cells over the corridor strip, coarse cells across X on the inaccessible
		# sides. Both keep 1 m rows along Z, so terrace steps line up and no crack opens.
		var strip: float = minf(_widest_corridor(layout) + 6.0, layout.size.x * 0.5)
		strip = ceilf(strip / SectorBuilder.MESH_CELL.x) * SectorBuilder.MESH_CELL.x
		var rows: int = int(layout.size.y / SectorBuilder.MESH_CELL.y)
		var centre_size := Vector2(strip * 2.0, layout.size.y)
		var centre: ArrayMesh = LowPolyTerrain.ground_grid(
			centre_size,
			Vector2i(int(centre_size.x / SectorBuilder.MESH_CELL.x), rows),
			sample,
			palette.earth,
			palette.dry_grass,
			7
		)
		SectorBuilder.add_mesh(root, "Ground", centre, palette, Vector3.ZERO).cast_shadow = shadow
		var side_w: float = layout.size.x * 0.5 - strip
		var side_cells: int = maxi(1, int(side_w / layout.side_cell))
		for sgn: float in [-1.0, 1.0]:
			var offset := Vector2(sgn * (strip + side_w * 0.5), 0.0)
			var shifted := func(xz: Vector2) -> float: return heights.at(xz.x + offset.x, xz.y)
			var side: ArrayMesh = LowPolyTerrain.ground_grid(
				Vector2(side_w, layout.size.y),
				Vector2i(side_cells, rows),
				shifted,
				palette.earth,
				palette.dry_grass,
				8
			)
			var node := SectorBuilder.add_mesh(
				root, "GroundSide", side, palette, Vector3(offset.x, 0, 0)
			)
			node.cast_shadow = shadow
	var shape := HeightMapShape3D.new()
	shape.map_width = heights.width
	shape.map_depth = heights.depth
	shape.map_data = heights.data
	var body := SectorBuilder.static_body(root, "GroundBody")
	var col := CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)


static func _widest_corridor(layout: SectorLayout) -> float:
	var widest: float = 0.0
	for p: Vector2 in layout.corridor:
		widest = maxf(widest, p.y)
	return widest

class_name SectorNavigation
extends RefCounted
## Navigation mesh for a generated sector (F3 task 9), baked when the level loads from
## the sector's static colliders (heightmap, walls, stair ramps, houses, crags). Only the
## walkable corridor is baked: the steep sides are out of bounds anyway.

const SOURCE_GROUP: StringName = &"sector_nav_source"
# Multiples of the navigation map's default cell (0.25 m), so nothing gets rounded.
const AGENT_RADIUS: float = 0.5
const AGENT_HEIGHT: float = 2.0
## Stair ramps climb at ~34°; the steep sides start at ~54°.
const MAX_SLOPE_DEG: float = 45.0
const MAX_CLIMB: float = 0.25
## Margin beyond the widest corridor (m).
const MARGIN: float = 3.0


## Builds and bakes a NavigationRegion3D under `sector` (synchronously). Returns it.
static func bake(sector: Node3D, layout: SectorLayout) -> NavigationRegion3D:
	sector.add_to_group(SOURCE_GROUP)
	var mesh := NavigationMesh.new()
	mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	mesh.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	mesh.geometry_source_group_name = SOURCE_GROUP
	mesh.agent_radius = AGENT_RADIUS
	mesh.agent_height = AGENT_HEIGHT
	mesh.agent_max_slope = MAX_SLOPE_DEG
	mesh.agent_max_climb = MAX_CLIMB
	var region := NavigationRegion3D.new()
	region.name = "Navigation"
	region.navigation_mesh = mesh
	sector.add_child(region)
	# The baking filter is in the region's own frame, the sector's (F10 task 6a: given in
	# world space, the rotated sector lost the last ~20 m of each end of its corridor).
	mesh.filter_baking_aabb = corridor_bounds(layout)
	var started: int = Time.get_ticks_msec()
	region.bake_navigation_mesh(false)
	region.set_meta(&"bake_ms", Time.get_ticks_msec() - started)
	return region


## Local bounds of the walkable corridor (the widest half width, the whole length).
static func corridor_bounds(layout: SectorLayout) -> AABB:
	var widest: float = 0.0
	for p: Vector2 in layout.corridor:
		widest = maxf(widest, p.y)
	var half := Vector2(widest + MARGIN, layout.size.y * 0.5)
	var low: float = INF
	var high: float = -INF
	for p: Vector2 in layout.profile:
		low = minf(low, p.y)
		high = maxf(high, p.y)
	return AABB(
		Vector3(-half.x, low - 5.0, -half.y), Vector3(half.x * 2.0, high - low + 15.0, half.y * 2.0)
	)

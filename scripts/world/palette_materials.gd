class_name PaletteMaterials
extends RefCounted
## Flat, matte materials for the scenery, built from a PaletteTuning (GDD §10.1: few
## textures, flat colours). Meshes that carry vertex colours (stones, slopes) use them as
## albedo; the rest take one palette colour.

enum Role { VERTEX, ADOBE, ICHU, EARTH, HUACA, MOUNTAIN, INCA, CHANCA, FAR, PLANT }


static func material_for(palette: PaletteTuning, role: Role) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.roughness = 1.0
	mat.metallic_specular = 0.2
	mat.albedo_color = color_for(palette, role)
	mat.vertex_color_use_as_albedo = role in [Role.VERTEX, Role.FAR, Role.PLANT]
	# PLANT: thin blades seen from both sides; their normals point up (soft, no dark backs).
	if role == Role.PLANT:
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	# FAR: distant scenery whose vertex colour already carries the haze and a baked
	# sun shading: no fog and no lighting, so the dawn ambient cannot turn the blue apus
	# brown (docs/guia-visual.md, «azules atmosféricos»).
	# Palette colours are sRGB: read the baked vertex colours as sRGB too, or they show
	# paler and washed out (F3 task 11, «reconocible andino»).
	mat.vertex_color_is_srgb = mat.vertex_color_use_as_albedo
	mat.disable_fog = role == Role.FAR
	if role == Role.FAR:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat


static func color_for(palette: PaletteTuning, role: Role) -> Color:
	match role:
		Role.ADOBE:
			return palette.adobe
		Role.ICHU:
			return palette.ichu
		Role.EARTH:
			return palette.earth
		Role.HUACA:
			return palette.huaca_stone
		Role.MOUNTAIN:
			return palette.mountain
		Role.INCA:
			return palette.inca_red
		Role.CHANCA:
			return palette.chanca
	return Color.WHITE


## Sky, fog and ambient light for a WorldEnvironment. Mobile-safe features only.
static func environment_for(palette: PaletteTuning) -> Environment:
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = palette.sky_top
	sky_mat.sky_horizon_color = palette.sky_horizon
	sky_mat.ground_horizon_color = palette.ground_horizon
	sky_mat.ground_bottom_color = palette.ground_horizon.darkened(0.3)
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = palette.ambient_color
	env.ambient_light_sky_contribution = palette.ambient_sky_contribution
	env.ambient_light_energy = palette.ambient_energy
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = palette.fog_color
	env.fog_density = palette.fog_density
	env.fog_height = palette.fog_height
	env.fog_height_density = palette.fog_height_density
	env.fog_sky_affect = 0.3
	env.glow_enabled = palette.glow_enabled
	env.glow_intensity = palette.glow_intensity
	env.glow_bloom = palette.glow_bloom
	env.glow_hdr_threshold = palette.glow_threshold
	return env


## Points and colours a sun light from the palette (low raking dawn light).
static func apply_sun(palette: PaletteTuning, sun: DirectionalLight3D) -> void:
	sun.light_color = palette.sun_color
	sun.light_energy = palette.sun_energy
	sun.rotation_degrees = Vector3(-palette.sun_elevation_deg, palette.sun_azimuth_deg, 0.0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = palette.shadow_distance
	sun.shadow_bias = palette.shadow_bias
	sun.shadow_normal_bias = palette.shadow_normal_bias
	match palette.shadow_splits:
		1:
			sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		2:
			sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
		_:
			sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS


## Direction towards the sun (unit vector, world space) for the palette.
static func sun_direction(palette: PaletteTuning) -> Vector3:
	var basis := Basis.from_euler(
		Vector3(deg_to_rad(-palette.sun_elevation_deg), deg_to_rad(palette.sun_azimuth_deg), 0.0)
	)
	return basis * Vector3.BACK


## Fill light: opposite the sun in azimuth, higher, no shadows. Returns null when the
## palette has none.
static func fill_light(palette: PaletteTuning) -> DirectionalLight3D:
	if palette.fill_energy <= 0.0:
		return null
	var fill := DirectionalLight3D.new()
	fill.name = "Fill"
	fill.light_color = palette.fill_color
	fill.light_energy = palette.fill_energy
	fill.rotation_degrees = Vector3(
		-palette.fill_elevation_deg, palette.sun_azimuth_deg + 180.0, 0.0
	)
	fill.shadow_enabled = false
	fill.light_specular = 0.0
	return fill

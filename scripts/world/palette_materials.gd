class_name PaletteMaterials
extends RefCounted
## Flat, matte materials for the scenery, built from a PaletteTuning (GDD §10.1: few
## textures, flat colours). Meshes that carry vertex colours (stones, slopes) use them as
## albedo; the rest take one palette colour.

enum Role { VERTEX, ADOBE, ICHU, EARTH, HUACA, MOUNTAIN, INCA, CHANCA, FAR }


static func material_for(palette: PaletteTuning, role: Role) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.roughness = 1.0
	mat.metallic_specular = 0.2
	mat.albedo_color = color_for(palette, role)
	mat.vertex_color_use_as_albedo = role == Role.VERTEX or role == Role.FAR
	# FAR: distant scenery (apus) whose vertex colour already includes the atmosphere.
	mat.disable_fog = role == Role.FAR
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
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = palette.ambient_color
	env.ambient_light_energy = palette.ambient_energy
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = palette.fog_color
	env.fog_density = palette.fog_density
	env.fog_height = palette.fog_height
	env.fog_height_density = palette.fog_height_density
	env.fog_sky_affect = 0.3
	return env


## Points and colours a sun light from the palette (low raking dawn light).
static func apply_sun(palette: PaletteTuning, sun: DirectionalLight3D) -> void:
	sun.light_color = palette.sun_color
	sun.light_energy = palette.sun_energy
	sun.rotation_degrees = Vector3(-palette.sun_elevation_deg, palette.sun_azimuth_deg, 0.0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = palette.shadow_distance

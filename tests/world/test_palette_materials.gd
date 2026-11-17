extends GdUnitTestSuite
## Unit: materials, environment and sun built from a PaletteTuning.


func test_vertex_and_far_roles_use_vertex_colour() -> void:
	var p := PaletteTuning.new()
	var vertex := PaletteMaterials.material_for(p, PaletteMaterials.Role.VERTEX)
	var far := PaletteMaterials.material_for(p, PaletteMaterials.Role.FAR)
	var adobe := PaletteMaterials.material_for(p, PaletteMaterials.Role.ADOBE)
	assert_bool(vertex.vertex_color_use_as_albedo).is_true()
	assert_bool(vertex.disable_fog).is_false()
	assert_bool(far.vertex_color_use_as_albedo).is_true()
	assert_bool(far.disable_fog).is_true()
	assert_int(far.shading_mode).is_equal(BaseMaterial3D.SHADING_MODE_UNSHADED)
	assert_bool(far.vertex_color_is_srgb).is_true()
	assert_int(vertex.shading_mode).is_equal(BaseMaterial3D.SHADING_MODE_PER_PIXEL)
	assert_bool(adobe.vertex_color_use_as_albedo).is_false()
	assert_object(adobe.albedo_color).is_equal(p.adobe)


func test_faction_colours_come_from_the_palette() -> void:
	var p := PaletteTuning.new()
	p.inca_red = Color(0.9, 0.1, 0.1)
	assert_object(PaletteMaterials.color_for(p, PaletteMaterials.Role.INCA)).is_equal(p.inca_red)
	assert_object(PaletteMaterials.color_for(p, PaletteMaterials.Role.CHANCA)).is_equal(p.chanca)


func test_environment_uses_palette_fog_and_mobile_safe_features() -> void:
	var p := PaletteTuning.new()
	p.fog_density = 0.003
	p.fog_color = Color(0.5, 0.6, 0.7)
	var env: Environment = PaletteMaterials.environment_for(p)
	assert_bool(env.fog_enabled).is_true()
	assert_float(env.fog_density).is_equal_approx(0.003, 0.0001)
	assert_object(env.fog_light_color).is_equal(p.fog_color)
	assert_bool(env.volumetric_fog_enabled).is_false()
	assert_bool(env.ssao_enabled).is_false()
	assert_bool(env.sdfgi_enabled).is_false()


func test_sun_is_low_and_limits_shadow_distance() -> void:
	var p := PaletteTuning.new()
	p.sun_elevation_deg = 12.0
	p.shadow_distance = 90.0
	var sun := DirectionalLight3D.new()
	PaletteMaterials.apply_sun(p, sun)
	assert_float(sun.rotation_degrees.x).is_equal_approx(-12.0, 0.01)
	assert_float(sun.directional_shadow_max_distance).is_equal_approx(90.0, 0.01)
	assert_bool(sun.shadow_enabled).is_true()
	sun.free()


func test_shadow_splits_choose_the_cascade_mode() -> void:
	var p := PaletteTuning.new()
	var sun := DirectionalLight3D.new()
	var modes: Dictionary = {
		1: DirectionalLight3D.SHADOW_ORTHOGONAL,
		2: DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS,
		4: DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS,
	}
	for splits: int in modes:
		p.shadow_splits = splits
		PaletteMaterials.apply_sun(p, sun)
		assert_int(sun.directional_shadow_mode).is_equal(modes[splits])
	sun.free()


## Carmenca walk budget (F3 task 10, docs/rendimiento/2026-11-carmenca-recorrido.md):
## 2 cascades and 8 m side cells keep it under 1.2 M primitives.
func test_carmenca_keeps_the_walk_budget_options() -> void:
	var p := load("res://resources/style/palette_amanecer_calido.tres") as PaletteTuning
	var layout := load("res://resources/levels/carmenca_layout.tres") as SectorLayout
	assert_int(p.shadow_splits).is_equal(2)
	assert_float(layout.side_cell).is_equal(8.0)
	assert_bool(layout.ground_shadow).is_true()


func test_every_palette_resource_loads() -> void:
	for name: String in ["amanecer_calido", "altura_fria", "contraste"]:
		var p := load("res://resources/style/palette_%s.tres" % name) as PaletteTuning
		assert_object(p).is_not_null()


func test_fill_light_is_off_by_default_and_never_casts_shadows() -> void:
	var p := PaletteTuning.new()
	assert_object(PaletteMaterials.fill_light(p)).is_null()
	p.fill_energy = 0.3
	var fill := PaletteMaterials.fill_light(p)
	assert_bool(fill.shadow_enabled).is_false()
	# Opposite the sun in azimuth.
	assert_float(fill.rotation_degrees.y).is_equal_approx(p.sun_azimuth_deg + 180.0, 0.01)
	fill.free()


func test_sun_direction_points_up_towards_the_light() -> void:
	var p := PaletteTuning.new()
	p.sun_elevation_deg = 30.0
	var to_sun: Vector3 = PaletteMaterials.sun_direction(p)
	assert_float(to_sun.y).is_equal_approx(0.5, 0.01)
	assert_float(to_sun.length()).is_equal_approx(1.0, 0.001)
	var sun := DirectionalLight3D.new()
	PaletteMaterials.apply_sun(p, sun)
	# A directional light shines along its -Z: the opposite of "towards the sun".
	assert_float((sun.basis * Vector3.FORWARD).dot(to_sun)).is_equal_approx(-1.0, 0.001)
	sun.free()


func test_glow_and_sky_ambient_follow_the_palette() -> void:
	var p := PaletteTuning.new()
	p.glow_enabled = true
	p.glow_intensity = 0.2
	p.ambient_sky_contribution = 0.3
	var env: Environment = PaletteMaterials.environment_for(p)
	assert_bool(env.glow_enabled).is_true()
	assert_float(env.glow_intensity).is_equal_approx(0.2, 0.001)
	assert_float(env.ambient_light_sky_contribution).is_equal_approx(0.3, 0.001)

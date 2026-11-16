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


func test_every_palette_resource_loads() -> void:
	for name: String in ["amanecer_calido", "altura_fria", "contraste"]:
		var p := load("res://resources/style/palette_%s.tres" % name) as PaletteTuning
		assert_object(p).is_not_null()

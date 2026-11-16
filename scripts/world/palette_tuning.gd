class_name PaletteTuning
extends Resource
## Colours and light of the scenery (GDD §10.1, §10.4; F3 visual guide). Scenery
## generators read every colour from here, never from code. One .tres per look.

@export_group("Stone and earth")
## Pirca stones vary between these two (per stone, baked as vertex colour).
@export var stone_light: Color = Color(0.62, 0.58, 0.52)
@export var stone_dark: Color = Color(0.38, 0.35, 0.32)
## The huaca rock: a stone that stands out from the walls.
@export var huaca_stone: Color = Color(0.46, 0.4, 0.36)
@export var adobe: Color = Color(0.66, 0.5, 0.36)
## Bare earth: terrace tops, paths.
@export var earth: Color = Color(0.5, 0.38, 0.27)
## Dry puna grass on slopes (mixed with earth).
@export var dry_grass: Color = Color(0.6, 0.55, 0.34)
## Ichu thatch on roofs.
@export var ichu: Color = Color(0.72, 0.6, 0.36)
## Water in irrigation channels (acequias).
@export var water: Color = Color(0.36, 0.48, 0.55)
## Smoke columns on the horizon (GDD §14.1).
@export var smoke: Color = Color(0.36, 0.33, 0.32)
## Cultivated fields in the valley: two tones mixed per plot.
@export var field_green: Color = Color(0.45, 0.5, 0.3)
@export var field_ochre: Color = Color(0.68, 0.56, 0.34)
## Far mountains (apus), atmosphere included: they are drawn without fog.
@export var mountain: Color = Color(0.42, 0.45, 0.55)

@export_group("Factions")
## Textile accents (GDD §10.4): red and yellow for the Inca side.
@export var inca_red: Color = Color(0.7, 0.14, 0.1)
@export var inca_yellow: Color = Color(0.86, 0.66, 0.16)
## Chanca warriors (same teal as the F2 warrior).
@export var chanca: Color = Color(0.16, 0.42, 0.52)

@export_group("Sky and fog")
@export var sky_top: Color = Color(0.32, 0.48, 0.7)
@export var sky_horizon: Color = Color(0.86, 0.7, 0.55)
@export var ground_horizon: Color = Color(0.5, 0.44, 0.4)
@export var fog_color: Color = Color(0.78, 0.72, 0.66)
## Exponential fog over distance. Mobile renderer: no volumetric fog (DECISIONS/0004).
@export_range(0.0, 0.05, 0.0005) var fog_density: float = 0.0015
## Height fog: denser below this height (valley mist).
@export_range(-200.0, 200.0, 1.0, "suffix:m") var fog_height: float = -55.0
@export_range(0.0, 2.0, 0.01) var fog_height_density: float = 0.03

@export_group("Light")
@export var sun_color: Color = Color(1.0, 0.78, 0.55)
@export_range(0.0, 4.0, 0.05) var sun_energy: float = 1.3
## Dawn light is low and raking (GDD §14.1): a few degrees above the horizon.
@export_range(1.0, 89.0, 0.5, "suffix:°") var sun_elevation_deg: float = 14.0
## Compass direction the light comes from, around the Y axis.
@export_range(-180.0, 180.0, 1.0, "suffix:°") var sun_azimuth_deg: float = 60.0
@export var ambient_color: Color = Color(0.55, 0.6, 0.7)
@export_range(0.0, 2.0, 0.05) var ambient_energy: float = 0.5
## Share of the ambient light taken from the sky instead of `ambient_color` (0..1). The
## sky warms the shadows at dawn; a flat blue alone turns dry grass green.
@export_range(0.0, 1.0, 0.05) var ambient_sky_contribution: float = 0.0
## Sun shadow distance; ~100 m keeps the proxy budget (docs/rendimiento).
@export_range(10.0, 500.0, 5.0, "suffix:m") var shadow_distance: float = 100.0
## Shadow biases: a low sun grazes the ground and needs more normal bias against acne.
@export_range(0.0, 2.0, 0.01) var shadow_bias: float = 0.1
@export_range(0.0, 10.0, 0.1) var shadow_normal_bias: float = 2.0

@export_group("Fill light")
## Bounce from the sky on the side opposite the sun, without shadows (cheap). Energy 0
## turns it off.
@export var fill_color: Color = Color(0.7, 0.72, 0.8)
@export_range(0.0, 2.0, 0.05) var fill_energy: float = 0.0
@export_range(1.0, 89.0, 0.5, "suffix:°") var fill_elevation_deg: float = 35.0

@export_group("Glow")
## Soft bloom around the sun and the bright sky (supported by the Mobile renderer).
@export var glow_enabled: bool = false
@export_range(0.0, 2.0, 0.05) var glow_intensity: float = 0.4
@export_range(0.0, 1.0, 0.01) var glow_bloom: float = 0.05
@export_range(0.0, 4.0, 0.05) var glow_threshold: float = 1.0

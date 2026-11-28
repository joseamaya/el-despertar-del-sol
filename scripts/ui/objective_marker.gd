class_name ObjectiveMarker
extends CanvasLayer
## Shows where the current objective is (F6 task 8): for steps that send the player to a
## place (reach, interact, rite) or to a fight that has not found them yet. Fades out
## near the place, during fights and while the player is held (talks, the opening).

@export var tuning: ObjectiveMarkerTuning
@export var slice: SliceDirector
@export var level: SectorLevel
@export var arena: ArenaController
@export var player: PlayerController
@export var camera: Camera3D
## Optional, the hub only: it leads to who to talk to next (F9 task 6).
@export var hub: HubTalks

var _canvas: Control
var _label: Label
var _alpha: float = 0.0


func _ready() -> void:
	assert(tuning != null and slice != null and level != null, "ObjectiveMarker: parts.")
	assert(player != null and camera != null, "ObjectiveMarker: player and camera.")
	layer = 5
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_marker)
	add_child(_canvas)
	_label = Label.new()
	_label.add_theme_font_size_override(&"font_size", 18)
	_label.add_theme_color_override(&"font_color", tuning.color)
	_label.add_theme_constant_override(&"outline_size", 5)
	_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	_canvas.add_child(_label)


func _process(delta: float) -> void:
	var target: Variant = target_position()
	var wanted: float = 0.0
	if target != null:
		var flat := Vector2(
			(target as Vector3).x - player.global_position.x,
			(target as Vector3).z - player.global_position.z
		)
		wanted = clampf((flat.length() - tuning.hide_within) / tuning.fade_span, 0.0, 1.0)
	_alpha = move_toward(_alpha, wanted, delta * 3.0)
	_canvas.queue_redraw()


## Whether the marker is showing now.
func is_showing() -> bool:
	return _alpha > 0.05


## Where the current step sends the player, or null if it sends them nowhere (a talk, a
## drill, a fight under way) or the player is held.
func target_position() -> Variant:
	if hub != null:
		return hub.objective_position()
	var step: SliceStep = slice.flow.current() if slice.flow != null else null
	if step == null or player.is_held():
		return null
	match step.kind:
		SliceStep.Kind.REACH, SliceStep.Kind.INTERACT, SliceStep.Kind.RITE, SliceStep.Kind.ESCORT:
			return level.marker_position(step.marker)
		SliceStep.Kind.ENCOUNTER:
			if arena != null and (arena.is_zone_engaged() or arena.is_in_combat()):
				return null
			return level.marker_position(StringName("Encounter%d" % step.zone))
	return null


func _draw_marker() -> void:
	_label.visible = false
	var target: Variant = target_position()
	if target == null or _alpha <= 0.01:
		return
	_draw_edge(target as Vector3, Color(tuning.color, _alpha))


func _draw_edge(place: Vector3, color: Color) -> void:
	var size: Vector2 = _canvas.size
	var margin: float = tuning.size * 2.5
	if size.x <= margin * 2.0 or size.y <= margin * 2.0:
		return  # No room to draw (a window without size, as in headless tests).
	var above: Vector3 = place + Vector3.UP * tuning.lift
	var behind: bool = camera.is_position_behind(above)
	var at: Vector2 = camera.unproject_position(above)
	if behind:
		at = size - at
	var inside := Rect2(Vector2(margin, margin), size - Vector2(margin, margin) * 2.0)
	if not behind and inside.has_point(at):
		_diamond(at, color)
		_show_distance(at + Vector2(-20, tuning.size * 1.4), place, color)
		return
	# Out of view: hold it at the edge, pointing the way.
	var centre: Vector2 = size * 0.5
	var dir: Vector2 = (at - centre).normalized()
	if dir.is_zero_approx():
		dir = Vector2.DOWN
	var reach: float = minf(
		absf((inside.size.x * 0.5) / dir.x) if not is_zero_approx(dir.x) else INF,
		absf((inside.size.y * 0.5) / dir.y) if not is_zero_approx(dir.y) else INF
	)
	_arrow(centre + dir * reach, dir, color)


func _diamond(at: Vector2, color: Color) -> void:
	var s: float = tuning.size
	var points := PackedVector2Array(
		[
			at + Vector2(0, -s),
			at + Vector2(s * 0.7, 0),
			at + Vector2(0, s),
			at + Vector2(-s * 0.7, 0)
		]
	)
	_canvas.draw_colored_polygon(points, Color(0, 0, 0, color.a * 0.6))
	_canvas.draw_colored_polygon(_shrink(points, at, 0.75), color)


func _arrow(at: Vector2, dir: Vector2, color: Color) -> void:
	var s: float = tuning.size
	var side: Vector2 = dir.orthogonal()
	var points := PackedVector2Array(
		[at + dir * s, at - dir * s * 0.6 + side * s * 0.8, at - dir * s * 0.6 - side * s * 0.8]
	)
	_canvas.draw_colored_polygon(points, Color(0, 0, 0, color.a * 0.6))
	_canvas.draw_colored_polygon(_shrink(points, at, 0.7), color)


func _show_distance(at: Vector2, place: Vector3, color: Color) -> void:
	var metres: int = roundi(
		Vector2(place.x - player.global_position.x, place.z - player.global_position.z).length()
	)
	_label.text = tr(&"HUD_DISTANCE").format({"m": metres})
	_label.position = at
	_label.modulate = Color(1, 1, 1, color.a)
	_label.visible = true


func _shrink(points: PackedVector2Array, centre: Vector2, factor: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	for p: Vector2 in points:
		result.append(centre + (p - centre) * factor)
	return result

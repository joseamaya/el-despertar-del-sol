class_name SliceCaption
extends CanvasLayer
## Large caption over the opening shots (SliceStep.caption; F5, build 0.1.1): one short
## line in the lower third, fading in, with a small hint to skip. Hidden on steps without
## a caption.

const FADE_TIME: float = 0.6
const BAND_HEIGHT: float = 150.0

@export var slice: SliceDirector

var _band: PanelContainer
var _text: Label
var _hint: Label
var _tween: Tween


func _ready() -> void:
	assert(slice != null, "SliceCaption: slice.")
	layer = 9
	_build()
	_band.visible = false
	slice.step_started.connect(_on_step_started)
	slice.slice_finished.connect(hide_caption)


func show_caption(key: StringName) -> void:
	_text.text = tr(key)
	_hint.text = tr(&"INTRO_SKIP")
	_band.visible = true
	_band.modulate.a = 0.0
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_band, ^"modulate:a", 1.0, FADE_TIME)


func hide_caption() -> void:
	if _tween != null:
		_tween.kill()
	_band.visible = false


func is_showing() -> bool:
	return _band.visible


func shown_text() -> String:
	return _text.text


func _on_step_started(step: SliceStep) -> void:
	if step.caption != &"":
		show_caption(step.caption)
	else:
		hide_caption()


func _build() -> void:
	_band = PanelContainer.new()
	_band.name = "Band"
	_band.anchor_right = 1.0
	_band.anchor_top = 1.0
	_band.anchor_bottom = 1.0
	_band.offset_top = -BAND_HEIGHT * 1.6
	_band.offset_bottom = -BAND_HEIGHT * 0.6
	_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.55)
	style.set_content_margin_all(16)
	_band.add_theme_stylebox_override(&"panel", style)
	add_child(_band)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	_band.add_child(column)
	_text = _label(40, Color(0.98, 0.95, 0.88))
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint = _label(18, Color(0.8, 0.76, 0.7))
	column.add_child(_text)
	column.add_child(_hint)


func _label(size: int, colour: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", size)
	label.add_theme_color_override(&"font_color", colour)
	label.add_theme_constant_override(&"outline_size", 6)
	label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.9))
	return label

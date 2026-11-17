class_name DialogueBox
extends CanvasLayer
## Shows one line of dialogue at the bottom of the screen (F4 task 3): the speaker, the
## text and how to go on. Builds its own panel; DialoguePlayer decides what it shows.

const MARGIN: int = 48
const PANEL_HEIGHT: int = 170

var _panel: PanelContainer
var _speaker: Label
var _text: Label
var _hint: Label


func _ready() -> void:
	layer = 10
	_build()
	hide_line()


## Shows a line; `speaker` and `text` are translation keys.
func show_line(speaker: StringName, text: StringName) -> void:
	_speaker.text = tr(speaker)
	_text.text = tr(text)
	_hint.text = tr(&"DIALOGUE_CONTINUE")
	_panel.visible = true


func hide_line() -> void:
	_panel.visible = false


func is_showing() -> bool:
	return _panel.visible


func shown_text() -> String:
	return _text.text


func _build() -> void:
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.anchor_left = 0.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = MARGIN
	_panel.offset_right = -MARGIN
	_panel.offset_top = -PANEL_HEIGHT - MARGIN * 0.5
	_panel.offset_bottom = -MARGIN * 0.5
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.05, 0.82)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(18)
	_panel.add_theme_stylebox_override(&"panel", style)
	add_child(_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 8)
	_panel.add_child(column)
	_speaker = _label(26, Color(0.95, 0.75, 0.35))
	_text = _label(24, Color(0.96, 0.93, 0.88))
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_hint = _label(18, Color(0.8, 0.76, 0.7))
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for label: Label in [_speaker, _text, _hint]:
		column.add_child(label)


func _label(size: int, colour: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override(&"font_size", size)
	label.add_theme_color_override(&"font_color", colour)
	return label

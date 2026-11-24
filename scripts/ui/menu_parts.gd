class_name MenuParts
extends RefCounted
## Controls shared by the menus (pause, title, settings; F4 task 8, F8 task 2): labels,
## buttons and the dark panel, with the same sizes and colours. Every text goes through
## tr().

const PANEL := Color(0.1, 0.075, 0.06, 0.95)


static func label(key: StringName, size: int, colour: Color) -> Label:
	var out := Label.new()
	out.text = TranslationServer.translate(key) if key != &"" else ""
	out.add_theme_font_size_override(&"font_size", size)
	out.add_theme_color_override(&"font_color", colour)
	return out


static func button(key: StringName) -> Button:
	var out := Button.new()
	out.text = TranslationServer.translate(key)
	out.add_theme_font_size_override(&"font_size", 26)
	out.custom_minimum_size = Vector2(0.0, 52.0)
	return out


## A centred dark panel filling `root`; returns the column to put the pages in.
static func panel(root: Control, width: float) -> VBoxContainer:
	var centre := CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(centre)
	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(width, 0.0)
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.set_corner_radius_all(6)
	style.set_content_margin_all(32)
	box.add_theme_stylebox_override(&"panel", style)
	centre.add_child(box)
	var pages := VBoxContainer.new()
	box.add_child(pages)
	return pages


## The build's version line, for testers' reports (F5 task 5).
static func version_label(colour: Color) -> Label:
	var out := label(&"", 18, colour)
	out.name = "Version"
	out.text = TranslationServer.translate(&"PAUSE_VERSION").format(
		{"version": GameVersion.current()}
	)
	out.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return out

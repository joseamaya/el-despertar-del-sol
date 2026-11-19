class_name PauseMenuBuilder
extends RefCounted
## Builds the pause menu's controls (F4 task 8): a dimmed screen, the main list and the
## settings page. PauseMenu wires them; every text goes through tr().

const TEXT := Color(0.96, 0.93, 0.88)
const TITLE := Color(0.95, 0.75, 0.35)
const DIM := Color(0.7, 0.65, 0.58)


static func build(parent: Node) -> Control:
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(root)
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.6)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var centre := CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(centre)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 0.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.075, 0.06, 0.95)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(32)
	panel.add_theme_stylebox_override(&"panel", style)
	centre.add_child(panel)
	var pages := VBoxContainer.new()
	panel.add_child(pages)
	pages.add_child(_main())
	pages.add_child(_options())
	return root


static func _main() -> VBoxContainer:
	var main := _column("Main")
	main.add_child(_label(&"PAUSE_TITLE", 34, TITLE))
	for key: StringName in [&"PAUSE_RESUME", &"PAUSE_SETTINGS", &"PAUSE_RESTART", &"PAUSE_QUIT"]:
		main.add_child(_button(key))
	# Which build this is, for testers' reports (F5 task 5).
	var version := _label(&"", 18, DIM)
	version.name = "Version"
	version.text = TranslationServer.translate(&"PAUSE_VERSION").format(
		{"version": GameVersion.current()}
	)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	main.add_child(version)
	return main


static func _options() -> VBoxContainer:
	var options := _column("Options")
	options.add_child(_label(&"PAUSE_SETTINGS", 34, TITLE))
	options.add_child(_label(&"SETTINGS_VOLUME", 22, TEXT))
	options.add_child(_slider("Volume", 0.0, 1.0, 0.05))
	var row := HBoxContainer.new()
	row.add_child(_label(&"SETTINGS_SENSITIVITY", 22, TEXT))
	var value := _label(&"", 22, TITLE)
	value.name = "SensitivityValue"
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)
	options.add_child(row)
	options.add_child(_slider("Sensitivity", 0.25, 3.0, 0.05))
	options.add_child(_label(&"SETTINGS_SCALE_3D", 22, TEXT))
	var scale := OptionButton.new()
	scale.name = "Scale"
	scale.add_theme_font_size_override(&"font_size", 22)
	options.add_child(scale)
	var back := _button(&"SETTINGS_BACK")
	back.name = "Back"
	options.add_child(back)
	return options


static func _column(node_name: String) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.name = node_name
	column.add_theme_constant_override(&"separation", 14)
	return column


static func _label(key: StringName, size: int, colour: Color) -> Label:
	var label := Label.new()
	label.text = TranslationServer.translate(key) if key != &"" else ""
	label.add_theme_font_size_override(&"font_size", size)
	label.add_theme_color_override(&"font_color", colour)
	return label


static func _button(key: StringName) -> Button:
	var button := Button.new()
	button.text = TranslationServer.translate(key)
	button.add_theme_font_size_override(&"font_size", 26)
	button.custom_minimum_size = Vector2(0.0, 52.0)
	return button


static func _slider(node_name: String, low: float, high: float, step: float) -> HSlider:
	var slider := HSlider.new()
	slider.name = node_name
	slider.min_value = low
	slider.max_value = high
	slider.step = step
	slider.custom_minimum_size = Vector2(0.0, 32.0)
	return slider

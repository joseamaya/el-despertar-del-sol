class_name InteractionPrompt
extends CanvasLayer
## The hint near the bottom of the screen when something can be done (F4 task 4):
## «E / A: …». Builds its own label; InteractionPoint decides when it shows.

var _label: Label


func _ready() -> void:
	layer = 9
	_label = Label.new()
	_label.name = "Prompt"
	_label.anchor_left = 0.0
	_label.anchor_right = 1.0
	_label.anchor_top = 0.72
	_label.anchor_bottom = 0.72
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override(&"font_size", 28)
	_label.add_theme_color_override(&"font_color", Color(0.98, 0.94, 0.86))
	_label.add_theme_color_override(&"font_outline_color", Color(0.1, 0.07, 0.05))
	_label.add_theme_constant_override(&"outline_size", 8)
	add_child(_label)
	hide_prompt()


## `key` is a translation key. Dimmed: something is there but cannot be done yet.
func show_prompt(key: StringName, dimmed: bool = false) -> void:
	_label.text = tr(key)
	_label.modulate = Color(0.75, 0.72, 0.68, 0.8) if dimmed else Color.WHITE
	_label.visible = true


func is_dimmed() -> bool:
	return _label.visible and _label.modulate != Color.WHITE


func hide_prompt() -> void:
	_label.visible = false


func is_showing() -> bool:
	return _label.visible


func shown_text() -> String:
	return _label.text

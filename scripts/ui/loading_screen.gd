class_name LoadingScreen
extends CanvasLayer
## Covers the screen while the game shell loads a level (F8 task 3): black, "Loading…"
## and a bar. Builds its own UI; the text goes through tr().

const TEXT := Color(0.96, 0.93, 0.88)

var _root: Control
var _bar: ProgressBar


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(black)
	var centre := CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(centre)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(420.0, 0.0)
	column.add_theme_constant_override(&"separation", 16)
	centre.add_child(column)
	var label: Label = MenuParts.label(&"LOADING", 30, TEXT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(label)
	_bar = ProgressBar.new()
	_bar.name = "Bar"
	_bar.max_value = 1.0
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(0.0, 10.0)
	column.add_child(_bar)
	_root.visible = false


func show_loading() -> void:
	_bar.value = 0.0
	_root.visible = true


## 0..1.
func set_progress(value: float) -> void:
	_bar.value = clampf(value, 0.0, 1.0)


func hide_loading() -> void:
	_root.visible = false


func is_showing() -> bool:
	return _root.visible

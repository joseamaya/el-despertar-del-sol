class_name FpsOverlay
extends CanvasLayer
## Frame rate in a corner, toggled with F3 (F4 task 11): lets testers on other machines
## (the Windows build, F5) report how the game runs. Hidden by default.

const ACTION_TOGGLE: StringName = &"toggle_fps"
## How often the text updates.
const REFRESH: float = 0.5

var _label: Label
var _left: float = 0.0


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_label = Label.new()
	_label.name = "Fps"
	_label.anchor_left = 1.0
	_label.anchor_right = 1.0
	_label.anchor_top = 1.0
	_label.anchor_bottom = 1.0
	_label.offset_left = -360.0
	_label.offset_right = -24.0
	_label.offset_top = -48.0
	_label.offset_bottom = -16.0
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.add_theme_font_size_override(&"font_size", 20)
	_label.add_theme_color_override(&"font_color", Color(0.98, 0.94, 0.86))
	_label.add_theme_color_override(&"font_outline_color", Color(0.1, 0.07, 0.05))
	_label.add_theme_constant_override(&"outline_size", 6)
	_label.visible = false
	add_child(_label)


func _process(delta: float) -> void:
	if not _label.visible:
		return
	_left -= delta
	if _left <= 0.0:
		_left = REFRESH
		_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_TOGGLE):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	_label.visible = not _label.visible
	_left = 0.0
	if _label.visible:
		_refresh()


func is_showing() -> bool:
	return _label.visible


func shown_text() -> String:
	return _label.text


func _refresh() -> void:
	var fps: float = Engine.get_frames_per_second()
	var ms: float = 1000.0 / maxf(fps, 1.0)
	_label.text = tr(&"HUD_FPS").format({"fps": roundi(fps), "ms": "%.1f" % ms})

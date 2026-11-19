class_name PassingLine
extends CanvasLayer
## Shows what someone says in passing (F4: the family going down past Cusi) as a subtitle
## above the dialogue box: it never stops the game nor waits for a key, and lines that
## come together are shown one after the other.

## Gap between the bottom of the screen and the subtitle: above the dialogue box.
const BOTTOM_GAP: int = 240

@export var crowd: SectorCrowd

var _label: Label
var _queue: Array[String] = []
var _left: float = 0.0


func _ready() -> void:
	assert(crowd != null, "PassingLine needs the crowd.")
	layer = 11
	_label = Label.new()
	_label.name = "Line"
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.offset_top = -BOTTOM_GAP - 60
	_label.offset_bottom = -BOTTOM_GAP
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_label.add_theme_font_size_override(&"font_size", 24)
	_label.add_theme_color_override(&"font_color", Color(0.98, 0.92, 0.78))
	_label.add_theme_color_override(&"font_outline_color", Color(0.08, 0.05, 0.03))
	_label.add_theme_constant_override(&"outline_size", 8)
	_label.visible = false
	add_child(_label)
	crowd.person_spoke.connect(_on_person_spoke)


func _process(delta: float) -> void:
	if not _label.visible:
		return
	_left -= delta
	if _left > 0.0:
		return
	if _queue.is_empty():
		_label.visible = false
	else:
		_show(_queue.pop_front())


func is_showing() -> bool:
	return _label.visible


func shown_text() -> String:
	return _label.text


func _on_person_spoke(speaker: StringName, line: StringName) -> void:
	var text: String = tr(&"PASSING_LINE").format({"speaker": tr(speaker), "line": tr(line)})
	if _label.visible:
		_queue.append(text)
	else:
		_show(text)


func _show(text: String) -> void:
	_label.text = text
	_label.visible = true
	_left = crowd.people.line_time

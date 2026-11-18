class_name CodexNotice
extends CanvasLayer
## A short notice when a codex entry unlocks (F4 task 5): its title and how to open the
## codex. Builds its own label.

## How long the notice stays up.
const SHOW_TIME: float = 6.0

@export var codex: Codex

var _label: Label
var _left: float = 0.0


func _ready() -> void:
	assert(codex != null, "CodexNotice: codex.")
	layer = 9
	_label = Label.new()
	_label.name = "Notice"
	_label.anchor_left = 1.0
	_label.anchor_right = 1.0
	_label.offset_left = -760.0
	_label.offset_right = -40.0
	_label.offset_top = 40.0
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override(&"font_size", 24)
	_label.add_theme_color_override(&"font_color", Color(0.95, 0.8, 0.45))
	_label.add_theme_color_override(&"font_outline_color", Color(0.1, 0.07, 0.05))
	_label.add_theme_constant_override(&"outline_size", 8)
	add_child(_label)
	_label.visible = false
	codex.entry_unlocked.connect(_on_entry_unlocked)


func _process(delta: float) -> void:
	if _left <= 0.0:
		return
	_left -= delta
	if _left <= 0.0:
		_label.visible = false


func is_showing() -> bool:
	return _label.visible


func shown_text() -> String:
	return _label.text


func _on_entry_unlocked(entry: CodexEntry) -> void:
	_label.text = tr(&"CODEX_NEW").format({"title": tr(entry.title)})
	_label.visible = true
	_left = SHOW_TIME

class_name CodexScreen
extends CanvasLayer
## The codex screen (F4 task 5, GDD §12.6): the unlocked entries on the left and the
## chosen one on the right, with its label, source and text. The `codex` action opens and
## closes it; the game pauses meanwhile. Builds its own UI.

const ACTION_CODEX: StringName = &"codex"
const ACTION_CLOSE: StringName = &"ui_cancel"
## Badge colour of each CodexEntry.Tag, in order.
const TAG_COLOURS: Array[Color] = [
	Color(0.28, 0.45, 0.3),
	Color(0.55, 0.38, 0.18),
	Color(0.45, 0.26, 0.42),
]
const TEXT_COLOUR := Color(0.96, 0.93, 0.88)
const DIM_COLOUR := Color(0.78, 0.73, 0.66)

@export var codex: Codex

var _open: bool = false
var _mouse_before: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
var _entries: Array[CodexEntry] = []
var _root: Control
var _list: ItemList
var _empty: Label
var _page: VBoxContainer
var _title: Label
var _tag: Label
var _source: Label
var _body: Label
var _note: Label


func _ready() -> void:
	assert(codex != null, "CodexScreen: codex.")
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_root.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_CODEX):
		if _open:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
	elif _open and event.is_action_pressed(ACTION_CLOSE):
		close()
		get_viewport().set_input_as_handled()


## Opens the codex and pauses the game. Does nothing if something else paused it.
func open() -> void:
	if _open or get_tree().paused:
		return
	_open = true
	get_tree().paused = true
	_mouse_before = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_fill()
	_root.visible = true


func close() -> void:
	if not _open:
		return
	_open = false
	_root.visible = false
	get_tree().paused = false
	Input.mouse_mode = _mouse_before


func is_open() -> bool:
	return _open


## Shows the entry at `index` of the unlocked list.
func select(index: int) -> void:
	if index < 0 or index >= _entries.size():
		return
	_list.select(index)
	var entry: CodexEntry = _entries[index]
	_title.text = tr(entry.title)
	_tag.text = tr(entry.tag_key())
	(_tag.get_theme_stylebox(&"normal") as StyleBoxFlat).bg_color = TAG_COLOURS[entry.tag]
	_source.text = tr(entry.source) if entry.source != &"" else ""
	_source.visible = entry.source != &""
	_body.text = tr(entry.body)
	_note.text = tr(entry.note) if entry.note != &"" else ""
	_note.visible = entry.note != &""


func shows_empty() -> bool:
	return _empty.visible


func shown_title() -> String:
	return _title.text


func shown_tag() -> String:
	return _tag.text


func shown_body() -> String:
	return _body.text


func _fill() -> void:
	_entries = codex.unlocked_entries()
	_list.clear()
	for entry: CodexEntry in _entries:
		_list.add_item(tr(entry.title))
	var empty: bool = _entries.is_empty()
	_empty.visible = empty
	_page.visible = not empty
	_list.visible = not empty
	if not empty:
		select(0)
		_list.grab_focus()


func _build() -> void:
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.55)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(shade)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.12
	panel.anchor_right = 0.88
	panel.anchor_top = 0.12
	panel.anchor_bottom = 0.88
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.075, 0.06, 0.95)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(28)
	panel.add_theme_stylebox_override(&"panel", style)
	_root.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 16)
	panel.add_child(column)
	var heading := _label(32, Color(0.95, 0.75, 0.35))
	heading.text = tr(&"CODEX_TITLE")
	column.add_child(heading)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override(&"separation", 28)
	column.add_child(row)
	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(260.0, 0.0)
	_list.add_theme_font_size_override(&"font_size", 22)
	_list.item_selected.connect(select)
	row.add_child(_list)
	_empty = _label(24, DIM_COLOUR)
	_empty.text = tr(&"CODEX_EMPTY")
	row.add_child(_empty)
	_build_page(row)
	var hint := _label(18, DIM_COLOUR)
	hint.text = tr(&"CODEX_CLOSE")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(hint)


func _build_page(row: HBoxContainer) -> void:
	_page = VBoxContainer.new()
	_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page.add_theme_constant_override(&"separation", 12)
	row.add_child(_page)
	_title = _label(30, TEXT_COLOUR)
	_tag = _label(18, TEXT_COLOUR)
	_tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var badge := StyleBoxFlat.new()
	badge.set_corner_radius_all(4)
	badge.content_margin_left = 10.0
	badge.content_margin_right = 10.0
	badge.content_margin_top = 3.0
	badge.content_margin_bottom = 3.0
	_tag.add_theme_stylebox_override(&"normal", badge)
	_source = _label(18, DIM_COLOUR)
	_body = _label(22, TEXT_COLOUR)
	_note = _label(18, DIM_COLOUR)
	for label: Label in [_source, _body, _note]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for label: Label in [_title, _tag, _source, _body, _note]:
		_page.add_child(label)


func _label(size: int, colour: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override(&"font_size", size)
	label.add_theme_color_override(&"font_color", colour)
	return label

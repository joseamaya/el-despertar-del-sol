class_name ChoiceBox
extends CanvasLayer
## Asks the player to pick one answer of a DialogueChoice (F4 task 6): the options at the
## bottom of the screen, up/down to move, `interact` to confirm. The player stands still
## and cannot fight meanwhile. Builds its own panel.

signal chosen(index: int)

const ACTION_CONFIRM: StringName = &"interact"
const ACTIONS_UP: Array[StringName] = [&"ui_up", &"move_forward"]
const ACTIONS_DOWN: Array[StringName] = [&"ui_down", &"move_back"]
const MARGIN: int = 48
const PANEL_HEIGHT: int = 170
const COLOUR_ON := Color(0.95, 0.75, 0.35)
const COLOUR_OFF := Color(0.8, 0.76, 0.7)

@export var player: PlayerController
## Nodes that read combat input (Combat, Defense…): paused while choosing.
@export var frozen: Array[Node] = []

var _choice: DialogueChoice
var _selected: int = 0
var _panel: PanelContainer
var _speaker: Label
var _list: VBoxContainer
var _hint: Label


func _ready() -> void:
	assert(player != null, "ChoiceBox: player.")
	layer = 10
	_build()
	_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not is_asking():
		return
	if event.is_action_pressed(ACTION_CONFIRM):
		get_viewport().set_input_as_handled()
		confirm()
		return
	for action: StringName in ACTIONS_UP:
		if event.is_action_pressed(action):
			get_viewport().set_input_as_handled()
			select(_selected - 1)
			return
	for action: StringName in ACTIONS_DOWN:
		if event.is_action_pressed(action):
			get_viewport().set_input_as_handled()
			select(_selected + 1)
			return


func ask(choice: DialogueChoice) -> void:
	assert(choice != null and not choice.options.is_empty(), "ChoiceBox: empty.")
	_choice = choice
	_speaker.text = tr(choice.speaker)
	_hint.text = tr(&"CHOICE_CONFIRM")
	for child: Node in _list.get_children():
		child.free()
	for option: DialogueOption in choice.options:
		var label := _label(24, COLOUR_OFF)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_list.add_child(label)
	select(0)
	_panel.visible = true
	PlayerHold.set_held(player, frozen, true)


## Highlights an option (clamped to the list).
func select(index: int) -> void:
	if not is_asking():
		return
	_selected = clampi(index, 0, _choice.options.size() - 1)
	for i: int in _choice.options.size():
		var label := _list.get_child(i) as Label
		var on: bool = i == _selected
		label.text = ("› " if on else "   ") + tr(_choice.options[i].text)
		label.add_theme_color_override(&"font_color", COLOUR_ON if on else COLOUR_OFF)


## Picks the highlighted option.
func confirm() -> void:
	if not is_asking():
		return
	var index: int = _selected
	_choice = null
	_panel.visible = false
	PlayerHold.set_held(player, frozen, false)
	chosen.emit(index)


func is_asking() -> bool:
	return _choice != null


func selected() -> int:
	return _selected


## The shown text of option `index`, marker included.
func option_text(index: int) -> String:
	return (_list.get_child(index) as Label).text


func _build() -> void:
	_panel = PanelContainer.new()
	_panel.name = "Panel"
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
	_speaker = _label(26, COLOUR_ON)
	_list = VBoxContainer.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_hint = _label(18, COLOUR_OFF)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(_speaker)
	column.add_child(_list)
	column.add_child(_hint)


func _label(size: int, colour: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override(&"font_size", size)
	label.add_theme_color_override(&"font_color", colour)
	return label

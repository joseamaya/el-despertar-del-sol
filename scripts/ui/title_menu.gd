class_name TitleMenu
extends CanvasLayer
## The title menu (F8 task 2): new game, continue (only when there is a saved game),
## settings and quit. Builds its own UI; navigable with mouse, keys and pad; every text
## goes through tr(). The game shell listens to its signals.

signal new_game_pressed
signal continue_pressed

const ACTION_BACK: StringName = &"ui_cancel"
const GOLD := Color(0.96, 0.83, 0.54)
const TEXT := Color(0.96, 0.93, 0.88)
const DIM := Color(0.7, 0.65, 0.58)
const BACKGROUND := Color(0.07, 0.05, 0.04)

var _root: Control
var _main: VBoxContainer
var _options: SettingsPage
var _continue: Button
var _new_game: Button


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_new_game.pressed.connect(new_game_pressed.emit)
	_continue.pressed.connect(continue_pressed.emit)
	(_main.get_node(^"Settings") as Button).pressed.connect(show_options)
	(_main.get_node(^"Quit") as Button).pressed.connect(_quit)
	_options.back_pressed.connect(show_main)
	set_can_continue(false)


func _unhandled_input(event: InputEvent) -> void:
	if is_showing() and _options.visible and event.is_action_pressed(ACTION_BACK):
		show_main()
		get_viewport().set_input_as_handled()


func show_menu() -> void:
	_root.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show_main()


func hide_menu() -> void:
	_root.visible = false


func is_showing() -> bool:
	return _root.visible


## "Continue" shows only with a saved game (F8 task 5).
func set_can_continue(can: bool) -> void:
	_continue.visible = can


func can_continue() -> bool:
	return _continue.visible


func show_main() -> void:
	_options.visible = false
	_main.visible = true
	(_continue if _continue.visible else _new_game).grab_focus()


func show_options() -> void:
	_main.visible = false
	_options.visible = true
	_options.refresh()
	_options.focus()


func is_showing_options() -> bool:
	return is_showing() and _options.visible


func _build() -> void:
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var background := ColorRect.new()
	background.color = BACKGROUND
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(background)
	var centre := CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(centre)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(520.0, 0.0)
	column.add_theme_constant_override(&"separation", 12)
	centre.add_child(column)
	var title: Label = MenuParts.label(&"TITLE_NAME", 96, GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var subtitle: Label = MenuParts.label(&"TITLE_SUBTITLE", 40, TEXT)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0.0, 48.0)
	column.add_child(gap)
	_main = VBoxContainer.new()
	_main.name = "Main"
	_main.add_theme_constant_override(&"separation", 14)
	column.add_child(_main)
	_continue = _named_button("Continue", &"TITLE_CONTINUE")
	_new_game = _named_button("NewGame", &"TITLE_NEW_GAME")
	_named_button("Settings", &"PAUSE_SETTINGS")
	_named_button("Quit", &"PAUSE_QUIT")
	_main.add_child(MenuParts.version_label(DIM))
	_options = SettingsPage.new()
	column.add_child(_options)
	_options.visible = false


func _named_button(node_name: String, key: StringName) -> Button:
	var button: Button = MenuParts.button(key)
	button.name = node_name
	_main.add_child(button)
	return button


func _quit() -> void:
	get_tree().quit()

class_name PauseMenu
extends CanvasLayer
## Pause menu (F4 task 8, GDD §14.2): Esc or Start pauses the game; continue, settings
## (volume, camera sensitivity, 3D scale), start the slice again or quit. It does not open
## over another pause (the codex) nor on the defeat and end screens, where Start retries.
## Builds its own UI; navigable with mouse, keys and pad. Inside the game shell (F8 task
## 2) it also offers going back to the title, and asks the shell to restart the level
## instead of reloading the scene.

## Hosted only: the player chose "start again".
signal restart_requested
## Hosted only: the player chose "back to the title".
signal title_requested

const ACTION_PAUSE: StringName = &"pause"
const ACTION_BACK: StringName = &"ui_cancel"

## Optional: on its defeat screen Start retries instead.
@export var arena: ArenaController
## Optional: once it is over Start plays again instead.
@export var slice: SliceDirector

var _open: bool = false
var _hosted: bool = false
var _mouse_before: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
var _root: Control
var _main: VBoxContainer
var _options: SettingsPage
var _resume: Button
var _support: SupportLedger


func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = PauseMenuBuilder.build(self)
	_main = _root.find_child("Main", true, false) as VBoxContainer
	_options = _root.find_child("Options", true, false) as SettingsPage
	_resume = _main.get_node(^"Resume") as Button
	_connect()
	_root.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_PAUSE):
		if _open:
			close()
			get_viewport().set_input_as_handled()
		elif can_open():
			open()
			get_viewport().set_input_as_handled()
	elif _open and event.is_action_pressed(ACTION_BACK):
		if _options.visible:
			show_main()
		else:
			close()
		get_viewport().set_input_as_handled()


## Not over another pause, nor where Start means retry (defeat, the end).
func can_open() -> bool:
	if _open or get_tree().paused:
		return false
	if arena != null and arena.state == ArenaController.EncounterState.DEFEATED:
		return false
	return slice == null or not slice.is_finished()


func open() -> void:
	if not can_open():
		return
	_open = true
	get_tree().paused = true
	_mouse_before = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_root.visible = true
	_refresh_support()
	show_main()


func close() -> void:
	if not _open:
		return
	_open = false
	_root.visible = false
	get_tree().paused = false
	Input.mouse_mode = _mouse_before


func is_open() -> bool:
	return _open


## Inside the game shell: "back to the title" shows, and restarting asks the shell.
func set_hosted(hosted: bool) -> void:
	_hosted = hosted
	(_main.get_node(^"ToTitle") as Button).visible = hosted


func is_hosted() -> bool:
	return _hosted


## Shows the chapter's Apoyo on the main page (F8 task 6).
func set_support(support: SupportLedger) -> void:
	_support = support
	_refresh_support()


func show_main() -> void:
	_options.visible = false
	_main.visible = true
	_resume.grab_focus()


func show_options() -> void:
	_main.visible = false
	_options.visible = true
	_options.refresh()
	_options.focus()


func is_showing_options() -> bool:
	return _open and _options.visible


func _connect() -> void:
	_resume.pressed.connect(close)
	(_main.get_node(^"Settings") as Button).pressed.connect(show_options)
	(_main.get_node(^"Restart") as Button).pressed.connect(_restart)
	(_main.get_node(^"ToTitle") as Button).pressed.connect(_to_title)
	(_main.get_node(^"Quit") as Button).pressed.connect(_quit)
	_options.back_pressed.connect(show_main)


func _refresh_support() -> void:
	var label := _main.get_node(^"Support") as Label
	label.visible = _support != null
	if _support != null:
		label.text = SupportText.summary(_support)


func _restart() -> void:
	close()
	if _hosted:
		restart_requested.emit()
	else:
		get_tree().reload_current_scene()


func _to_title() -> void:
	close()
	title_requested.emit()


func _quit() -> void:
	get_tree().quit()

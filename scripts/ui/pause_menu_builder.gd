class_name PauseMenuBuilder
extends RefCounted
## Builds the pause menu's controls (F4 task 8): a dimmed screen, the main list and the
## settings page (SettingsPage, F8 task 2). PauseMenu wires them; every text goes through
## tr(). "ToTitle" and the Apoyo show only when the level runs inside the game shell (F8
## tasks 2 and 6); "ToHub" only in a mission played from the hub (F10 task 3).

const TITLE := Color(0.95, 0.75, 0.35)
const DIM := Color(0.7, 0.65, 0.58)
## Main list buttons: node name and text.
const BUTTONS: Dictionary = {
	"Resume": &"PAUSE_RESUME",
	"Settings": &"PAUSE_SETTINGS",
	"Restart": &"PAUSE_RESTART",
	"ToHub": &"PAUSE_TO_HUB",
	"ToTitle": &"PAUSE_TO_TITLE",
	"Quit": &"PAUSE_QUIT",
}


static func build(parent: Node) -> Control:
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(root)
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.6)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var pages: VBoxContainer = MenuParts.panel(root, 560.0)
	pages.add_child(_main())
	pages.add_child(SettingsPage.new())
	return root


static func _main() -> VBoxContainer:
	var main := VBoxContainer.new()
	main.name = "Main"
	main.add_theme_constant_override(&"separation", 14)
	main.add_child(MenuParts.label(&"PAUSE_TITLE", 34, TITLE))
	# The chapter's Apoyo (F8 task 6); filled by PauseMenu inside the game shell.
	var support: Label = MenuParts.label(&"", 20, DIM)
	support.name = "Support"
	support.visible = false
	main.add_child(support)
	for node_name: String in BUTTONS:
		var button: Button = MenuParts.button(BUTTONS[node_name] as StringName)
		button.name = node_name
		main.add_child(button)
	(main.get_node(^"ToTitle") as Button).visible = false
	(main.get_node(^"ToHub") as Button).visible = false
	main.add_child(MenuParts.version_label(DIM))
	return main

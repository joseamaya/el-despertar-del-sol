extends SceneTree
## One-off builder: run with `godot --headless --path . -s <this file>`.
## Keep it OUTSIDE the repo (scratchpad). Run `godot --headless --path . --import` first
## so new class_names are registered.

var _root: Node


func _own(node: Node, parent: Node) -> void:
	parent.add_child(node)
	node.owner = _root


func _init() -> void:
	# 1. Tuning resource with default values.
	var tuning := ExampleTuning.new()
	var err: Error = ResourceSaver.save(tuning, "res://resources/tuning/example.tres")
	print("tuning=", err)
	tuning = load("res://resources/tuning/example.tres") as ExampleTuning

	# 2. Scene: root + children, every child owned by the root.
	var root := Node3D.new()
	root.name = "Example"
	_root = root
	var component := ExampleComponent.new()
	component.name = "ExampleComponent"
	component.tuning = tuning
	_own(component, root)

	# 3. Instancing another scene inside: GEN_EDIT_STATE_INSTANCE, owner on its root only.
	#   var inst := (load("res://scenes/x.tscn") as PackedScene).instantiate(
	#       PackedScene.GEN_EDIT_STATE_INSTANCE)
	#   _own(inst, root)

	var packed := PackedScene.new()
	packed.pack(root)
	print("scene=", ResourceSaver.save(packed, "res://scenes/example/example.tscn"))
	root.free()
	quit()

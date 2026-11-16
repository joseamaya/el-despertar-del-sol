extends SceneTree
## Audits a scene (skill godot-scene-audit): what it costs to draw, what it collides
## with, which scripts it runs and the coupling smells in them. Instantiates the scene,
## waits a few frames so runtime builders (SectorLevel, StyleVignette…) finish, then
## prints a summary and writes JSON.
##
##   godot --headless --path . -s res://tools/scene_audit.gd -- \
##       --scene=res://scenes/levels/carmenca.tscn --out=/tmp/audit.json

## Budgets from docs/rendimiento/2026-11-carmenca-proxy.md (F3).
const MAX_DRAW_CALLS: int = 350
const MAX_PRIMITIVES: int = 1_200_000
const MAX_SHADOW_LIGHTS: int = 3
const MAX_SCRIPT_LINES: int = 300
## Coupling smells (AGENTS.md: no get_node paths to other systems, no chained get_parent).
const SMELLS: Dictionary = {
	"get_node con ruta hacia arriba": "get_node\\(\\s*[\"']\\.\\./",
	"$ con ruta hacia arriba": "\\$[\"']?\\.\\./",
	"get_parent() encadenado": "get_parent\\(\\)\\.get_parent\\(\\)",
	"búsqueda por grupo": "get_nodes_in_group\\(",
	"ruta absoluta /root": "[\"']/root/",
}

var _scene_path: String = ""
var _out: String = "user://scene_audit.json"
var _frames: int = 10
var _scene: Node


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--scene="):
			_scene_path = arg.trim_prefix("--scene=")
		elif arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		elif arg.begins_with("--frames="):
			_frames = arg.trim_prefix("--frames=").to_int()
	if _scene_path.is_empty():
		push_error("scene_audit: pass --scene=res://...")
		quit(1)
		return
	_scene = (load(_scene_path) as PackedScene).instantiate()
	root.add_child(_scene)


func _process(_delta: float) -> bool:
	_frames -= 1
	if _frames > 0:
		return false
	var report: Dictionary = audit(_scene)
	report["scene"] = _scene_path
	_print(report)
	var file: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "  "))
	return true


## Everything measured on an instantiated scene. Static so tests can call it.
static func audit(scene: Node) -> Dictionary:
	var classes: Dictionary = {}
	var draw: Dictionary = {
		"surfaces": 0, "with_shadow": 0, "primitives": 0, "multimesh_instances": 0
	}
	var lights: Dictionary = {"total": 0, "shadow": 0}
	var physics: Dictionary = {"bodies": 0, "shapes": 0, "shape_types": {}}
	var empty: Array[String] = []
	var scripts: Dictionary = {}
	var nodes: Array[Node] = [scene]
	nodes.append_array(scene.find_children("*", "", true, false))
	for node: Node in nodes:
		var cls: String = node.get_class()
		classes[cls] = int(classes.get(cls, 0)) + 1
		_measure_draw(node, draw)
		_measure_light(node, lights)
		_measure_physics(node, physics, empty, scene)
		if node.get_script() != null:
			var path: String = (node.get_script() as Script).resource_path
			if path.begins_with("res://") and not path.begins_with("res://addons/"):
				scripts[path] = true
		if (
			node.get_class() == "Node3D"
			and node.get_script() == null
			and node.get_child_count() == 0
		):
			empty.append("Node3D vacío: %s" % scene.get_path_to(node))
	var script_report: Array = []
	for path: String in scripts.keys():
		script_report.append(_scan_script(path))
	var draw_calls: int = int(draw["surfaces"]) + int(draw["with_shadow"])
	return {
		"nodes": nodes.size(),
		"classes": classes,
		"draw": draw,
		"draw_calls_estimate": draw_calls,
		"lights": lights,
		"physics": physics,
		"empty_or_broken": empty,
		"scripts": script_report,
		"over_budget":
		{
			"draw_calls": draw_calls > MAX_DRAW_CALLS,
			"primitives": int(draw["primitives"]) > MAX_PRIMITIVES,
			"shadow_lights": int(lights["shadow"]) > MAX_SHADOW_LIGHTS,
		},
	}


static func _measure_draw(node: Node, draw: Dictionary) -> void:
	var mesh: Mesh = null
	var copies: int = 1
	var geo := node as GeometryInstance3D
	if node is MeshInstance3D:
		mesh = (node as MeshInstance3D).mesh
	elif node is MultiMeshInstance3D:
		var mm: MultiMesh = (node as MultiMeshInstance3D).multimesh
		if mm != null:
			mesh = mm.mesh
			copies = mm.instance_count
			draw["multimesh_instances"] = int(draw["multimesh_instances"]) + copies
	if mesh == null or geo == null or not (node as Node3D).visible:
		return
	var surfaces: int = mesh.get_surface_count()
	draw["surfaces"] = int(draw["surfaces"]) + surfaces
	if geo.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
		draw["with_shadow"] = int(draw["with_shadow"]) + surfaces
	var tris: int = 0
	for s: int in surfaces:
		var arrays: Array = mesh.surface_get_arrays(s)
		# Generated meshes are not indexed: ARRAY_INDEX is null, not an empty array.
		var index: Variant = arrays[Mesh.ARRAY_INDEX]
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var count: int = (index as PackedInt32Array).size() if index != null else verts.size()
		tris += count / 3
	draw["primitives"] = int(draw["primitives"]) + tris * copies


static func _measure_light(node: Node, lights: Dictionary) -> void:
	var light := node as Light3D
	if light == null:
		return
	lights["total"] = int(lights["total"]) + 1
	if light.shadow_enabled:
		lights["shadow"] = int(lights["shadow"]) + 1


static func _measure_physics(
	node: Node, physics: Dictionary, broken: Array[String], scene: Node
) -> void:
	if node is CollisionObject3D:
		physics["bodies"] = int(physics["bodies"]) + 1
	var shape := node as CollisionShape3D
	if shape == null:
		return
	if shape.shape == null:
		broken.append("CollisionShape3D sin forma: %s" % scene.get_path_to(node))
		return
	physics["shapes"] = int(physics["shapes"]) + 1
	var types: Dictionary = physics["shape_types"]
	var cls: String = shape.shape.get_class()
	types[cls] = int(types.get(cls, 0)) + 1


static func _scan_script(path: String) -> Dictionary:
	var text: String = FileAccess.get_file_as_string(path)
	var lines: PackedStringArray = text.split("\n")
	var smells: Array[String] = []
	for label: String in SMELLS.keys():
		var regex := RegEx.create_from_string(SMELLS[label])
		for i: int in lines.size():
			if regex.search(lines[i]) != null:
				smells.append("%s:%d %s" % [path, i + 1, label])
	return {
		"path": path,
		"lines": lines.size(),
		"too_long": lines.size() > MAX_SCRIPT_LINES,
		"smells": smells,
	}


static func _print(r: Dictionary) -> void:
	var draw: Dictionary = r["draw"]
	print("SCENE_AUDIT ", r["scene"])
	print(
		(
			"  nodos: %d · draw calls estimadas: %d (presupuesto %d) · primitivas: %d (presupuesto %d)"
			% [
				r["nodes"],
				r["draw_calls_estimate"],
				MAX_DRAW_CALLS,
				draw["primitives"],
				MAX_PRIMITIVES
			]
		)
	)
	print("  luces: %s · física: %s" % [r["lights"], r["physics"]])
	for s: Dictionary in r["scripts"]:
		if s["too_long"] or not (s["smells"] as Array).is_empty():
			print("  script %s: %d líneas %s" % [s["path"], s["lines"], s["smells"]])
	for e: String in r["empty_or_broken"]:
		print("  ", e)
	print("  fuera de presupuesto: ", r["over_budget"])

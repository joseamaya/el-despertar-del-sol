class_name DebugArenaMix
extends Node
## Test-scene helper (F9 task 11): keys 1–4 pick who fights in the combat arena and start
## again: three club warriors, one lancer alone, a lancer with two clubs, three lancers.
## Lives only in test scenes.

## Per composition: one letter per spawn point used, L lancer or P club.
const MIXES: Array[String] = ["PPP", "L", "LPP", "LLL"]
const NAMES: Array[String] = [
	"3 guerreros de porra",
	"1 lancero solo",
	"1 lancero y 2 de porra",
	"3 lanceros",
]

@export var arena: ArenaController

var mix: int = 0
var _points: Array[Node3D] = []
var _label: Label


func _ready() -> void:
	assert(arena != null, "DebugArenaMix needs the arena.")
	_points = arena.spawn_points.duplicate()
	var layer := CanvasLayer.new()
	add_child(layer)
	_label = Label.new()
	_label.position = Vector2(16, 16)
	layer.add_child(_label)
	_show()


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo:
		handle_key(key.physical_keycode)


## Public so tests can drive it without input events. Returns true if the key was used.
func handle_key(keycode: Key) -> bool:
	var index: int = keycode - KEY_1
	if index < 0 or index >= MIXES.size():
		return false
	choose(index)
	return true


## Sets composition `index` and restarts the encounter with it.
func choose(index: int) -> void:
	mix = index
	var letters: String = MIXES[index]
	var used: Array[Node3D] = []
	var lancers := PackedInt32Array()
	for i: int in mini(letters.length(), _points.size()):
		used.append(_points[i])
		if letters[i] == "L":
			lancers.append(i)
	arena.spawn_points = used
	arena.lancer_spawns = lancers
	arena.reset_encounter()
	_show()


func _show() -> void:
	_label.text = "%s · teclas 1–4: %s" % [NAMES[mix], " / ".join(NAMES)]

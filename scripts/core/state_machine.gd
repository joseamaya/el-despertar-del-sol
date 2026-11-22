class_name StateMachine
extends Node
## Node-based state machine: every child State is a state, named after its node.
## `context` is whatever the states drive (e.g. the EnemyController).

signal state_changed(from: StringName, to: StringName)

@export var initial_state: State
@export var context: Node

var current: State
var _states: Dictionary = {}


func _ready() -> void:
	for child: Node in get_children():
		var state: State = child as State
		if state != null:
			state.machine = self
			_states[StringName(state.name)] = state
	assert(initial_state != null, "StateMachine needs an initial state.")
	current = initial_state
	current.enter(&"")


func _physics_process(delta: float) -> void:
	tick(delta)


## Runs the current state once and follows the transition it asks for.
func tick(delta: float) -> void:
	if current == null:
		return
	var next: StringName = current.physics_update(delta)
	if next != &"":
		transition_to(next)


func transition_to(state_name: StringName) -> void:
	var next: State = _states.get(state_name) as State
	assert(next != null, "Unknown state: %s" % state_name)
	if next == current:
		return
	var previous: StringName = current_name()
	current.exit()
	current = next
	current.enter(previous)
	state_changed.emit(previous, state_name)


func current_name() -> StringName:
	return StringName(current.name) if current != null else &""


func has_state(state_name: StringName) -> bool:
	return _states.has(state_name)


## Reseeds every state, each with its own seed derived from `value`.
func seed_rng(value: int) -> void:
	var offset: int = 0
	for state: State in _states.values():
		state.seed_rng(value + offset)
		offset += 1

class_name State
extends Node
## One state of a StateMachine (GDD §7: one node per state). Override what you need.
## physics_update() returns the name of the next state, or &"" to stay.

var machine: StateMachine


func enter(_previous: StringName) -> void:
	pass


func exit() -> void:
	pass


func physics_update(_delta: float) -> StringName:
	return &""


## Reseeds whatever randomness the state uses (reproducible tests). Override if any.
func seed_rng(_value: int) -> void:
	pass

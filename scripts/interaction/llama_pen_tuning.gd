class_name LlamaPenTuning
extends Resource
## The family's llamas in their corral (F4 task 6): how many, their wool, and how they
## trot out once freed.

@export_range(1, 6, 1) var count: int = 3
## Llamas stand within this share of the corral radius.
@export_range(0.1, 0.9, 0.05) var spread: float = 0.5
@export
var wool: Array[Color] = [Color(0.9, 0.86, 0.78), Color(0.55, 0.38, 0.24), Color(0.32, 0.24, 0.18)]
@export var dark: Color = Color(0.2, 0.16, 0.13)
## Once freed they leave through the opening (+Z) and stop this far from the corral.
@export_range(2.0, 40.0, 0.5, "suffix:m") var trot_distance: float = 7.0
@export_range(0.5, 15.0, 0.5, "suffix:s") var trot_time: float = 4.0
## Up-and-down of the trot.
@export_range(0.0, 0.3, 0.01, "suffix:m") var bob: float = 0.06
@export var seed: int = 5

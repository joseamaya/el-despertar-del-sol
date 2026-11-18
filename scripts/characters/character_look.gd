class_name CharacterLook
extends Resource
## How a character looks on the shared mannequin (F4 task 10, DECISIONS/0012): the
## colours of its two surfaces and the pieces it wears (unku, llauto, orejeras, manta…).
## A placeholder until the project's own character model (GDD §10.5).

@export var skin: Color = Color(0.55, 0.36, 0.24)
## The mannequin's joint surface: reads as clothing under the pieces.
@export var joints: Color = Color(0.18, 0.12, 0.1)
@export var parts: Array[LookPart] = []

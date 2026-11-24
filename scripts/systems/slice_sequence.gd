class_name SliceSequence
extends Resource
## The vertical slice as data (F4 task 2): its steps in order. One .tres per sector.

@export var steps: Array[SliceStep] = []
## Banner of each act (SliceStep.Act order), instead of the slice's (F8 task 8: the
## prologue is not Carmenca). An empty key shows no banner. Empty list: the slice's.
@export var act_titles: Array[StringName] = []

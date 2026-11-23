class_name GuardPoseTuning
extends Resource
## The guard pose drawn over the animation while blocking (F6 task 4): the free animation
## pack has no block clip (DECISIONS/0007), so the arms are turned by these rotations,
## added to whatever pose the animation gives. Degrees, as Euler angles (X, Y, Z) in each
## bone's own frame.

@export var bones: PackedStringArray = PackedStringArray()
@export var rotations_deg: PackedVector3Array = PackedVector3Array()

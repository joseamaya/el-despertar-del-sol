class_name TargetReticle
extends Control
## Ring drawn around the locked target's aim point on screen.

@export var radius: float = 26.0
@export var thickness: float = 3.0
@export var color: Color = Color(1.0, 0.85, 0.3)


func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, color, thickness, true)
	for i: int in 4:
		var dir := Vector2.RIGHT.rotated(TAU * i / 4.0 + PI / 4.0)
		draw_line(dir * (radius - 6.0), dir * (radius + 6.0), color, thickness, true)

class_name PostureTuning
extends Resource
## Posture of one kind of enemy (GDD §6.4): fills with hits and parries; when full the
## enemy is stunned and can be executed.

## Must be > 0. Basic warrior: tuned in F2 task 8 (GDD §6.5: 2–3 parries to break).
@export_range(1.0, 1000.0, 1.0) var max_posture: float = 100.0
## Posture drains this fast once nothing has added to it for `decay_delay`.
@export_range(0.0, 200.0, 0.5, "suffix:/s") var decay_per_second: float = 15.0
@export_range(0.0, 10.0, 0.05, "suffix:s") var decay_delay: float = 1.5
## How long a broken posture stays broken (stun and execution window).
@export_range(0.1, 10.0, 0.05, "suffix:s") var broken_duration: float = 2.0

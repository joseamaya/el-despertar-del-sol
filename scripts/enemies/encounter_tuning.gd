class_name EncounterTuning
extends Resource
## Encounter rules (GDD §6.6, §7.1): how many enemies may attack at once and how they
## spread around the player.

## Attack tokens available at once (GDD: two).
@export_range(1, 8, 1) var max_attackers: int = 2
## Minimum time between two grants, so tokens do not start attacks on the same frame.
@export_range(0.0, 3.0, 0.05, "suffix:s") var grant_spacing: float = 0.5
## Enemies closer than this push each other apart while circling.
@export_range(0.0, 6.0, 0.1, "suffix:m") var separation_distance: float = 2.2
## Strength of that push relative to circling speed.
@export_range(0.0, 3.0, 0.05) var separation_strength: float = 2.0

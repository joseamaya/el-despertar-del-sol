class_name ResponseTuning
extends Resource
## How the player's presses are kept and how early a dodge may cut an attack (F6 task 7).
## The diagnosis (docs/fases/F6-diagnostico-respuesta.md) found that 96–97 % of dodges
## were dropped while trading blows, and every blow taken came right after one.

## A dodge pressed while it cannot start (attacking, already dodging) waits this long.
@export_range(0.0, 1.0, 0.01, "suffix:s") var dodge_buffer: float = 0.3
## An attack pressed during a dodge or a stun waits this long.
@export_range(0.0, 1.0, 0.01, "suffix:s") var attack_buffer: float = 0.3
## A dodge may cut an attack in its windup, not only in its recovery.
@export var dodge_cancels_windup: bool = true

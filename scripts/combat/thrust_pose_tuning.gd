class_name ThrustPoseTuning
extends Resource
## The spear thrust drawn over the animation (F9 task 8): the free pack has no thrust clip,
## so the bones listed are turned on top of the animated pose, like the guard (F6). Two
## poses: `drawn`, the spear pulled back at the end of the windup, and `thrust`, the arms
## out at the hit. Degrees, as Euler angles (X, Y, Z) in each bone's own frame.
## The spear is not tied to the hand's turn: it sits in the hand but always points along
## the warrior's front, pitched by `rest_pitch_deg` (tip up) and level at the thrust.

@export var bones: PackedStringArray = PackedStringArray()
@export var drawn_deg: PackedVector3Array = PackedVector3Array()
@export var thrust_deg: PackedVector3Array = PackedVector3Array()
## Share of the active window the arms take to reach the thrust (the rest, held out).
@export_range(0.05, 1.0, 0.05) var strike_share: float = 0.4
## The hand that holds the spear.
@export var hand_bone: StringName = &"RightHand"
## Tip up while not thrusting (degrees); the thrust levels it to `thrust_pitch_deg`.
@export_range(-30.0, 60.0, 1.0, "suffix:°") var rest_pitch_deg: float = 20.0
@export_range(-30.0, 60.0, 1.0, "suffix:°") var thrust_pitch_deg: float = 0.0
## Where the fist closes, in the hand bone's own frame (the bone starts at the wrist), so
## the shaft runs through the fist instead of past the wrist.
@export var grip_offset: Vector3 = Vector3(0.0, 0.08, 0.0)

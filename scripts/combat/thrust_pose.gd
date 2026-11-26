class_name ThrustPose
extends SkeletonModifier3D
## The spear thrust (F9 task 8, `docs/capitulo-1.md` §7.5): while `combat` runs an attack
## marked `thrust`, turns the bones of `tuning` over the animated pose. Windup: from rest to
## drawn back. Active: out to the thrust in `strike_share` of the window, then held.
## Recovery: back to rest. Lives under the Skeleton3D. If `spear` is set, it is placed in
## the fist (`grip_offset` from the hand bone) every frame, pointing along `body`'s front
## (-Z), so turning the arms moves the spear forward and back without tilting it.

@export var tuning: ThrustPoseTuning
@export var combat: EnemyCombat
## Optional: the spear (its +X axis is the shaft, the hand at its origin) and the body whose
## front it follows.
@export var spear: Node3D
@export var body: Node3D

var _bone_ids: PackedInt32Array = PackedInt32Array()
var _drawn: Array[Quaternion] = []
var _thrust: Array[Quaternion] = []
var _hand: int = -1


func _ready() -> void:
	assert(tuning != null and combat != null, "ThrustPose: tuning and combat.")
	assert(spear == null or body != null, "ThrustPose: a spear needs the body.")
	if spear != null:
		spear.top_level = true
	assert(
		(
			tuning.bones.size() == tuning.drawn_deg.size()
			and tuning.bones.size() == tuning.thrust_deg.size()
		),
		"ThrustPose: one drawn and one thrust turn per bone."
	)
	rebuild()


## Reads the bones and turns from `tuning` again (after changing it).
func rebuild() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	_bone_ids.clear()
	_drawn.clear()
	_thrust.clear()
	if skeleton == null:
		return
	_hand = skeleton.find_bone(tuning.hand_bone)
	for i: int in tuning.bones.size():
		var id: int = skeleton.find_bone(tuning.bones[i])
		assert(id >= 0, "ThrustPose: no bone %s." % tuning.bones[i])
		_bone_ids.append(id)
		_drawn.append(Quaternion.from_euler(tuning.drawn_deg[i] * (PI / 180.0)))
		_thrust.append(Quaternion.from_euler(tuning.thrust_deg[i] * (PI / 180.0)))


## Where the arms are along the thrust at `elapsed` real seconds into `attack`: 0 at rest,
## 1 drawn back, 2 thrust out. On the way back (recovery) the value goes from 2 down to 0
## straight to rest, without passing through "drawn" (see `turn`).
static func progress(elapsed: float, attack: AttackData, strike_share: float) -> float:
	var windup: float = AttackRules.real(attack.windup_end, attack)
	var active: float = AttackRules.real(attack.active_end, attack)
	var recovery: float = AttackRules.real(attack.recovery_end, attack)
	if elapsed < windup:
		return _ease(elapsed / maxf(windup, 0.001))
	if elapsed < active:
		var strike: float = (active - windup) * strike_share
		return 1.0 + _ease((elapsed - windup) / maxf(strike, 0.001))
	if elapsed < recovery:
		return 2.0 * (1.0 - _ease((elapsed - active) / maxf(recovery - active, 0.001)))
	return 0.0


## The turn of one bone at `value` of `progress` (in recovery, straight back to rest).
static func turn(
	value: float, drawn: Quaternion, thrust: Quaternion, recovering: bool
) -> Quaternion:
	if recovering:
		return Quaternion.IDENTITY.slerp(thrust, value * 0.5)
	if value <= 1.0:
		return Quaternion.IDENTITY.slerp(drawn, value)
	return drawn.slerp(thrust, value - 1.0)


## The current value of `progress`, or 0 when no thrust is running.
func current_progress() -> float:
	var attack: AttackData = combat.get_current()
	if attack == null or not attack.thrust:
		return 0.0
	return progress(combat.get_elapsed(), attack, tuning.strike_share)


## Pitch of the spear (degrees, tip up) at `value` of `progress`.
static func spear_pitch(value: float, rest_deg: float, thrust_deg: float) -> float:
	return lerpf(rest_deg, thrust_deg, clampf(value - 1.0, 0.0, 1.0)) if value > 1.0 else rest_deg


func _process_modification_with_delta(_delta: float) -> void:
	var value: float = current_progress()
	if value > 0.001:
		_turn_bones(value)
	_place_spear(value)


func _turn_bones(value: float) -> void:
	var recovering: bool = combat.get_phase() == AttackRules.Phase.RECOVERY
	var skeleton: Skeleton3D = get_skeleton()
	for i: int in _bone_ids.size():
		var id: int = _bone_ids[i]
		var extra: Quaternion = turn(value, _drawn[i], _thrust[i], recovering)
		skeleton.set_bone_pose_rotation(id, skeleton.get_bone_pose_rotation(id) * extra)


func _place_spear(value: float) -> void:
	if spear == null or _hand < 0:
		return
	var skeleton: Skeleton3D = get_skeleton()
	var grip: Vector3 = skeleton.get_bone_global_pose(_hand) * tuning.grip_offset
	var hand: Vector3 = skeleton.global_transform * grip
	var front: Vector3 = -body.global_basis.z
	front.y = 0.0
	if front.length_squared() < 0.0001:
		return
	front = front.normalized()
	var pitch: float = deg_to_rad(
		spear_pitch(value, tuning.rest_pitch_deg, tuning.thrust_pitch_deg)
	)
	var side: Vector3 = front.cross(Vector3.UP).normalized()
	var shaft: Vector3 = front.rotated(side, pitch)
	var up: Vector3 = side.cross(shaft).normalized()
	spear.global_transform = Transform3D(Basis(shaft, up, shaft.cross(up)), hand)


static func _ease(t: float) -> float:
	return smoothstep(0.0, 1.0, clampf(t, 0.0, 1.0))

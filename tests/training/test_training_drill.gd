extends GdUnitTestSuite
## Vicaquirao's training at the lookout (F4 task 12a): after the opening he spars with
## Cusi; real blocks count; his blows do no harm and he never falls; the four drills lead
## to the first skirmish with the standing Vicaquirao back in place.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const TIME_SCALE: float = 2.0

var _runner: GdUnitSceneRunner
var _slice: SliceDirector
var _drill: TrainingDrill
var _talk: DialoguePlayer
var _player: PlayerController
var _npc: Node3D


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_slice = _runner.find_child("SliceDirector") as SliceDirector
	_drill = _runner.find_child("TrainingDrill") as TrainingDrill
	_talk = _runner.find_child("DialoguePlayer") as DialoguePlayer
	_player = _runner.find_child("Player") as PlayerController
	_npc = _runner.find_child("Vicaquirao") as Node3D
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(10)


func after_test() -> void:
	Engine.time_scale = 1.0
	Input.action_release(&"block")


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


## Plays the talk until the next drill starts.
func _to_drill() -> void:
	for i: int in 20:
		while _talk.is_playing():
			_talk.advance()
		await _frames(2)
		if _slice.flow.current().kind == SliceStep.Kind.DRILL:
			return


func test_training_follows_the_opening_and_he_spars() -> void:
	await _to_drill()
	var step: SliceStep = _slice.flow.current()
	assert_int(step.drill).is_equal(SliceStep.Drill.BLOCK)
	assert_bool(_drill.is_training()).is_true()
	assert_bool(_npc.visible).is_false()
	assert_object(_drill.trainer().perception.target).is_same(_player)
	assert_int(_slice.objective_count()).is_equal(step.count)


func test_real_blocks_count_and_his_blows_do_no_harm() -> void:
	await _to_drill()
	var health := _player.get_node(^"Health") as HealthComponent
	var lock := _player.get_node(^"LockOn") as LockOnController
	Engine.time_scale = TIME_SCALE
	# Unguarded first: he lands blows that do nothing.
	var hits: Array[int] = [0]
	(_player.get_node(^"Hurtbox") as Hurtbox).hit_received.connect(
		func(_i: HitInfo) -> void: hits[0] += 1
	)
	for i: int in 900:
		if hits[0] > 0:
			break
		await _frames(1)
	assert_int(hits[0]).is_greater(0)
	assert_float(health.current).is_equal(health.get_maximum())
	# Then guarded, facing him: two blocks end the drill. Lock-on only picks what the
	# camera sees, so turn the view to him first (blocks count from the front only).
	var rig := _runner.find_child("CameraRig") as CameraController
	var to: Vector3 = _drill.trainer().global_position - _player.global_position
	rig.yaw = atan2(-to.x, -to.z)
	rig.snap_to_target()
	await _frames(2)
	if not lock.is_locked():
		lock.toggle_lock()
	assert_bool(lock.is_locked()).is_true()
	Input.action_press(&"block")
	for i: int in 1500:
		if _slice.flow.current().kind != SliceStep.Kind.DRILL:
			break
		await _frames(1)
	Input.action_release(&"block")
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.DIALOGUE)


func test_hits_count_and_he_never_falls() -> void:
	await _to_drill()
	var trainer: EnemyController = _drill.trainer()
	# Jump to the striking drill.
	while _slice.flow.current().drill != SliceStep.Drill.HIT:
		var step: SliceStep = _slice.flow.current()
		if step.kind == SliceStep.Kind.DRILL:
			for i: int in step.count:
				_drill.count(step.drill)
		await _to_drill()
	var info := HitInfo.new()
	info.damage = trainer.health.get_maximum() * 2.0
	(trainer.get_node(^"Hurtbox") as Hurtbox).receive_hit(info)
	await _frames(2)
	assert_bool(trainer.is_dead()).is_false()
	assert_int(_drill.remaining()).is_equal(_slice.flow.current().count - 1)


func test_after_the_four_drills_he_stands_again_and_the_slice_goes_on() -> void:
	var drills: Array[int] = []
	for i: int in 4:
		await _to_drill()
		var step: SliceStep = _slice.flow.current()
		drills.append(step.drill)
		for k: int in step.count:
			_drill.count(step.drill)
		await _frames(2)
	while _talk.is_playing():
		_talk.advance()
	await _frames(3)
	assert_array(drills).is_equal(
		[SliceStep.Drill.BLOCK, SliceStep.Drill.PARRY, SliceStep.Drill.EVADE, SliceStep.Drill.HIT]
	)
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.ENCOUNTER)
	assert_bool(_drill.is_training()).is_false()
	assert_bool(_npc.visible).is_true()

class_name PickupProps
extends Node3D
## Things lying on the ground at layout markers that the player picks up (F10 task 4b:
## the three bundles of mission A). One kit piece stands at each marker until the
## InteractionPoint there is used; then it goes. The level's other props are merged into
## one mesh, so they cannot be taken one by one: these are apart.

signal picked(marker: StringName)

@export var level: SectorLevel
@export var interaction: InteractionPoint
## The markers (layout points) where a piece lies, in order.
@export var markers: Array[StringName] = []
@export var kind: KitProps.Kind = KitProps.Kind.BUNDLE
## Seed of the first piece; each next one adds one, so they differ.
@export var seed: int = 600

var _pieces: Dictionary[StringName, MeshInstance3D] = {}


func _ready() -> void:
	assert(level != null and interaction != null, "PickupProps: parts.")
	interaction.interacted.connect(_on_interacted)
	# After the level has built the sector and its markers.
	_build.call_deferred()


## Whether the piece at `marker` still lies there.
func is_lying(marker: StringName) -> bool:
	return _pieces.has(marker)


func _build() -> void:
	for i: int in markers.size():
		var marker: StringName = markers[i]
		var piece: MeshInstance3D = SectorBuilder.add_mesh(
			self,
			String(marker),
			KitProps.piece(kind, seed + i, level.palette),
			level.palette,
			Vector3.ZERO
		)
		piece.global_position = level.marker_position(marker)
		piece.rotation.y = float(i) * 1.3
		_pieces[marker] = piece


func _on_interacted(marker: StringName) -> void:
	if not _pieces.has(marker):
		return
	_pieces[marker].queue_free()
	_pieces.erase(marker)
	picked.emit(marker)

class_name SliceAudioTuning
extends Resource
## What the slice sounds like (F4 task 9, GDD §11): the wind all along, one piece of music
## in some acts, the Chanca pututu when a zone first sees the player, and the vision of the
## huaca heard muffled.

@export_group("Ambience")
@export var ambience: AudioStream
@export_range(-60.0, 6.0, 0.5, "suffix:dB") var ambience_db: float = -12.0

@export_group("Music")
@export var music: AudioStream
@export_range(-60.0, 6.0, 0.5, "suffix:dB") var music_db: float = -10.0
## Acts with music (SliceStep.Act values); in the others it fades out.
@export var music_acts: Array[SliceStep.Act] = [SliceStep.Act.OPENING, SliceStep.Act.ENDING]
@export_range(0.1, 10.0, 0.1, "suffix:s") var music_fade_in: float = 2.0
@export_range(0.1, 10.0, 0.1, "suffix:s") var music_fade_out: float = 4.0

@export_group("Pututu")
## Blown when this encounter zone first sees the player (GDD §12.3: the Chanca attack call).
@export var pututu: AudioStream
@export_range(0, 10, 1) var pututu_zone: int = 3
@export_range(-60.0, 6.0, 0.5, "suffix:dB") var pututu_db: float = -4.0
## Sounds a slice step carries (SliceStep.sound, e.g. the far pututus at the end).
@export_range(-60.0, 6.0, 0.5, "suffix:dB") var step_sound_db: float = -10.0

@export_group("Vision")
## The huaca's vision is heard through this low-pass filter on the Master bus.
@export_range(100.0, 20000.0, 10.0, "suffix:Hz") var vision_cutoff_hz: float = 700.0
@export_range(0.1, 5.0, 0.1, "suffix:s") var vision_muffle_time: float = 1.0

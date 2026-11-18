class_name KitAnimals
extends RefCounted
## Animals built by script, low-poly like the rest of the kit (F4 task 6). They stand on
## y = 0 with the head towards +Z.


## A llama: four legs, a body, a long neck, head, ears and tail. About 1.9 m to the ears.
static func llama(wool: Color, dark: Color, seed: int) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := LowPolyMesh.begin()
	var j: float = 0.02
	for x: float in [-0.15, 0.15]:
		for z: float in [-0.38, 0.38]:
			LowPolyMesh.add_box(st, Vector3(x, 0.4, z), Vector3(0.12, 0.8, 0.12), dark, rng, j)
	LowPolyMesh.add_box(st, Vector3(0.0, 1.0, 0.0), Vector3(0.5, 0.45, 1.1), wool, rng, j)
	LowPolyMesh.add_box(st, Vector3(0.0, 1.42, 0.48), Vector3(0.2, 0.75, 0.22), wool, rng, j)
	LowPolyMesh.add_box(st, Vector3(0.0, 1.84, 0.58), Vector3(0.2, 0.22, 0.38), wool, rng, j)
	for x: float in [-0.06, 0.06]:
		LowPolyMesh.add_box(st, Vector3(x, 2.0, 0.5), Vector3(0.05, 0.16, 0.05), dark, rng, j)
	LowPolyMesh.add_box(st, Vector3(0.0, 1.12, -0.6), Vector3(0.1, 0.2, 0.1), wool, rng, j)
	return LowPolyMesh.end(st)

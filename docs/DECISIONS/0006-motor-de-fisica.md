# 0006 · Motor de física 3D: GodotPhysics3D

**Fecha:** 2026-11-13 · **Estado:** propuesta (pendiente de decisión del desarrollador)

## Contexto
El GDD (§13.1) pide evaluar Jolt frente a Godot Physics en F1. El proyecto tenía el motor
en `DEFAULT`, que en Godot 4.7.2 resuelve a **GodotPhysics3D** (comprobado: una caída de
prueba da posiciones idénticas con `DEFAULT` y `GodotPhysics3D`, distintas con Jolt).
Con `DEFAULT` el motor podría cambiar con una actualización de Godot sin que nadie lo decida.

Este juego no es de física de objetos: lo que importa es el movimiento de personajes
(`CharacterBody3D`), la detección de golpes (`Area3D`) y los rayos (cámara, percepción).

## Medición
Herramienta: `tools/physics_compare.gd`, mismo escenario con cada motor (vía `override.cfg`),
3 repeticiones, i7-13700. Resultados idénticos entre repeticiones salvo el coste.

**Detección de golpes** (caja de 0,25 m cruzando una cápsula de cuerpo, ~780 golpes por velocidad):

| Velocidad del arma | Golpes perdidos GodotPhysics3D | Golpes perdidos Jolt | Detectados 1 frame tarde (Jolt) | Atraviesan sin tocar (ambos) |
| --- | --- | --- | --- | --- |
| 10 m/s | 0 | 0 | 1,1 % | 0 |
| 20 m/s | 0 | 0 | 1,1 % | 0 |
| 30 m/s | 0 | 3 (0,4 %) | 0,5 % | 3 (0,4 %) |
| 45 m/s | 0 | 4 (0,5 %) | 0,3 % | 20 (2,6 %) |

«Perdido» = en ese frame la geometría se solapaba y el motor no lo informó. Los fallos de
Jolt son roces de esquina; la causa probable es el radio convexo con el que Jolt redondea
las cajas. GodotPhysics3D no perdió ninguno.

**Movimiento del personaje:** idéntico con los dos motores en todos los casos medidos:
coronar una rampa de 20° (3 frames en el aire, sin rebote), mantenerse en 40° (0 m de
deslizamiento), deslizarse en 50°, bajar un escalón de 0,25 m y deslizarse a lo largo de
un muro en diagonal (3,54 m/s, el valor ideal, sin vibración).

**Coste** (30 personajes y 300 rayos por frame, sin render):

| Motor | Frame medio | p95 |
| --- | --- | --- |
| GodotPhysics3D | 1,05 ms | 1,44 ms |
| Jolt | 1,14 ms | 1,48 ms |

## Decisión (propuesta)
Fijar **GodotPhysics3D** explícitamente en `project.godot`. Detecta todos los golpes
medidos, mueve a los personajes igual que Jolt y es algo más barato con esta carga.

## Consecuencias
- `tests/physics/test_hit_detection.gd` comprueba que el motor sigue fijado y que los
  golpes a 20 m/s se detectan siempre.
- **Para F2 (independiente del motor):** a partir de ~30 m/s una parte de los golpes cruza
  el cuerpo entre dos frames sin solaparse nunca (0,4 % a 30 m/s, 2,6 % a 45 m/s). El
  sistema de Hitbox debe cubrir el recorrido entre frames (p. ej. `ShapeCast3D` del
  frame anterior al actual) o limitar la velocidad de la cabeza del champi.
- Bajar un escalón de 0,25 m deja al personaje 7 frames en el aire con ambos motores
  pese al `floor_snap_length` de 0,3 m. No afecta a la decisión; se revisa si se nota en juego.
- Jolt sería preferible si el juego necesitara muchos cuerpos rígidos apilados o ragdolls
  (fuera del alcance del slice). Revisar si eso cambia.

## Revisar
Al actualizar de versión menor de Godot o si se añaden físicas de objetos.

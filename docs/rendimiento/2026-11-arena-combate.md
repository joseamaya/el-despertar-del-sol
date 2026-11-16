# Rendimiento de la arena de combate con 3–4 enemigos (F2, tarea 12)

**Fecha:** 2026-11-16 · **Equipo de referencia:** el del desarrollador (Intel UHD 770,
«Intel(R) Graphics (RPL-S)»), renderer Mobile, salida 1920×1080, vsync desactivado.

## Resumen
- **Cumple con mucho margen.** Con 4 enemigos en combate continuo: 223 FPS de media al
  83 % y **ningún frame por encima de 16,7 ms** en ninguna configuración.
- **La IA y el combate no son el cuello de botella.** La física (que incluye IA, navegación,
  barridos de golpes y percepción) cuesta 1,5–2,2 ms de media por tick, frente a 1,3 ms con
  la arena tranquila. Con 6 enemigos sigue en 2,1 ms.
- **Draw calls: 69–86**, muy por debajo del presupuesto de 350 que fijó la medición de
  Carmenca.
- **Ojo:** la arena es greybox (cajas CSG y personajes con un solo material). El arte final
  costará más en GPU; el margen que importa para F3 es el de la medición de Carmenca
  (`2026-11-carmenca-proxy.md`), no este.

## Cómo se midió
`tools/scene_benchmark.gd` sobre `scenes/tests/combat_arena.tscn`, 3 s de calentamiento y
20 s de captura:

```bash
godot --path . -s res://tools/scene_benchmark.gd -- \
    --scene=res://scenes/tests/combat_arena.tscn --fight --enemies=4 --scale3d=0.833
```

- `--fight` añade `ArenaFightDriver` (`tools/arena_fight_driver.gd`): el jugador espera en
  guardia frente a los guerreros y lanza un golpe ligero cada 2,5 s; nadie muere ni es
  ejecutado, así que el combate dura toda la captura (ataques, bloqueos, hitstop, sonido,
  sacudida de cámara, director de fichas).
- `--enemies=N` añade puntos de aparición antes de cargar la arena (hasta 6).
- Los tiempos de frame salen del reloj real: durante el hitstop `Engine.time_scale` encoge
  el `delta` y daba FPS imposibles.
- Una pasada por configuración: ninguna cifra sorprendió.

## Resultados

| Enemigos | 3D | FPS medio | 1 % bajo | p99 frame | Frames > 16,7 ms | Física media / máx. | Draw calls medio / máx. | Primitivas máx. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 3 | 100 % | 199,8 | 137,7 | 6,7 ms | 0 % | 1,7 / 3,3 ms | 69 / 80 | 419 k |
| 3 | 83 % | 228,0 | 151,6 | 6,2 ms | 0 % | 1,6 / 2,4 ms | 68 / 76 | 398 k |
| 3 | 75 % | 249,2 | 159,3 | 5,6 ms | 0 % | 1,9 / 7,3 ms | 69 / 80 | 419 k |
| 4 | 100 % | 188,6 | 129,2 | 7,1 ms | 0 % | 2,2 / 6,7 ms | 73 / 82 | 492 k |
| **4** | **83 %** | **223,1** | 127,3 | 6,7 ms | **0 %** | 1,7 / 2,5 ms | 75 / 86 | 513 k |
| 4 | 75 % | 246,8 | 152,9 | 5,9 ms | 0 % | 1,5 / 2,0 ms | 74 / 86 | 513 k |
| 6 (estrés) | 83 % | 209,1 | 140,0 | 6,7 ms | 0 % | 2,1 / 6,6 ms | 86 / 94 | 700 k |
| 3, sin combate | 83 % | 243,4 | 163,9 | 5,6 ms | 0 % | 1,3 / 3,2 ms | 94 / 98 | 265 k |

«Física» es `Performance.TIME_PHYSICS_PROCESS`: tiempo de CPU de cada tick de física
(60/s), que incluye los `_physics_process` de IA y combate. Los picos de 6–7 ms son
aislados y no producen frames lentos. Sin combate hay más draw calls porque la cámara mira
la arena desde la entrada, con más pirca en pantalla.

El JSON de cada pasada incluye además `process_ms_avg` (`TIME_PROCESS`), que en Godot
contiene la espera de sincronización con el render: no sirve como coste de scripts y no
se usa aquí.

## Conclusiones
1. F2 no necesita optimizar nada para 3–4 enemigos.
2. Cada guerrero añade unas 70 k primitivas (el modelo UAL sin LOD). Con muchos enemigos a
   la vista en F3 conviene vigilarlo junto al presupuesto de 1,2 M de Carmenca.
3. La herramienta queda lista para repetir la medición en cada cierre de fase.

## No verificado
- En Windows (el equipo de referencia es el mismo, pero solo se midió en Linux).
- Con el arte final: esta arena no tiene texturas, vegetación ni luces extra.

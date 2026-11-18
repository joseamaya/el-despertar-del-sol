# Rendimiento del recorrido de Carmenca (F3, tarea 10)

**Fecha:** 2026-11-17 · **Equipo de referencia:** el del desarrollador (Intel UHD 770,
«Intel(R) Graphics (RPL-S)»), renderer Mobile, salida 1920×1080, vsync desactivado.

## Resumen
- **Ya cumplía los 60 FPS, pero no el presupuesto de primitivas.** Con la configuración de
  la tarea 9, recorrer Carmenca daba 96,9 FPS de media al 83 % y 0,12 % de frames lentos,
  pero llegaba a **1,59 M primitivas** en las terrazas (presupuesto: 1,2 M).
- **Lo que más pesaba era la sombra del sol.** Con 4 cascadas, cada cascada vuelve a dibujar
  la escena. Con 2 cascadas: 1,00 M primitivas y +14 % de FPS.
- **Valores adoptados:** `shadow_splits = 2` en la paleta A y `side_cell = 8.0` en el
  layout de Carmenca (laderas inaccesibles con celdas de 8 m). Resultado: **116,6 FPS de
  media, 0 % de frames lentos y 0,89 M primitivas.** En el peor caso (combate con 3
  guerreros en el paso) da 109,6 FPS y 0,03 % de frames lentos.
- **El terreno sigue proyectando sombra.** Quitarla ahorra otras 0,3 M primitivas, pero
  cambia el aspecto con el sol rasante. No hace falta para cumplir; queda como reserva para
  el arte final (`ground_shadow = false`).

## Cómo se midió
`tools/scene_benchmark.gd` con `--walk`: `SectorWalkDriver` (`tools/sector_walk_driver.gd`)
recorre el camino entero (~365 m) con la cámara de juego, que mira hacia el siguiente punto
del camino. Los enemigos se retiran al empezar cada encuentro. El informe sale por tramos,
según el marcador más cercano: mirador, terrazas, huaca, casas y paso.

```bash
godot --path . -s res://tools/scene_benchmark.gd -- \
    --scene=res://scenes/levels/carmenca.tscn --walk --scale3d=0.833
```

El peor caso de combate usa `--fight-zone=3 --seconds=30`: `ArenaFightDriver` pelea contra
los 3 guerreros del paso.

- **Una opción cada vez.** Cada variante cambia el `.tres`, mide y lo restaura.
- **Equipo en reposo.** Antes de cada pasada se espera a que la CPU esté libre. Si durante
  la pasada aparece otro proceso pesado (había otra batería de pruebas en marcha en el
  equipo), la pasada se descarta y se repite.
- **Las primitivas no dependen de la carga** (son las mismas en cada pasada); los FPS sí.
  Una primera pasada con el equipo cargado dio 1,08 % de frames lentos con la misma
  configuración que, en reposo, da 0,12 %.
- **Una pasada por configuración.** El recorrido produce unos 7 000–9 000 frames.

## Resultados del recorrido (3D al 83 %)

| Variante | FPS medio | 1 % bajo | p99 frame | Frames > 16,7 ms | Primitivas máx. | Draw calls máx. |
| --- | --- | --- | --- | --- | --- | --- |
| Tarea 9 (4 cascadas, celdas de 2 m) | 96,9 | 59,1 | 14,4 ms | 0,12 % | 1,59 M | 108 |
| Terreno sin sombra | 115,6 | 74,7 | 12,0 ms | 0,05 % | 1,27 M | 107 |
| 2 cascadas | 110,3 | 75,1 | 12,5 ms | 0 % | 1,00 M | 108 |
| **2 cascadas + celdas de 8 m (adoptada)** | **116,6** | **83,3** | **11,4 ms** | **0 %** | **0,89 M** | **112** |
| Las tres opciones | 125,6 | 75,5 | 12,3 ms | 0,01 % | 0,80 M | 109 |

Las celdas de 8 m solas (con 4 cascadas) quitan 0,17 M primitivas (1,59 → 1,42 M). Se
midieron antes de corregir el inyector de variantes, así que sus FPS no se dan.

**Por tramos, configuración adoptada:**

| Tramo | FPS medio | 1 % bajo | Frames > 16,7 ms | Primitivas máx. |
| --- | --- | --- | --- | --- |
| Mirador | 98,1 | 74,7 | 0 % | 0,85 M |
| Terrazas | 102,4 | 83,2 | 0 % | 0,89 M |
| Huaca | 114,5 | 89,0 | 0 % | 0,80 M |
| Casas | 124,3 | 95,3 | 0 % | 0,65 M |
| Paso | 130,5 | 86,2 | 0 % | 0,59 M |

El mirador y las terrazas son los tramos caros: desde ahí la cámara ve todo el sector y el
valle de fondo.

## Otras escalas y el combate

| Pasada | 3D | FPS medio | 1 % bajo | Frames > 16,7 ms | Primitivas máx. | Draw calls máx. |
| --- | --- | --- | --- | --- | --- | --- |
| Recorrido, tarea 9 | 75 % | 102,8 | 70,5 | 0,04 % | 1,59 M | 108 |
| Recorrido, adoptada | 75 % | 117,7 | 73,3 | 0,03 % | 0,89 M | 112 |
| Combate en el paso, tarea 9 | 83 % | 93,3 | 65,4 | 0,11 % | 1,31 M | 117 |
| **Combate en el paso, adoptada** | **83 %** | **109,6** | **72,5** | **0,03 %** | **0,89 M** | **123** |

Con la configuración adoptada, bajar al 75 % apenas cambia nada: la GPU ya no es el límite
(la sombra del sol era lo que dependía de la geometría, no de los píxeles).

## F4, tarea 6b: el paso con los comuneros

Combate en el paso con 3 chancas y 2 comuneros (`--fight-zone=3 --slice-flag=llamas_freed`)
frente a solo los 3 chancas, 83 %, pasadas alternadas. Medido con otros procesos usando la CPU,
así que vale la comparación, no las cifras absolutas.

| Pasada | FPS medio | 1 % bajo | Frames > 16,7 ms | Primitivas máx. | Draw calls máx. | Física (ms) |
| --- | --- | --- | --- | --- | --- | --- |
| 3 chancas (1) | 116,9 | 67,5 | 0,00 % | 0,94 M | 138 | 3,8 |
| + 2 comuneros (1) | 118,7 | 55,9 | 0,01 % | 1,02 M | 162 | 7,0 |
| 3 chancas (2) | 112,7 | 49,2 | 0,02 % | 0,94 M | 138 | 8,7 |
| + 2 comuneros (2) | 108,8 | 41,1 | 0,05 % | 1,02 M | 162 | 11,2 |

Los dos comuneros añaden unas 0,08 M primitivas y 24 draw calls; el FPS medio no cambia más
que el ruido entre pasadas. Sigue dentro del criterio de F3 (más de 60 FPS, menos de 1 % de
frames lentos, menos de 1,2 M primitivas). La física sube unos 3 ms: hay que repetir la medida
con la máquina en reposo en el cierre de F4 (tarea 12).

## F4, tarea 10: atuendos de los personajes

El mismo combate del paso con comuneros, ahora con los atuendos (unku, llauto, orejeras y
manta, unas 4–6 piezas por personaje). Medido con la máquina muy cargada (carga media 15),
así que solo vale la comparación.

| Pasada | FPS medio | 1 % bajo | Frames > 16,7 ms | Primitivas máx. | Draw calls máx. |
| --- | --- | --- | --- | --- | --- |
| Sin atuendos (tarea 6b, 1) | 118,7 | 55,9 | 0,01 % | 1,02 M | 162 |
| Sin atuendos (tarea 6b, 2) | 108,8 | 41,1 | 0,05 % | 1,02 M | 162 |
| Con atuendos (1) | 110,5 | 62,9 | 0,00 % | 1,03 M | 194 |
| Con atuendos (2) | 117,4 | 47,5 | 0,02 % | 1,02 M | 190 |

Los atuendos añaden unos 30 draw calls (cada pieza es una malla con su material) y casi
ninguna primitiva; el FPS no cambia más que el ruido. Si hiciera falta, las piezas de cada
hueso se pueden fusionar en una malla con color por vértice.

## Coste de la luz (pendiente de la tarea 7)
- **Sombras del sol:** con 4 cascadas costaban 0,59 M primitivas (37 % del total) y 13 FPS
  de media frente a 2 cascadas.
- **Luz de relleno y glow:** la paleta A los tiene apagados (decisión de la tarea 7), así
  que no cuestan nada.

## Conclusiones
1. **Criterio de la tarea 10 cumplido** con la configuración adoptada, en el recorrido y
   en el peor combate: más de 60 FPS de media, menos de 1 % de frames lentos, menos de
   1,2 M primitivas y menos de 350 draw calls.
2. **Qué hay que comprobar a ojo:** con 2 cascadas, las sombras a media distancia
   (30–100 m) son algo más blandas. Las laderas de 8 m solo afectan a terreno donde no se
   puede pisar.
3. **Reserva para el arte final:** quitar la sombra del terreno (−0,1 M con la
   configuración adoptada) y bajar la distancia de sombra.

Datos en bruto: los JSON de cada pasada no se versionan; se reproducen con los comandos de
arriba.

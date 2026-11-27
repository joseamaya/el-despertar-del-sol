# Rendimiento · sitio en el centro (F10, tarea 1)

**Fecha:** 2026-11-27 · **Renderer:** Mobile · **3D:** 83 %.

- **Primitivas y draw calls:** medidos fuera de pantalla (`xvfb-run`, llvmpipe).
- **FPS:** medidos en la GPU de referencia (al final).

## Qué cambió

1. **El maniquí se importa con niveles de detalle** (`ual1_standard.glb.import`,
   `meshes/generate_lods=true`). Cada personaje tiene 13,7 k triángulos y en F1 se importó
   sin LOD: lejos costaba lo mismo que de cerca, también en las sombras.
2. **Las 121 casas de fondo son casas lejanas** (`KitBuildings.far_house`): bloques de
   zócalo y muro, puerta oscura, hastiales y una capa de ichu con su cumbrera. Unos 70
   triángulos por casa en vez de 1.176.
3. **La ropa de cada personaje es una sola malla** con *skin* (`CharacterOutfit`): cada
   pieza va pegada a su hueso, como antes, pero se dibuja en una llamada en vez de una por
   pieza.

## Medido

Sonda: 360° desde la salida de Cusi, máximo del giro. Benchmark: 25 s andando y girando
(`--hold=move_forward,look_right`).

| | Primitivas máx. | Draw calls máx. |
| --- | --- | --- |
| Centro, sonda, antes | 1,12 M | 261 |
| Centro, sonda, solo con LOD | 0,92 M | 261 |
| Centro, sonda, después | **0,79 M** | **174** |
| Centro, benchmark, antes | 1,18 M | 293 |
| Centro, benchmark, después | **0,85 M** | **203** |
| Prólogo, benchmark, antes (cierre de F9) | 0,42 M | 132 |
| Prólogo, benchmark, después | 0,30 M | 84 |

**De dónde salían, antes** (sonda, quitando una parte cada vez): las casas de fondo,
0,14 M; los 17 cuerpos, 0,23 M; las sombras, 0,44 M; la ropa, unos 100 draw calls.

## Lo que dice

- **Hay margen para el Apoyo:** unas 0,35 M primitivas hasta el límite de 1,2 M.
- **Draw calls: 203 en el peor frame,** justo por encima del objetivo de 200; 174 en la
  sonda. Lo que queda son sobre todo las sombras (64 llamadas).
- **No se nota** en las capturas (`docs/img/f10/sitio-*.jpg`, arriba o a la izquierda
  antes, abajo o a la derecha después).

## FPS en la GPU de referencia

Medido con ventana el mismo día (Intel RPL-S integrada), con `tools/scene_benchmark.gd`, igual
que en el cierre de F9 (`2026-11-cierre-f9.md`).

**La máquina no estaba en reposo:** había Chrome, pytest y node en marcha, con una carga
media de 10–18 en las dos primeras pasadas del centro, y de 2,5 en las dos últimas. Por eso
solo cuentan las pasadas con poca carga.

| Escena | Cierre de F9 | Ahora |
| --- | --- | --- |
| Centro, andando y girando | 92,7 · 92,3 FPS; p99 13,5 ms | **116,7 · 114,3 FPS**; p99 11,3–12,2 ms (con carga 10–18: 69,8 y 91,1) |
| Centro, recorriendo el camino | 99,2 FPS | **111,9 FPS** (con carga) |
| Prólogo | 157,0 · 158,8 FPS | **189,1 FPS** (con carga) |
| Carmenca, partida completa | 122,6 FPS · 1,12 M · 201 draw calls | **123,8 FPS · 0,97 M · 172 draw calls** |

- **El centro gana un 25 %** (de 92 a 115 FPS) y no tiene ningún frame de más de 16,7 ms.
- **El frame de 3 s de la construcción** no salió en las dos últimas pasadas (el peor, 25 ms).
  Puede ser la caché de shaders ya caliente; no se da por resuelto. La carga dentro del
  capítulo se mide en la tarea 3.
- **Carmenca** baja de 1,12 M a 0,97 M primitivas, con los mismos FPS.

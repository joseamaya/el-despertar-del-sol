# Rendimiento · sitio en el centro (F10, tarea 1)

**Fecha:** 2026-11-27 · **Equipo:** este equipo, **fuera de pantalla** (`xvfb-run`, llvmpipe):
las primitivas y los draw calls valen; los FPS, no · **Renderer:** Mobile · **3D:** 83 %.

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

## No medido

- **FPS en la GPU de referencia:** hace falta abrir ventana.
- **Carmenca:** no se pasó el benchmark. Le afectan los mismos cambios (LOD y ropa) y sus
  pruebas pasan.

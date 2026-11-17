# F3 · Escenario de Carmenca — nota de cierre

**Fechas:** 2026-11-16 – 2026-11-17 · **Estado:** cerrada

Criterio de salida confirmado por el desarrollador el 2026-11-17.

## Criterio de salida (GDD §15)

«Recorrible a 60 FPS y reconocible andino»:

- **Recorrible a 60 FPS.** Un bot recorre los ~365 m del sector con la cámara de juego
  (`--walk`). Da 118,8 FPS de media al 83 %, con 0,21 % de frames lentos, 0,89 M primitivas
  y 113 draw calls. El combate con 3 guerreros en el paso da 124 FPS y 0 % de frames
  lentos. El desarrollador recorrió el sector entero tras las tareas 4 y 11.
- **Reconocible andino.** Prueba de la tarea 11 (`docs/fases/F3-prueba-andina.md`): el
  desarrollador la dio por superada el 2026-11-17 («está genial»), después de dos ajustes:
  - el color de vértices en sRGB;
  - laderas con tope de 8 m en lugar de paredes de 100 m.

## Qué se hizo

| Tarea | PR | Resultado |
| --- | --- | --- |
| 1 · Decisiones previas | #26 | `0010`: arte generado por script, sin Blender MCP; licencias del escenario |
| 2 · Medición en reposo (deuda de F2) | #27 | Proxy de Carmenca: 73 FPS al 83 %, 79 al 75 %; sin regresión frente a F1 |
| 3 · Guía visual | #28 | Viñeta de estilo y tres paletas; elegida la A · amanecer cálido |
| 4 · Blockout | #29 | Sector de 240 × 340 m: terrazas con escaleras, camino, huaca, 3 zonas de encuentro, límites |
| 5 · Kit modular v1 | #30 | 12 piezas por script (pirca, adobe, techo de ichu, huaca, corrales, peñas…); skill `godot-scene-audit` |
| 6 · Paisaje lejano | #31 | Valle con parcelas, Cusco en 7 barrios, 10 apus, 4 columnas de humo |
| 7 · Luz de amanecer | #32 | Sol rasante con sombras, ambiente cálido, fondo con sol cocido |
| 8 · Vegetación | #33 | 13.445 matas de ichu y arbustos en MultiMesh por parcelas, con rango de visibilidad |
| 9 · Combate en el escenario | #34 | Navmesh al cargar, 2 + 2 + 3 guerreros con el `ArenaController` de F2; el build abre Carmenca |
| 10 · Rendimiento del recorrido | #35 | Benchmark por tramos; 2 cascadas de sombra y laderas de 8 m bajan de 1,59 a 0,89 M primitivas |
| 11 · Prueba «reconocible andino» | #36 | Capturas fijas, color de vértices en sRGB, laderas con tope; puertas rectangulares |
| 12 · Cierre | este PR | Esta nota |

## Verificación (commit `35f6a13`)

- **Pruebas:** **297/297** en verde (gdUnit4). gdformat y gdlint sin errores (`scripts`,
  `tests`, `tools`).
- **CI de `main`** en verde (lint, pruebas, exportación).
- **Builds exportados en local:** Linux (76 MB) y Windows (112 MB). El de Linux arranca
  en headless.
- **El build abre Carmenca** (`scenes/main.tscn` → `carmenca.tscn`).

## Rendimiento (UHD 770, renderer Mobile, salida a 1080p)

Recorrido completo de Carmenca. Cada pasada se hizo esperando a que la CPU estuviera libre,
y se repetía si aparecía carga externa:

| Pasada | 3D al | FPS medio | 1 % bajo | Frames > 16,7 ms | Primitivas máx. | Draw calls máx. |
| --- | --- | --- | --- | --- | --- | --- |
| Recorrido | 100 % | 96,4 | 44,3 | 4,8 % | 0,89 M | 113 |
| **Recorrido** | **83 %** | **118,8** | 60,7 | **0,21 %** | 0,89 M | 113 |
| Recorrido | 75 % | 126,0 | 80,1 | 0,10 % | 0,89 M | 113 |
| **Combate en el paso (3 guerreros)** | **83 %** | **124,0** | 84,2 | **0 %** | 0,89 M | 127 |

**Comparación:**
- Al empezar F3, el proxy de Carmenca (sin arte, sin fondo, sin vegetación) daba 73 FPS al
  83 %. El sector real, completo, da 119.
- Respecto a la tarea 10 (116,6 FPS) no hay caída: los ajustes de la tarea 11 no cuestan.
- **Al 100 % no se cumple** (4,8 % de frames lentos): por eso se juega al 83 %
  (`DECISIONS/0005`).

Detalle en `docs/rendimiento/2026-11-carmenca-recorrido.md`.

## Decisiones de la fase

- `0010` aceptada: arte del escenario generado por script; sin Blender MCP.
- `0011` aceptada: color de vértices en sRGB; nuevo `ground_mix` en la paleta.
- **Rendimiento:** 2 cascadas de sombra en la paleta A; laderas inaccesibles con celdas de
  8 m.
- **Prueba andina:**
  - laderas con tope de 8 m y lomas suaves;
  - puertas rectangulares;
  - techos de ichu y apus se quedan como están hasta el arte final.

## Herramientas, skills y recursos

- **Skill nueva:** `godot-scene-audit` (tarea 5). `godot-component` gana la nota sobre
  MultiMesh en headless.
- **Herramientas nuevas:**
  - `tools/scene_audit.gd`;
  - `tools/capture_style.gd` y `tools/capture_sector.gd` (capturas fijas);
  - `tools/sector_walk_driver.gd`, más `--walk` y `--fight-zone` en `scene_benchmark.gd`.
- **Recursos de terceros:** ninguno nuevo. Todo el escenario se genera por script.

## Deudas heredadas de F2

| Deuda | Estado |
| --- | --- |
| 1 · Repetir la medición de Carmenca en reposo | Resuelta: tarea 2 |
| 2 · Primitivas por personaje (~70 k) | Resuelta para el slice: el combate del paso con 3 guerreros se queda en 0,89 M |
| 3 · Animaciones Pro | Sin cambios: ningún enemigo ni ataque nuevo las ha pedido |
| 4 · Escalón de 0,25 m | Resuelta en las terrazas: escaleras con rampa de colisión (tarea 4) |
| 5 · Ideas surgidas al jugar | Sin decidir: no eran del escenario |
| 6 · Publicar avances | Pendiente |
| 7 · Mando físico y Windows | Pendiente |

## Duración

**Estimada: 3 semanas. Real: 2 días.** No hubo que recortar alcance.

## Lo aprendido

- **Las capturas desde la cámara del jugador encuentran lo que no enseñan el catálogo ni
  la viñeta.** Las paredes de 100 m y el tono de arena solo aparecieron al mirar cuesta
  arriba desde el camino. Las 7 tomas fijas se repiten igual antes y después de cada
  ajuste.
- **Un color de paleta solo es fiable si el material lo lee igual.** Los colores cocidos
  como color de vértice se leían como lineales y salían pálidos.
- **Medir rendimiento exige un equipo libre y comprobarlo en cada pasada.** Navegadores,
  otra sesión con su batería de pruebas y la espera de disco estropearon varias tandas. El
  vigilante que espera a la CPU libre y repite las pasadas contaminadas hizo fiables las
  cifras.
- **Las sombras del sol eran el mayor coste del escenario.** Con 4 cascadas, la escena se
  dibujaba varias veces: el 37 % de las primitivas.
- **Lo que no se puede probar en headless se separa en funciones puras.** En headless no se
  guardan las transformaciones de MultiMesh ni se dibuja nada; la colocación de plantas y
  rocas se prueba como datos.
- **Las aserciones de gdUnit4 son caras.** Una por vértice colgó la batería 45 minutos; se
  calcula el rango y se comprueba una vez.
- **Una opción mal escrita en un `.tres` falla en silencio.** Una propiedad antes de
  `script =` se descarta sin error. El benchmark ahora aborta si el recorrido no termina.

## No verificado

- **Mando físico y Windows:** el build de Windows se exporta, pero nadie lo ha ejecutado.
- **Otros equipos:** solo se ha medido en el de referencia.
- **Que no se pueda trepar la franja de 8 m con el mando:** las pruebas comprueban
  pendiente y altura; el desarrollador recorrió el sector sin encontrar un sitio.
- **Capturas antiguas:** las de `docs/img/guia-visual/` son anteriores al cambio a sRGB.

## Pasa a F4 · Integración del slice

1. **Entrada de orientación** en `HISTORICAL_REFERENCES.md`: la edita el desarrollador.
2. **Arte final:**
   - techos de ichu con espesor visible;
   - apus menos regulares;
   - reserva de rendimiento si hiciera falta: quitar la sombra del terreno (−0,1 M
     primitivas).
3. **Ideas de F2 sin decidir:**
   - evitación entre guerreros;
   - sprint manteniendo B;
   - enemigos que esperan a que el jugador se acerque.
4. **Animaciones Pro** (`0008`): volver a plantearlo si un enemigo o ataque nuevo lo pide.
5. **Navmesh al cargar** (80–350 ms): vigilarlo si F4 añade checkpoints o recargas.
6. **Publicar avances** (GDD §15): proponer la skill `devlog` cuando se quiera empezar.
7. **Mando físico y build de Windows:** probarlos antes de F5.

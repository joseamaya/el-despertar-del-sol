# F6 · Ajuste del combate — backlog

**Estado:** aprobado por el desarrollador el 2026-11-23.

- **Criterio de salida (GDD §15, `DECISIONS/0014`):** bloqueo fiable y legible, controles que
  responden, orientación, y una build lista para una nueva prueba con jugadores.
- **Estimación:** 2 semanas. Si se pasa de 3, se recorta alcance (ver «Qué se recorta
  primero»).

**Base:** `docs/fases/F5-analisis.md`. Las quejas que se repiten son:
- el bloqueo «no responde» (P2, O1 y la mayoría de los comentarios);
- la respuesta al atacar y esquivar (P1);
- la orientación (O1 y varios).

**Alcance:**
- que el bloqueo funcione como el jugador espera y se vea;
- que atacar y esquivar respondan;
- un indicador ligero hacia el objetivo;
- dejar lista la build `0.2-slice`, con probadores apalabrados para la próxima prueba.

**Fuera del alcance** (`0014`, puntos 3 y 4):
- más movimientos, combos o saltos (GDD §6.1 sin cambios);
- el armamento, los aliados del Apoyo, las llamas y la apertura «espectacular»;
- la dificultad del paso;
- el arte final;
- las deudas de presentación de F4 que no estorban al combate. Siguen en «Pasa a F6» de
  `F5-prueba-externa.md`.

**Deudas heredadas de F5:** `docs/fases/F5-prueba-externa.md`, sección «Pasa a F6».

| # | Tarea | Estado |
| --- | --- | --- |
| 1 | **Rendimiento en reposo de la build actual** (deuda de F5): 3 pasadas del slice completo con `--playthrough`, con la máquina en reposo, y la mediana en `docs/rendimiento/`. Es la referencia para comparar los cambios de F6. **Lo hace el agente; tú avisas de cuándo la máquina está libre**, porque se abre una ventana unos 15 min | Pendiente |
| 2 | **Diagnóstico del bloqueo:** un bot con el bloqueo mantenido, sin fijar objetivo y con lock-on, contra 1 y contra 3 guerreros. Mide qué parte de los golpes entra y por qué: fuera del arco de 120°, guardia rota por falta de resistencia (< 15) o bloqueo suspendido mientras se ataca. Entrega las cifras y 2–3 opciones de arreglo, con su efecto en la sensación del combate | Hecha: #75, `F6-diagnostico-bloqueo.md`; el 68–79 % de los golpes que entraban lo hacían por fuera del arco; ninguna guardia rota |
| 3 | **Bloqueo fiable:** aplicar la opción que elijas en la tarea 2. Por ejemplo: que al bloquear Cusi se oriente hacia quien ataca, ampliar el arco (`DefenseTuning.block_arc_deg`) o ajustar el coste o la recuperación. Los valores viven en sus `.tres` y se registran en `combat-tuning-log.md`. Pruebas de que los golpes que hoy entran por el lado ahora se bloquean | Hecha: #76 (opciones 1 + 3: la guardia encara al golpe y el entrenamiento enseña a fijar objetivo). Sin fijar objetivo, de 48–79 % de golpes que entran a 0 %. Probado por el desarrollador: «está excelente». Los efectos con 3 guerreros se quedan como están |
| 4 | **Bloqueo legible:** que se vea que estás bloqueando. El pack gratuito no trae pose de bloqueo (`0007`). Las opciones se presentan con capturas antes de implementar: pose procedural en los brazos, otro clip del pack o la versión Pro (9,99 USD, CC0; decisión y compra tuyas) | Hecha: destello con chispas al bloquear (#78) y huallcanca (rodela) en el brazo izquierdo, alzada al bloquear (`DECISIONS/0015`). Pendiente de que el desarrollador lo pruebe |
| 5 | **Golpe que atraviesa el bloqueo:** un sonido y un efecto distintos cuando un golpe entra con la guardia alzada (por el lado o sin resistencia), distintos de la guardia rota. Así el jugador entiende que no es un fallo. Con pruebas de las señales | **Recortada** por el desarrollador (2026-11-23). Con la guardia que encara al golpe (tarea 3), sin fijar objetivo ya no entra ningún golpe en los escenarios medidos, y el bloqueo ya se ve: escudo y destello (tarea 4). Queda como deuda para la próxima prueba si los jugadores no entienden por qué entra un golpe por la espalda |
| 6 | **Diagnóstico de la respuesta de ataque y esquiva:** medir en fotogramas cuánto tarda cada acción en verse desde la pulsación, y en qué momentos se rechaza una esquiva o un ataque. Hoy la esquiva no cancela un ataque hasta su recuperación: unos 0,4 s comprometido con un golpe ligero. Entrega las cifras y las opciones de ajuste, con el GDD §6.5 | Hecha: `F6-diagnostico-respuesta.md`. A ritmo normal se pierde el 96–97 % de las esquivas (por estar atacando o sin resistencia) y todos los golpes recibidos llegan tras una esquiva perdida; se pierde el 17–50 % de los ataques |
| 7 | **Respuesta de ataque y esquiva:** aplicar los ajustes que elijas en la tarea 6 con la skill `combat-tuning` (por ejemplo, poder esquivar durante la anticipación, o una ventana de búfer distinta). Con pruebas y registro en `combat-tuning-log.md` | Hecha: búfer de esquiva y ataque (0,3 s), la esquiva corta la anticipación, aviso de resistencia en la barra y recuperación tras 0,3 s (antes 0,6 s). Con 1 guerrero, las esquivas perdidas pasan del 87 % al 0 %; con 3, del 81 % al 26 %. Probado por el desarrollador: «está todo correcto» |
| 8 | **Orientación:** un indicador ligero hacia el objetivo de los pasos que piden ir a un sitio (`REACH`, `INTERACT`, `RITE`). Por ejemplo, un marcador en el borde de la pantalla que se desvanece al acercarse; no una flecha permanente. Las opciones se presentan con capturas antes de implementar | Hecha: marcador dorado sobre el destino del paso (huaca, familia, llamas, final o la próxima zona de combate), con la distancia en metros y una flecha en el borde cuando queda fuera de la vista. Se oculta en combate, en diálogos y a menos de 6 m. Elegido entre marcador y brújula con capturas |
| 9 | **Probadores apalabrados** (en paralelo desde el inicio): conseguir 5–10 personas que se comprometan a jugar la `0.2-slice` y rellenar el formulario. Tú decides el canal. Si quieres usar publicaciones, ahora toca proponer la skill `devlog` (GDD §16.5). El agente prepara los textos y el material con imágenes reales | Pendiente |
| 10 | **Prueba del desarrollador:** juegas la build con los cambios y confirmas que el bloqueo es fiable y legible, que los controles responden y que te orientas. Es la evidencia del criterio de salida; si algo no convence, se itera en las tareas 3–8 | Pendiente |
| 11 | **Build `0.2-slice`:** versión en el menú, pre-release pública con los zips de Windows y Linux, y guía y encuesta actualizadas. La encuesta se pide también a quien no termine. Se comprueba en Windows y, si hay uno disponible, con mando | En curso: versión `0.2-slice` y guía `F6-guia-prueba.md`. La release se publica tras la prueba del desarrollador (tarea 10) y la medición de rendimiento (tarea 1) |
| 12 | **Cierre de F6** con `phase-gate` | Pendiente |

## Orden propuesto

- **Semana 1:**
  - 1 (referencia de rendimiento);
  - 2 → 3 → 4 → 5 (bloqueo);
  - 9 en paralelo.
- **Semana 2:**
  - 6 → 7 (respuesta);
  - 8 (orientación);
  - 10 → 11 → 12.

## Decisiones que se te piden por el camino

- **Tarea 3:** qué arreglo del bloqueo, a partir de las cifras de la tarea 2.
- **Tarea 4:** qué pose de bloqueo y, si es la Pro, la compra.
- **Tarea 7:** qué ajustes de respuesta.
- **Tarea 8:** qué indicador de orientación.
- **Tarea 9:** el canal para conseguir probadores.

## Qué se recorta primero

Si F6 se pasa de 3 semanas, en este orden:

1. **La tarea 8:** el indicador se reduce a resaltar el objetivo en el HUD al cambiar de paso.
2. **La tarea 5:** el golpe que atraviesa el bloqueo se queda con el sonido de golpe normal.
3. **La tarea 4:** la pose de bloqueo se queda como está.

Las tareas 2, 3, 6 y 7 no se recortan: son el núcleo de la decisión de `0014`.

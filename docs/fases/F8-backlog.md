# F8 · Base del capítulo — backlog

**Estado:** propuesta del agente, pendiente de aprobación del desarrollador.

- **Criterio de salida (GDD §15, `docs/capitulo-1.md` §8):** desde el menú, «Nueva partida»
  → prólogo → Carmenca → centro del Cusco (en bruto), y «Continuar» recupera la partida. En
  build exportada.
- **Estimación:** 3 semanas (2026-11-25 – 2026-12-15). Si se pasa de 4,5, se recorta alcance.

**Base:** `docs/capitulo-1.md`: estructura B (§3), sistemas (§6.2) y plan (§8). El juego
hoy es una sola escena (`main.tscn` → `carmenca.tscn`). Solo se guardan los ajustes, y al
reiniciar se recarga la escena.

**Alcance:** las tres piezas de base y el Apoyo:
- cambio de escena;
- partida guardada;
- estado del capítulo;
- Apoyo por ayllu.

Además, el recorrido prólogo → Carmenca → centro, **en bruto** (blockout, sin arte final).

**Fuera del alcance:**
- el arte del centro y el lancero (F9);
- las misiones de Apoyo jugables (F10): en F8 son puertas de prueba que se marcan como
  hechas;
- Susurpuquio (F11);
- cambiar la `0.2-slice` publicada, que sigue en prueba (`0016`).

| # | Tarea | Estado |
| --- | --- | --- |
| 1 | **Diseño técnico de la base:** cómo se reparten `SceneLoader` (cambio de escena), `SaveGame` (guardado), `ChapterState` (misiones y *flags*) y `SupportState` (Apoyo). Qué es autoload: AGENTS.md permite «guardado, eventos, ajustes», y se propone que el cambio de escena sea servicio global. Cómo pasan los *flags* del `SliceFlow` de cada nivel al capítulo y qué datos van en `.tres`. Con un diagrama, para que lo apruebes antes de programar | Pendiente |
| 2 | **Menú de título:** Nueva partida, Continuar (solo si hay partida), Ajustes y Salir. El menú de pausa añade «Volver al título». Todo con `tr()`. Pruebas | Pendiente |
| 3 | **Cambio de escena:** cargar un nivel con pantalla de carga y punto de entrada, y volver al centro. Medir el tiempo de carga en el equipo de referencia. Pruebas de ida y vuelta | Pendiente |
| 4 | **Estado del capítulo:** misiones definidas en `.tres` (bloqueada, disponible, en curso, hecha), condiciones como «2 de 3» y *flags* del capítulo. El `SliceDirector` de cada nivel informa al capítulo al terminar. Pruebas | Pendiente |
| 5 | **Partida guardada:** autoload `SaveGame` en `user://`, con formato versionado: capítulo, misiones, Apoyo, mejoras, códice y último punto de control. Se guarda al llegar a un punto de control y al volver al centro. Pruebas de guardar, cargar y versión antigua o archivo corrupto | Pendiente |
| 6 | **Apoyo por ayllu:** Neutral → Simpatizante → Aliado por ayllu y un total visible en el menú de pausa, con un aviso al subir. `SupportAllies` lee el Apoyo en lugar del *flag* `llamas_freed`. Valores en `.tres`. Pruebas | Pendiente |
| 7 | **Carmenca como nivel del capítulo:** el slice entra en el capítulo. Al terminar, la familia de las llamas cuenta como Apoyo y se vuelve al centro. El modo slice actual se conserva para las pruebas y el benchmark | Pendiente |
| 8 | **Prólogo y centro en bruto:** <br>– el prólogo: blockout de calles del Cusco con la corte que se va, a partir de `SectorLayout` y `SectorCrowd`; <br>– el centro: una plaza en bruto con Vicaquirao y tres «puertas» de misión de prueba que se marcan como hechas. <br>Sirve para recorrer el capítulo de punta a punta | Pendiente |
| 9 | **Skill `canon-check`** (`0017`): revisa textos, diálogos y entradas del códice contra `HISTORICAL_REFERENCES.md`. Se estrena con los textos del prólogo | Pendiente |
| 10 | **UAL2 Standard** (gratis, CC0): descarga con tu OK en el momento, registro en `ASSET_SOURCES.md` y comprobación de que sus clips encajan con el `BoneMap` actual. Solo se integra, todavía no se usa | Pendiente |
| 11 | **Build y prueba del desarrollador:** Nueva partida → prólogo → Carmenca → centro → Continuar tras cerrar el juego. En Linux y, si es posible, en Windows | Pendiente |
| 12 | **Prueba de la `0.2-slice` en paralelo** (`0016`): <br>– **tú:** la encuesta 0.2 (enlace) y la difusión; <br>– **el agente:** la guía y el registro en `F7-resultados.md`; <br>– se revisa la cláusula al cerrar | Pendiente · **tú** |
| 13 | **Cierre de F8** con `phase-gate` | Pendiente |

## Orden propuesto

- **Semana 1:** 1 → 2 → 3; 9 y 10 en los huecos.
- **Semana 2:** 4 → 5 → 6.
- **Semana 3:** 7 → 8 → 11 → 13.
- **12** en paralelo todo el tiempo.

## Decisiones que se te piden por el camino

- **Tarea 1:** el diseño técnico, sobre todo qué va como autoload.
- **Tarea 2:** el aspecto del menú de título, con capturas.
- **Tarea 10:** el OK a la descarga.
- **Tarea 11:** si el recorrido cumple el criterio.

## Qué se recorta primero

Si F8 se pasa de 4,5 semanas, en este orden:

1. **El prólogo** (tarea 8) se queda en un rótulo y se empieza en Carmenca.
2. **El aviso y la vista del Apoyo** (tarea 6): el estado existe, pero solo se ve en F10.
3. **La pantalla de carga** (tarea 3) se queda en un fundido a negro.

El guardado, el estado del capítulo y el cambio de escena no se recortan: son la base de
F9–F11.

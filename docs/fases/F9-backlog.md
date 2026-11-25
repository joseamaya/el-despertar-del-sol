# F9 · El centro y el lancero — backlog

**Estado:** aprobado por el desarrollador el 2026-11-25.

- **Criterio de salida (GDD §15, `docs/capitulo-1.md` §8):**
  - el centro del Cusco se recorre a 60 FPS y se reconoce andino;
  - pelear contra lanceros se siente bien.

  Lo prueba el desarrollador.
- **Estimación:** 3 semanas (2026-11-26 – 2026-12-16). Si se pasa de 4,5, se recorta alcance.

**Base:**
- **`docs/capitulo-1.md`:** estructura B (§3), sistemas (§6), arte (§7.1–7.3 y
  decisiones de §7.5) y plan (§8).
- **`DECISIONS/0017`:** los chancas llevan lanza larga.
- **La nota de F8,** sección «Pasa a F9».

**Lo que hay hoy:**
- **El centro** es la plaza de Carmenca heredada, vacía. Tiene cinco puertas de misión
  invisibles, no muestra ningún objetivo y Vicaquirao queda fuera del encuadre.
- **Los chancas** llevan porra (`guerrero_chanca.tres`, `Sword_Attack`).
- **Los exploradores** esperan en su sitio hasta detectar al jugador.

**Alcance:** dos bloques.
- **El centro:**
  - arte de plaza y calles;
  - gente;
  - Vicaquirao y Apo Mayta;
  - los 3 curacas;
  - que se entienda dónde se coge cada misión.
- **El lancero:**
  - estocada procedural;
  - IA de distancia;
  - tuning;
  - exploradores que patrullan.

**Fuera del alcance:**
- las misiones de Apoyo jugables (F10): las puertas siguen siendo de prueba;
- que la gente del centro cambie según el Apoyo (F10);
- el quipucamayoc, Susurpuquio, la música y los ambientes (F11);
- cambiar la `0.2-slice` publicada.

| # | Tarea | Estado |
| --- | --- | --- |
| 1 | **Referencia de rendimiento en reposo** (deuda de F8): medir el prólogo, el centro actual y Carmenca con el bot, con la máquina sin navegador ni Node. Es la base con la que se compara el centro nuevo. Te aviso antes de abrir ventanas | Pendiente |
| 2 | **Diseño del centro:** plano de plaza y calles, y dónde están Vicaquirao, Apo Mayta, los 3 curacas, las salidas de misión y la gente. Cómo se entiende qué hacer: un objetivo en pantalla y personajes con quienes se habla, en vez de puertas invisibles. **Canon:** un Cusco de 1438 modesto, de pirca, adobe e ichu, sin la cantería posterior (registro, línea 44); `canon-check` de la plaza. Con un plano y capturas del blockout para que decidas | Pendiente · **tú** decides |
| 3 | **Blockout del centro:** `centro_layout.tres` nuevo según el plano, con calles, plaza, desniveles y fondo del valle con la ciudad. Pruebas de que las casas quedan dentro del terreno y de que se llega a cada punto de misión | Pendiente |
| 4 | **Arte del centro:** casas y muros del kit en la disposición del Cusco, con variantes (casas mayores, una kancha, un ushnu o una huaca en la plaza, si el canon lo permite). Medir: 60 FPS y menos de 1,2 M primitivas | Pendiente |
| 5 | **Personajes del centro:** Apo Mayta y 3 curacas como variantes de `CharacterOutfit`, distintos por ropa y tocado, no solo por color (GDD §10.5). Vicaquirao, a la vista. Capturas para que elijas | Pendiente · **tú** eliges |
| 6 | **Hablar para coger misiones:** cada curaca da su misión con un diálogo corto, y las puertas invisibles desaparecen. Las misiones siguen siendo de prueba, pero el aviso dice qué pasa y qué Apoyo se gana. Un objetivo en pantalla guía la visita. Textos con `canon-check`. Pruebas | Pendiente |
| 7 | **Gente del centro:** `SectorPeople` del Cusco medio vacío: poca gente, con rutas y frases. Que no tape los puntos de misión | Pendiente |
| 8 | **Estocada procedural:** un `SkeletonModifier3D`, como `GuardPose` (F6), que lleva los brazos al frente sobre la locomoción. Prop de la lanza larga. Pruebas de la pose | Pendiente |
| 9 | **Lancero chanca:** `EnemyData` y `AttackData` de la estocada, con más alcance, más preparación y menos daño de postura que la porra. Valores en `.tres` dentro de los rangos de GDD §6.5. Pruebas de alcance y de bloqueo | Pendiente |
| 10 | **IA de distancia:** el lancero mantiene la distancia de su lanza, retrocede si Cusi se pega y ataca desde el límite de su alcance. Pruebas en la arena | Pendiente |
| 11 | **Tuning del lancero** con `combat-tuning`, en la arena y en Carmenca: lancero solo, mezclado con porras y en grupo de 3. Lo pruebas y lo ajustamos | Pendiente · **tú** pruebas |
| 12 | **Exploradores que patrullan:** el enemigo recorre una ruta hasta detectar a Cusi y, si lo pierde, vuelve a ella. En `.tres`. Pruebas | Pendiente |
| 13 | **Prueba del desarrollador:** recorrer el centro y pelear contra lanceros en la build exportada | Pendiente · **tú** |
| 14 | **Prueba de la `0.2-slice` en paralelo** (`0016`): la encuesta 0.2 y la difusión. Se revisa la cláusula al cerrar | Sin empezar · **tú** |
| 15 | **Cierre de F9** con `phase-gate` | Pendiente |

## Orden propuesto

- **Semana 1:** 1 → 2 → 3, y 8 en paralelo (no depende del centro).
- **Semana 2:** 9 → 10 → 11; 4 y 5 en los huecos.
- **Semana 3:** 6 → 7 → 12 → 13 → 15.
- **14** en paralelo todo el tiempo.

## Decisiones que se te piden

Tomadas con el backlog (2026-11-25):

1. **F9 empieza sin la prueba de la 0.2.** Sigue en paralelo, y la cláusula de `0016` se
   revisa al cerrar F9.
2. **Los lanceros salen en la arena y en Carmenca,** donde sustituyen a parte de los de
   porra (`0017`). Se hace en las tareas 9–11.
3. **Dentro del capítulo, Carmenca salta su apertura de tres planos:** el prólogo hace de
   apertura. En el modo slice no cambia nada. Se hace junto a la tarea 6.

Por el camino:

- **Tarea 2:** el plano del centro y el canon de la plaza.
- **Tarea 5:** el aspecto de Apo Mayta y los curacas.
- **Tarea 11:** si pelear contra lanceros se siente bien.
- **Tarea 13:** si se cumple el criterio.

## Qué se recorta primero

Si F9 se pasa de 4,5 semanas, en este orden (`capitulo-1.md` §8.2):

1. **Las patrullas** (tarea 12): los exploradores siguen esperando y detectando.
2. **El centro se reduce a la plaza,** sin calles que recorrer.
3. **El lancero:** los chancas siguen con porra en el capítulo, y la lanza pasa al Capítulo
   II.

**No se recortan** que el centro se entienda (tarea 6) ni la medición de rendimiento.

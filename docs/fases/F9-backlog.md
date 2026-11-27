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
| 1 | **Referencia de rendimiento en reposo** (deuda de F8): medir el prólogo, el centro actual y Carmenca con el bot, con la máquina sin navegador ni Node. Es la base con la que se compara el centro nuevo. Te aviso antes de abrir ventanas | Hecha: `docs/rendimiento/2026-11-reposo-f9.md`. Carmenca, 121,3 FPS y 0,03 % de frames lentos, igual que F6. Prólogo y centro, 170–180 FPS. El pico de 0,8 s eran tirones al aparecer guerreros, que se creaban en el origen: corregido (pico de física de 823 a 16 ms; física media de 6,0 a 2,5 ms) |
| 2 | **Diseño del centro:** plano de plaza y calles, y dónde están Vicaquirao, Apo Mayta, los 3 curacas, las salidas de misión y la gente. Cómo se entiende qué hacer: un objetivo en pantalla y personajes con quienes se habla, en vez de puertas invisibles. **Canon:** un Cusco de 1438 modesto, de pirca, adobe e ichu, sin la cantería posterior (registro, línea 44); `canon-check` de la plaza. Con un plano y capturas del blockout para que decidas | Hecha: `F9-diseno-centro.md`. Plaza genérica (licencia), cada curaca a la entrada de su kancha, 3 entradas nuevas en el registro |
| 3 | **Blockout del centro:** `centro_layout.tres` nuevo según el plano, con calles, plaza, desniveles y fondo del valle con la ciudad. Pruebas de que las casas quedan dentro del terreno y de que se llega a cada punto de misión | Hecha: 25 casas, 3 kanchas, plaza con fogón y salidas. 164 FPS y 0,50 M primitivas. Capturas en `docs/img/f9/` |
| 4 | **Arte del centro:** casas y muros del kit en la disposición del Cusco, con variantes (casas mayores, una kancha, un ushnu o una huaca en la plaza, si el canon lo permite). Medir: 60 FPS y menos de 1,2 M primitivas | Hecha, con tu visto bueno: calles de la llegada y de la salida entre pirca, 5 casas mayores (una por kancha y dos en la plaza), 7 casas cerradas con la puerta tapiada, jambas de piedra en las entradas de las kanchas, casas de la plaza mirando a ella y una huaca de piedra alta en la plaza (licencia, en el registro). 0,66 M primitivas y 145 draw calls como máximo, medido fuera de pantalla; los FPS, sin medir en tu GPU. Capturas `docs/img/f9/centro-arte-*.jpg` |
| 4b | **Más ciudad** (pedido por el desarrollador al recorrer el centro: «se ve un lugar pequeño»): de 25 a 43 casas dentro, una cuarta kancha sin curaca y 121 casas más allá del borde, sobre terreno al que Cusi no llega, sin colisión ni sombra. El suelo del centro pasa de 120 a 240 m; el suelo ya no proyecta sombra y hay menos ichu en las laderas. 1,07 M primitivas como máximo, fuera de pantalla. Capturas `docs/img/f9/centro-ciudad-*.jpg` | Hecha |
| 4c | **El Cusco de 1438** (pedido por el desarrollador: «no aparece ningún edificio histórico»): lectura de Betanzos, Sarmiento, Cieza, Cobo y Garcilaso, y el desarrollador elige. Inticancha antigua (casa de piedra con ichu en su cancha, al sur), dos canchas de Incas anteriores en la parte alta, la piedra de la guerra en la plaza (sustituye a la huaca de licencia) y dos arroyos sin encauzar a los lados de la ciudad. Fuentes en el registro | Hecha |
| 5 | **Personajes del centro:** Apo Mayta y 3 curacas como variantes de `CharacterOutfit`, distintos por ropa y tocado, no solo por color (GDD §10.5). Vicaquirao, a la vista. Capturas para que elijas | Hecha: elegiste la opción A de los cuatro (`docs/img/f9/personajes-elegidos.jpg`). Apo Mayta con manta, llauto y orejeras; curacas con turbante y bolsa (llamas), tocado alto con placa (prisioneros) y llauto con plumas (disputa). Están en sus puntos del centro; Vicaquirao, en la plaza |
| 6 | **Hablar para coger misiones:** cada curaca da su misión con un diálogo corto, y las puertas invisibles desaparecen. Las misiones siguen siendo de prueba, pero el aviso dice qué pasa y qué Apoyo se gana. Un objetivo en pantalla guía la visita. Textos con `canon-check`. Pruebas | Hecha: `HubTalks` sustituye a las puertas. Apo Mayta habla en la primera visita; cada curaca cuenta su problema y pregunta (aceptar / más tarde); luego da las gracias. Vicaquirao espera a 2 de 3 y ofrece «Ante los curacas». Objetivo «Habla con los curacas (n/3)» y marcador al más cercano. El aviso dice qué misión de prueba se cumple y con qué ayllu sube el Apoyo |
| 7 | **Gente del centro:** `SectorPeople` del Cusco medio vacío: poca gente, con rutas y frases. Que no tape los puntos de misión | Hecha: 7 personas (`centro_people.tres`): dos ancianos sentados, una mujer de rodillas, un guerrero de guardia y tres que hacen recados en bucle (`SectorPerson.loop`). Cuatro dicen una frase al pasar, todas ya registradas en el canon. Nadie a menos de 3,5 m de quien da misiones. 0,87 M primitivas y 258 draw calls como máximo, fuera de pantalla. Captura `docs/img/f9/centro-gente.jpg` |
| 8 | **Estocada procedural:** un `SkeletonModifier3D`, como `GuardPose` (F6), que lleva los brazos al frente sobre la locomoción. Prop de la lanza larga. Pruebas de la pose | Hecha: `ThrustPose` y `ThrustPoseTuning`; la lanza va en la mano apuntando al frente y avanza 1 m en la estocada. Escena `chanca_lancer.tscn`. Captura en `docs/img/f9/lancero-estocada.jpg` |
| 9 | **Lancero chanca:** `EnemyData` y `AttackData` de la estocada, con más alcance, más preparación y menos daño de postura que la porra. Valores en `.tres` dentro de los rangos de GDD §6.5. Pruebas de alcance y de bloqueo | Hecha: `lancero_chanca.tres` y `chanca_estocada.tres` (anticipación 0,75 s, postura 10 frente a 12–15 de la porra, alcance 2,8 m). El golpe y el aviso van en la punta de la lanza. A 3 m golpea donde la porra no llega |
| 10 | **IA de distancia:** el lancero mantiene la distancia de su lanza, retrocede si Cusi se pega y ataca desde el límite de su alcance. Pruebas en la arena | Hecha: `keep_away_distance` (lancero 2 m; la porra, 0). Rodeando, retrocede si Cusi se pega, como mucho cada 2,5 s; antes de golpear da un paso atrás de hasta 0,6 s |
| 11 | **Tuning del lancero** con `combat-tuning`, en la arena y en Carmenca: lancero solo, mezclado con porras y en grupo de 3. Lo pruebas y lo ajustamos | Hecha: el desarrollador lo probó el 2026-11-26 y la pelea contra lanceros «va bien». Sin más ajustes que los de la tarea 11 (la lanza en el puño y el deslizamiento al estocar) |
| 12 | **Exploradores que patrullan:** el enemigo recorre una ruta hasta detectar a Cusi y, si lo pierde, vuelve a ella. En `.tres`. Pruebas | Hecha: rutas en `SectorLayout.patrols` (por índice de aparición). En Carmenca, un explorador de porra por escaramuza hace su ronda; los lanceros esperan en su puesto. Si pierde a Cusi, vuelve al punto más cercano de su ronda. Pruebas en `test_carmenca_patrols.gd` |
| 13 | **Prueba del desarrollador:** recorrer el centro y pelear contra lanceros en la build exportada | Hecha el 2026-11-26: el centro «se recorre bien» y «se reconoce andino»; la pelea con los lanceros «va bien». Pidió más ciudad y edificios de la época (filas 4b y 4c). Sin medición de FPS registrada en el equipo de referencia |
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

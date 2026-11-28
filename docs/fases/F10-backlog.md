# F10 · Las misiones de Apoyo — backlog

**Estado:** aprobado por el desarrollador el 2026-11-27.

- **Criterio de salida (GDD §15, `docs/capitulo-1.md` §8):**
  - las 3 misiones de Apoyo se juegan en cualquier orden;
  - el Apoyo cambia el centro y el combate visible.

  Lo prueba el desarrollador.
- **Estimación:** 3 semanas (2026-11-27 – 2026-12-17). Si se pasa de 4,5, se recorta alcance.

**Base:**
- **`docs/capitulo-1.md`:** estructura B (§3), sistemas (§6.1–6.2), escenarios (§7.3) y
  plan (§8).
- **GDD §8.2:** Neutral → Simpatizante → Aliado. Las misiones rescatan prisioneros,
  recuperan provisiones o llamas, resuelven una disputa o demuestran valor en un combate
  visible.
- **La nota de F9,** sección «Pasa a F10».

**Lo que hay hoy:**
- **El capítulo** (`capitulo_1.tres`) ya define las misiones `llamas`, `prisioneros`,
  `disputa` y `combate_visible`. El combate pide 2 de 3. Sus niveles (`mision_llamas`, …)
  no existen en el catálogo: al aceptar, el curaca da una **misión de prueba** que se cumple
  al instante.
- **El Apoyo** (`SupportLedger`) ya sube por ayllu y avisa. Los ayllus se llaman
  `ayllu_a`, `ayllu_b` y `curaca_c`, con nombres provisionales.
- **El centro** está en 1,19 M primitivas, en el límite de 1,2 M, y en 297 draw calls.
- **`SupportAllies`** pone a los comuneros del paso de Carmenca de nuestro lado.
- **El director del slice** tiene los pasos REACH, ENCOUNTER, DIALOGUE, INTERACT, RITE,
  CHOICE y DRILL. Falta `ESCORT`.

**Alcance:** tres bloques.
- **Las misiones:**
  - A · llamas o provisiones;
  - B · prisioneros, con escolta;
  - C · la disputa del curaca, con una decisión.
- **El combate visible** ante los curacas, con aliados según el Apoyo.
- **El Apoyo se ve en el centro:** gente que vuelve y hombres que mandan los curacas.

**Fuera del alcance:**
- Susurpuquio, el quipucamayoc, las huacas nuevas, el códice nuevo, la música y los
  ambientes (F11);
- cambiar la `0.2-slice` publicada;
- la batalla del Capítulo II.

| # | Tarea | Estado |
| --- | --- | --- |
| 1 | **Hacer sitio en el centro** (deudas 2 y 4 de F9): casas de fondo más baratas (menos piezas, o un impostor por grupo) y ropa de cada personaje fundida en una sola malla. Objetivo: bajar de 1,19 M a menos de 0,9 M primitivas y de 297 a menos de 200 draw calls, para que quepa la gente que trae el Apoyo. Capturas antes y después para que veas que no se nota | Hecha: el maniquí con LOD, 121 casas de fondo lejanas (unos 70 triángulos cada una) y la ropa de cada personaje en una malla. El centro baja de 1,18 M a 0,85 M primitivas y de 293 a 203 draw calls; en la GPU de referencia, de 92 a 115 FPS. `docs/rendimiento/2026-11-sitio-centro-f10.md`; capturas `docs/img/f10/sitio-*.jpg` |
| 2 | **Diseño de las 3 misiones:** para cada una, la zona, el guion de pasos del director, los enemigos (porras, lanceros, patrullas), lo que se gana y cómo se falla o se repite. Nombres definitivos de misiones, ayllus y curacas (deuda 6 de F9). La decisión de la misión C y sus consecuencias. Textos con `canon-check`. Un documento corto con planos, para que decidas | Hecha: `F10-diseno-misiones.md`. A «Lo que se llevaron» (depósitos de un ayllu del valle), B «Los presos de Conchacalla» (quilescachis, con escolta) y C «Irse o quedarse» (pueblo del camino; ninguna opción es la mala). Cuatro entradas nuevas en el registro |
| 3 | **Misiones de verdad desde el centro:** al aceptar, el centro carga el nivel de la misión; al terminar, se vuelve al centro con la misión hecha, el Apoyo sumado y guardado. Abandonar devuelve al centro sin hacerla. Las misiones de prueba desaparecen. El aviso del Apoyo se ve y no lo pisa otro (deuda 5 de F9). Medir la carga del centro dentro del capítulo (deuda 3 de F9). Pruebas de ida y vuelta | Hecha: las cuatro misiones se juegan en un nivel provisional (`mision_esbozo.tscn`) hasta tener el suyo; al terminar se vuelve junto al curaca, con el Apoyo sumado y guardado; «Volver al centro» en la pausa las deja sin hacer. Los avisos dicen qué ayllu sube, esperan su turno y se repiten al llegar al centro. Los nombres aprobados ya están en el juego. Carga del centro en la GPU de referencia: unos 2,5 s tras la pantalla de carga y sin tirón después, unos 60 ms (`docs/rendimiento/2026-11-carga-capitulo-f10.md`) |
| 4 | **Misión A · llamas o provisiones:** nivel con el kit de Carmenca (ladera y corrales), guion, enemigos y recompensa. Medir: 60 FPS y menos de 1,2 M primitivas | Hecha. **4a, la zona:** Ladera de 160 × 220 m con las casas del ayllu, los depósitos, siete terrazas y el paso; 0,73 M primitivas y 126–131 FPS en la GPU de referencia (`docs/rendimiento/2026-11-zona-provisiones-f10.md`). **4b, la misión:** los 7 pasos del diseño, con la mujer, el anciano, los fardos (`PickupProps`) y un punto de control por combate; el bot la juega entera a 130 FPS y 0,83 M primitivas |
| 5 | **Paso `ESCORT`:** gente liberada que sigue a Cusi hasta un sitio, se para y se agacha en combate, y hace fallar la misión si cae (se repite desde el último punto de control). Valores en `.tres`. Pruebas | Pendiente |
| 6 | **Misión B · prisioneros:** quebrada con un campamento de exploradores; liberar a los prisioneros y escoltarlos. Medir | Pendiente |
| 7 | **Misión C · la disputa:** pueblo de un ayllu con las casas del kit; hablar con las dos partes y decidir. La decisión cambia algo que se ve (quién te acompaña, o cuánto Apoyo y de quién). Medir | Pendiente |
| 8 | **El Apoyo cambia el centro:** según el estado de cada ayllu, vuelve gente a su kancha y, con Aliado, aparecen hombres armados del curaca. Datos en `.tres` (`SectorPeople` condicionado al Apoyo). Pruebas por estado. Medir en el peor caso (los 3 aliados) | Pendiente |
| 9 | **Combate visible ante los curacas:** una ladera del kit; los curacas que ya apoyan miran desde arriba; los exploradores atacan. Aliados según el Apoyo, generalizando `SupportAllies`. Al ganar, todos los ayllus ganados suben (`support_all_won`). Medir | Pendiente |
| 10 | **Orden libre y guardado:** prueba de integración que juega las 3 misiones en los 6 órdenes posibles (con niveles mínimos), comprueba que el combate se abre con 2 de 3 y que «Continuar» recupera la partida entre misiones | Pendiente |
| 11 | **Deudas pequeñas de F9:** quien camina por el pueblo deja de esperar sin fin si Cusi se planta delante (lo rodea o cambia de rumbo) y se quitan las 7 aserciones de `LockOnController` en las pruebas (deudas 7 y 9) | Pendiente |
| 12 | **Prueba del desarrollador:** el capítulo desde Carmenca hasta el combate visible, en build exportada, con las misiones en el orden que quieras | Pendiente |
| 13 | **Prueba de la `0.2-slice` en paralelo** (`0016`): falta el enlace de la encuesta y la difusión. Se revisa la cláusula al cerrar | Pendiente |
| 14 | **Cierre de F10** con `phase-gate` | Pendiente |

## Orden propuesto

- **Semana 1:** 1 → 2 → 3. Sin el diseño (2) no se construye ninguna misión, y sin la ida y
  vuelta (3) no se juega ninguna.
- **Semana 2:** 4 → 5 → 6, y 11 en un hueco.
- **Semana 3:** 7 → 8 → 9 → 10 → 12 → 14.
- **13** en paralelo todo el tiempo.

## Decisiones que se te piden

Tomadas con el backlog (2026-11-27):

1. **F10 empieza sin la prueba de la 0.2.** Sigue en paralelo, y la cláusula de `0016` se
   revisa al cerrar F10.
2. **La misión A es de provisiones,** no de llamas: Carmenca ya tiene la decisión de las
   llamas. Maíz, chuño o charqui de un depósito saqueado por exploradores; se confirma con
   el canon en la tarea 2.
3. **Primero se hace sitio en el centro** (tarea 1): sin ese margen, el Apoyo no puede añadir
   gente sin pasar de 1,2 M.

Por el camino:

- **Tarea 1:** si las casas de fondo más baratas se notan.
- **Tarea 2:** el diseño, los nombres y la decisión de la misión C.
- **Tarea 8:** cómo se ve el Apoyo en el centro.
- **Tarea 12:** si se cumple el criterio.

## Qué se recorta primero

Si F10 se pasa de 4,5 semanas, en este orden (`capitulo-1.md` §8.2):

1. **La misión C** (la disputa): quedan 2 misiones, y el combate visible pide las 2.
2. **Los hombres armados en el centro:** el Apoyo se ve solo con la gente que vuelve.
3. **La escolta:** los prisioneros liberados huyen solos y la misión B termina al liberarlos.

**No se recortan** el orden libre, la vuelta al centro con el Apoyo guardado ni la medición
de rendimiento de cada zona.

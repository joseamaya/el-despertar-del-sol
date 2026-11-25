# F8 · Base del capítulo — nota de cierre

**Fechas:** 2026-11-24 – 2026-11-25 · **Estado:** cerrada

El desarrollador la dio por cumplida el 2026-11-25.

## Criterio de salida (GDD §15, `docs/capitulo-1.md` §8)

«Nueva partida → prólogo → Carmenca → centro; "Continuar" recupera la partida; build
exportada»:

- **El recorrido:** hecho. El desarrollador lo jugó del 2026-11-24 al 2026-11-25 y lo dio
  por probado («ya está todo probado»). Sus avisos se corrigieron en #98 y #99:
  - casas flotando y una cuesta demasiado empinada en el prólogo;
  - la huaca y el corral en medio del camino;
  - E no saltaba los rótulos;
  - Cusi atravesaba a la gente.
- **«Continuar»:** hecho. Lo cubren las pruebas de guardado y del recorrido del capítulo, y lo
  probó el desarrollador.
- **Build exportada:** hecha. Linux y Windows se exportan, y el de Linux arranca.
  - **Sin confirmar:** si el desarrollador jugó la build exportada o el editor.
  - **Windows no se ha jugado.**
- **Duración:** 2 días de las 3 semanas estimadas.

## Qué se hizo

| Tarea | PR | Resultado |
| --- | --- | --- |
| Backlog | #89 | `F8-backlog.md` |
| 1 · Diseño técnico | #90 | `F8-diseno-tecnico.md`: el armazón `game.tscn` y un solo autoload nuevo, `Save` |
| 2 · Menú de título | #90 | Nueva partida, Continuar, Ajustes y Salir. Fondo del valle al amanecer. «Volver al título» en la pausa |
| 3 · Cambio de escena | #90 | `LevelHost` y `LevelEntry`, con pantalla de carga |
| 4 · Estado del capítulo | #91 | `ChapterProgress` y el Capítulo I en `.tres`, con 7 misiones |
| 5 · Partida guardada | #92 | JSON versionado en `user://partida.json`. Guarda al empezar, en cada punto de control y al terminar un nivel |
| 6 · Apoyo por ayllu | #93 | `SupportLedger` con 4 ayllus provisionales, visible en la pausa y con aviso al subir |
| 7 · Carmenca en el capítulo | #94 | «Misión cumplida» y vuelta al centro |
| 8 · Prólogo y centro en bruto | #95 | Calle del Cusco con la corte que se va, y una plaza con puertas de misión de prueba |
| 9 · Skill `canon-check` | #96, #97 | Sin errores. 2 licencias registradas |
| 10 · UAL2 Standard | #96 | CC0, mismo esqueleto que UAL1. Solo integrado |
| 11 · Prueba del desarrollador | #98, #99 | 4 avisos corregidos (ver arriba) |
| 12 · Prueba de la `0.2-slice` | — | **No ha empezado:** falta la encuesta 0.2 y la difusión |
| 13 · Cierre | este PR | Esta nota |

## Verificación

En la rama `docs/cierre-f8` sobre `main` `93eaae7`, el 2026-11-25:
- **Importación** en headless: correcta.
- **Pruebas:** 484 de 484 en verde (en F7 eran 432).
- **Lint y formato:** sin problemas.
- **Builds:** Linux y Windows exportados. El de Linux arranca en headless sin errores.
- **CI de `main`:** en verde en el merge de #99.

## Rendimiento

Detalle en `docs/rendimiento/2026-11-cierre-f8.md`. **La máquina no estaba en reposo**
(navegador y Node con carga media de 3 a 17).

| Escena | FPS medio | Frames > 16,7 ms | Primitivas máx. |
| --- | --- | --- | --- |
| Prólogo | 114,2 | 3,7 % | 0,42 M |
| Centro | 115,0 | 2,5 % | 0,31 M |
| Carmenca, partida completa con el bot | 99,1 | 4,5 % | 1,12 M |
| Referencia de F6, en reposo | 121,3 | 0,1 % | 1,12 M |

- **Carga:** el prólogo tarda 0,6–0,7 s y Carmenca, 1,9–3,1 s.
- **La media pasa de 60 FPS en todo.**
- **Los frames lentos son ruido de la máquina:** la `v0.2-slice`, medida justo después con
  la misma carga, da lo mismo (4,7–6,4 %), igual que el prólogo sin las colisiones de #99.
- **No es una medición en reposo.** Se repite al empezar F9.

## Decisiones de la fase

- **Diseño técnico** (aprobado el 2026-11-24): un armazón `game.tscn` y un solo autoload
  nuevo, `Save`. Las dependencias se inyectan a los niveles con
  `LevelEntry.prepare`. La partida es un JSON versionado.
- **Fondo del título:** la imagen del valle.
- **Dos licencias en el registro histórico:** la calle del Cusco del prólogo, y el Cusco que
  se vacía con la corte.
- **Ninguna decisión nueva en `docs/DECISIONS/`.**

## Lo aprendido

- **Heredar escenas trae todo lo que tienen.** El prólogo y el centro heredan de Carmenca, y
  aparecieron su huaca, sus llamas, su comunero y los rótulos de sus actos donde no tocaba.
  Cada pieza de un nivel heredado necesita poder apagarse.
- **Las herramientas también deben proteger la partida.** Las pruebas desvían el guardado,
  pero `tools/shell_capture.gd` no lo hacía: al medir el cierre sobrescribió la partida del
  desarrollador. Ya guarda en su propio archivo y lo borra al terminar.
- **La prueba del desarrollador encuentra lo que las pruebas no ven:** casas flotando, cosas
  en medio del camino y gente que se atraviesa. Hay que pedirla antes del cierre, no en él.
- **Medir con la máquina ocupada solo sirve comparando.** Dos ramas medidas una tras otra
  separan el ruido de una regresión.

## No verificado

- **Si el recorrido se jugó en la build exportada** o en el editor.
- **Windows y mando:** ni la `0.2-slice` ni el capítulo.
- **El rendimiento en reposo** del prólogo, el centro y Carmenca con #99.
- **La gente del pueblo con cuerpo** (#99) solo se ha visto en pruebas.
- **La partida del desarrollador:** la medición la sustituyó a las 18:10 del 2026-11-25 por
  una nueva en el prólogo. No queda copia.

## Pasa a F9 · El centro y el lancero

1. **La prueba de la `0.2-slice`** sigue sin empezar:
   - falta la encuesta 0.2 (el enlace) y la difusión del tráiler y el flyer;
   - `capitulo-1.md` §8 pedía que llegara antes de F9, y la cláusula de `0016` no se puede
     revisar sin respuestas;
   - **el desarrollador decide** si F9 empieza igual.
2. **El centro no explica las puertas de prueba.** No hay objetivo, las puertas no se ven y
   el aviso es breve; el desarrollador no entendió «La disputa del curaca». F9 rehace el
   centro: que diga qué hacer y dónde. Las puertas de prueba se quedan hasta F10.
3. **Carmenca repite su apertura de tres planos** después del prólogo. Hay que decidir si se
   salta dentro del capítulo.
4. **El centro está vacío y Vicaquirao queda fuera del encuadre.** Es su arte, de F9.
5. **Quien camina por el pueblo espera sin fin** si Cusi se planta delante; no le rodea.
6. **Rendimiento:**
   - repetir la medición en reposo;
   - el margen de primitivas de Carmenca (1,12–1,14 M de 1,2 M);
   - el pico de física de 989 ms, sin reproducir.
7. **Nombres provisionales** de misiones, ayllus y curaca: se fijan con las misiones (F10).
8. **Canon pendiente**, de F7:
   - cotejar a Betanzos con la edición de Martín Rubio;
   - leer a Bauer y otros (2010);
   - las láminas de Guamán Poma;
   - el nombre del quipucamayoc.
9. **Deudas de F6 y anteriores**, sin cambios: «Pasa a F7» de `F6-ajuste-del-combate.md`.

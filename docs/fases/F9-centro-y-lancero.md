# F9 · El centro y el lancero — nota de cierre

**Fechas:** 2026-11-25 – 2026-11-26 · **Estado:** cerrada

El desarrollador la dio por cumplida el 2026-11-26.

## Criterio de salida (GDD §15, `docs/capitulo-1.md` §8)

«El centro del Cusco se recorre a 60 FPS y es reconocible andino; pelear contra lanceros se
siente bien»:

- **Reconocible andino:** el desarrollador lo confirmó el 2026-11-26 («sí se reconoce
  andino»). Al recorrerlo pidió dos cosas más, que ya están hechas:
  - más ciudad (#115), porque se veía «un lugar pequeño»;
  - edificios de la época (#116), elegidos con las crónicas.
- **Se recorre a 60 FPS:** el desarrollador dice que «se recorre bien». Medido en el equipo de
  referencia al cerrar, da 92–99 FPS de media, con el 99 % de los frames por debajo de
  13,5 ms. Más abajo se detalla el tirón de construcción del nivel.
- **Pelear contra lanceros se siente bien:** el desarrollador, el 2026-11-26: «la pelea con
  los lanceros va bien».
- **Duración:** 2 días de las 3 semanas estimadas. No hubo que recortar.

## Qué se hizo

| Tarea | PR | Resultado |
| --- | --- | --- |
| Backlog | #101 | `F9-backlog.md` |
| 1 · Rendimiento en reposo | #102, #104 | `2026-11-reposo-f9.md`. Corregidos los tirones al aparecer guerreros |
| 2 · Diseño del centro | #103 | `F9-diseno-centro.md`: plaza genérica, cada curaca en su kancha, 3 entradas en el registro |
| 3 · Blockout del centro | #105 | 25 casas, 3 kanchas, plaza y salidas |
| 4 · Arte del centro | #111 | Calles entre pirca, casas mayores y cerradas, jambas en las kanchas, piedra alta en la plaza |
| 4b · Más ciudad | #115 | 43 casas dentro, una cuarta kancha y 121 casas más allá del borde |
| 4c · El Cusco de 1438 | #116 | Inticancha antigua, canchas de Incas anteriores en Hanan, piedra de la guerra y dos arroyos sin encauzar, con fuentes |
| 5 · Personajes del centro | #112 | Apo Mayta y 3 curacas, opción A elegida por el desarrollador; Vicaquirao con orejeras |
| 6 · Hablar para coger misiones | #113 | `HubTalks` sustituye a las puertas: llegada de Apo Mayta, ofertas, objetivo en pantalla y aviso de la misión de prueba |
| 7 · Gente del centro | #114 | 7 personas, recados en bucle y frases al pasar |
| 8 · Estocada procedural | #106 | `ThrustPose` sobre la animación |
| 9 · Datos del lancero | #107 | `lancero_chanca.tres`, golpe en la punta de la lanza |
| 10 · IA de distancia | #108 | El lancero guarda la distancia de su lanza |
| 11 · Tuning del lancero | #109 | Arena con 4 mezclas y lanceros en Carmenca; lanza en el puño y deslizamiento al estocar |
| 12 · Patrullas | #110 | Un explorador por escaramuza hace su ronda y vuelve a ella |
| 13 · Prueba del desarrollador | #117 | Criterio confirmado (ver arriba) |
| Decisión 3 del backlog | #118 | Dentro del capítulo, Carmenca salta su apertura; el prólogo la conserva |
| 14 · Prueba de la `0.2-slice` | — | **No ha empezado:** pasa a F10 por decisión del desarrollador |
| 15 · Cierre | este PR | Esta nota |

## Verificación

En la rama `docs/cierre-f9` sobre `main` `1e3cd40`, el 2026-11-26:
- **Importación** en headless: correcta.
- **Pruebas:** 551 de 551 en verde (en F8 eran 484), y 552 con #118.
- **Lint y formato:** sin problemas en los archivos versionados.
- **Builds:** Linux y Windows exportados. El de Linux arranca en headless sin errores.
- **CI de `main`:** en verde en el merge de #116.

## Rendimiento

Detalle en `docs/rendimiento/2026-11-cierre-f9.md`. Carga media de la máquina, 1,4–1,8.

| Escena | FPS medio | Frames > 16,7 ms | Primitivas máx. |
| --- | --- | --- | --- |
| Centro, andando y girando | 92,3–92,7 | 0,15 % | **1,19 M** |
| Centro, recorriendo el camino | 99,2 | 0,20 % | 1,14 M |
| Prólogo | 157,0–158,8 | 0–0,03 % | 0,42 M |
| Carmenca, partida completa con el bot | 122,6 | 0,09 % | 1,12 M |

- **El centro pasa de 60 FPS con margen.** Su peor frame, de 3,1–3,3 s, es el de construir el
  nivel al cargarlo, no un tirón al jugar.
- **Las primitivas del centro están en el límite:** 1,19 M de 1,2 M.
- **Carmenca no empeora** con los lanceros y las patrullas.

## Decisiones de la fase

Ninguna nueva en `docs/DECISIONS/`. Las del backlog y las de canon:
- **Del backlog:**
  - F9 empezó sin la prueba de la 0.2;
  - los lanceros salen en la arena y en Carmenca;
  - dentro del capítulo, Carmenca salta su apertura.
- **El diseño del centro:** plaza genérica y cada curaca a la entrada de su kancha.
- **El aspecto de Apo Mayta y los curacas:** opción A. Las orejeras de oro, solo para los
  nobles incas: Cusi, Vicaquirao y Apo Mayta.
- **El Cusco de 1438,** elegido por el desarrollador tras leer a Betanzos, Sarmiento, Cieza,
  Cobo y Garcilaso: Inticancha, las canchas de Hanan, la piedra de la guerra y los dos
  arroyos. La huaca de licencia de la plaza pasa a ser la piedra de la guerra.
- **Registro histórico:** 13 entradas nuevas o revisadas, todas con su etiqueta:
  - el trazado del centro;
  - las kanchas;
  - los curacas en el Cusco;
  - las casas cerradas;
  - la ropa;
  - los problemas de los curacas;
  - el combate en la ladera;
  - Vicaquirao y Susurpuquio;
  - Inticancha;
  - las canchas de Hanan;
  - la piedra de la guerra;
  - los arroyos.

## Lo aprendido

- **La prueba del desarrollador encuentra la escala.** Las pruebas automáticas daban el
  centro por bueno, pero recorriéndolo se veía «un lugar pequeño» y sin historia. Las capturas
  a la altura de los ojos y desde arriba ayudan, pero no sustituyen a recorrerlo.
- **Leer las crónicas da contenido, no solo etiquetas.** La lectura dio sitios concretos
  (Inticancha, la piedra de la guerra, los dos arroyos) y también sus discrepancias. Hay que
  leerlas antes de diseñar un lugar, no después.
- **Hay que releer las decisiones del backlog al cerrar cada tarea.** La decisión 3 (Carmenca
  salta su apertura dentro del capítulo) era «junto a la tarea 6» y se olvidó hasta el cierre.
- **El presupuesto de primitivas se lo come el escenario, no los personajes.** El centro pasó
  de 0,31 a 1,19 M con casas, terreno y ciudad de fondo. Medir tras cada paso permitió
  recortar a tiempo: sin sombra del suelo, menos ichu y menos casas de fondo.
- **Las PR apiladas obligan a un orden de merge.** Funcionó avisándolo en cada PR, pero las
  filas del backlog y del registro chocan si dos ramas tocan el mismo sitio.

## No verificado

- **La pantalla de carga del centro dentro del capítulo:** construirlo tarda 3,1–3,3 s
  medido con la escena suelta.
- **Windows y mando:** el centro y los lanceros no se han jugado así.
- **Si el desarrollador jugó la build exportada** o el editor.
- **Las citas de las crónicas** salen de OCR; se comprobaron dos a mano.
- **Los avisos de «Simpatizante»** pueden quedar tapados por el de la misión de prueba.

## Pasa a F10 · Las misiones de Apoyo

1. **La prueba de la `0.2-slice`:**
   - falta la encuesta 0.2 (el enlace) y la difusión;
   - la cláusula de `0016` sigue sin revisar.
2. **El centro está en el límite de primitivas (1,19 M).** F10 hace que el Apoyo cambie el
   centro con más gente y hombres armados, así que antes hay que hacer sitio:
   - casas de fondo más baratas (impostores o menos detalle);
   - o menos casas de fondo.
3. **La carga del centro:** medir la pantalla de carga dentro del capítulo y, si se alarga,
   repartir la construcción o el horneado del navmesh.
4. **Los draw calls del centro (297):** la ropa de cada personaje son varias piezas. Si F10
   añade gente, conviene fundirlas.
5. **Los avisos que se pisan:** «Simpatizante» y la misión de prueba salen a la vez; con las
   misiones de verdad, el aviso del Apoyo debe verse.
6. **Nombres provisionales** de misiones, ayllus y curacas («Curaca del valle», «de la
   quebrada», «del pueblo»): se fijan con las misiones.
7. **Quien camina por el pueblo espera sin fin** si Cusi se planta delante (de F8, sin cambios).
8. **Canon pendiente:**
   - lo de F7: Betanzos en la edición de Martín Rubio, Bauer y otros (2010), Guamán Poma y el
     nombre del quipucamayoc;
   - lo que no se pudo leer en F9: la segunda parte de Betanzos, Molina, Pedro Pizarro y Polo
     de Ondegardo;
   - revisar con especialista las citas OCR de Inticancha, la piedra de la guerra y los
     arroyos.
9. **Ruido en las pruebas:** 7 aserciones «LockOnController needs its sensor and camera», ya
   presentes en `main` antes de F9. No fallan pruebas, pero ensucian la salida.
10. **Deudas de F6 y anteriores**, sin cambios: «Pasa a F7» de `F6-ajuste-del-combate.md`.

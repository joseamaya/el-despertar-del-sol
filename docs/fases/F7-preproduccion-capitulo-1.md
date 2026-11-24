# F7 · Preproducción del Capítulo I — nota de cierre

**Fechas:** 2026-11-24 – 2026-11-24 · **Estado:** cerrada

El desarrollador pidió cerrarla el 2026-11-24 («Cierra F7 ya»). La prueba de la `0.2-slice`
aún no había empezado, y pasa a F8 como tarea en paralelo.

## Criterio de salida (GDD §15, `DECISIONS/0016`)

«Capítulo I diseñado y planificado (estructura, canon, sistemas, arte y fases de
producción), con la prueba de la `0.2-slice` en paralelo»:

- **Canon:** hecho. `F7-canon-capitulo-1.md` contrasta Betanzos, Sarmiento y Molina con su
  texto; las decisiones están en `DECISIONS/0017`.
- **Estructura:** hecha. La **B · Cusco como centro**, de unos 90–100 min
  (`docs/capitulo-1.md` §3).
- **Sistemas:** hecho. §6: se reutiliza casi todo el slice y hay 8 piezas nuevas de tamaño M.
- **Arte y audio:** hecho. §7: estocada procedural, música CC0 prehispánica primero y UAL2
  Standard en F8.
- **Fases de producción:** hechas. §8, aprobadas: F8–F12, unas 13 semanas, en GDD §15.
- **La prueba de la `0.2-slice` en paralelo: no ha empezado.** Falta la encuesta 0.2 (el
  enlace) y la difusión, que dependen del desarrollador. **No se cumple esta parte;** el
  desarrollador decide cerrar igualmente, y la prueba pasa a F8 (ver «Pasa a F8»).
- **Duración:** 1 día de las 2 semanas estimadas.

## Qué se hizo

| Tarea | PR | Resultado |
| --- | --- | --- |
| Replanteamiento de F7 | #87 | `DECISIONS/0016`: la prueba deja de ser una puerta y F7 pasa a ser la preproducción del Capítulo I. Backlog aprobado |
| 1 · Prueba de la 0.2 en paralelo | — | No ha empezado: falta el enlace de la encuesta 0.2 |
| 2 · Canon | #88 | `F7-canon-capitulo-1.md`, `DECISIONS/0017` y `HISTORICAL_REFERENCES.md` |
| 3 · Estructura | #88 | Estructura B elegida entre tres |
| 4 · Sistemas | #88 | Inventario y tamaños (§6) |
| 5 · Arte y audio | #88 | Necesidades y 3 decisiones (§7) |
| 6 · Plan de producción | #88 | F8–F12 aprobadas (§8) y GDD §15 |
| 7 · Cierre | #88 | Esta nota |

## Verificación

En la rama del cierre (`docs/canon-capitulo-1`, `30c37c9`, sobre `main` `9f1e959`), el
2026-11-24:
- **Importación** en headless: correcta.
- **Pruebas:** 432 de 432 en verde.
- **Lint y formato:** sin problemas.
- **Builds exportados:** Linux y Windows. El de Linux arranca en headless.
- **CI de `main`:** en verde en el último merge (#87, `9f1e959`).

## Rendimiento

No se mide: F7 no cambia el juego (solo documentación). La referencia sigue siendo la de F6,
tarea 1: 121,3 FPS de mediana y 0,1 % de frames lentos
(`docs/rendimiento/2026-11-slice-completo.md`).

## Decisiones de la fase

- **`0016`:** la prueba de la 0.2 corre en paralelo, y F7 es la preproducción del Capítulo I.
  Cláusula de seguridad: si al menos 3 personas que terminen dan menos del 50 % de 4–5, se
  para.
- **`0017` · Canon del Capítulo I:**
  - visión de Susurpuquio ambigua, con cristal;
  - los chancas llevan lanza larga;
  - Quilescachi Urco Guaranga, solo en el códice;
  - sin cascos ni corazas;
  - la skill `canon-check`, en F8.
- **Estructura B · Cusco como centro** (`docs/capitulo-1.md`).
- **Arte y audio:**
  - estocada procedural;
  - música CC0 prehispánica primero;
  - UAL2 Standard en F8.
- **Plan F8–F12** (GDD §15).

## Lo aprendido

- **Leer la crónica, no el resumen.** El registro tenía una duda que el texto de Betanzos
  resolvía: el campamento chanca está en Vilcaconga. También tenía la visión atribuida solo
  a Molina, cuando cada cronista la cuenta de una forma.
- **Las fuentes en línea fallan:** Gutenberg rechazó las descargas, y archive.org sirvió como
  alternativa. Las citas que vienen de transcripciones automáticas hay que cotejarlas.
- **Cerrar el diseño antes de producir** permite cambiar el plan si la prueba de la 0.2
  revela algo, sin tirar trabajo.
- **Conseguir probadores sigue siendo el cuello de botella:** por segunda fase, la prueba no
  arranca sin la encuesta y la difusión.

## No verificado

- **Las citas de Betanzos** salen del texto escaneado de la edición de 1880 y deben
  cotejarse con la edición de Martín Rubio.
- **La vestimenta chanca:** no se leyó el estudio de Bauer y otros (2010).
- **Los clips de la versión Pro de Quaternius:** ninguna página los lista. Ya no hace falta,
  porque la estocada será procedural.
- **El criterio 8 de §14.4** sigue sin medirse: ningún jugador externo ha probado la
  `0.2-slice`.
- **La `0.2-slice` en Windows y con mando.**

## Pasa a F8 · Base del capítulo

1. **La prueba de la `0.2-slice` en paralelo:**
   - la encuesta 0.2 (el enlace) y la difusión del tráiler y el flyer;
   - registrar lo que llegue en `F7-resultados.md`;
   - revisar la cláusula de `0016` en cada cierre de fase, idealmente antes de F9.
2. **Windows y mando** con la `0.2-slice`.
3. **El contenido de F8,** según `docs/capitulo-1.md` §8:
   - cambio de escena;
   - partida guardada;
   - estado del capítulo y misiones;
   - Apoyo por ayllu;
   - el slice como nivel de Carmenca;
   - el prólogo en bruto;
   - la skill `canon-check`;
   - la descarga de UAL2 Standard.
4. **Canon pendiente:**
   - cotejar a Betanzos con la edición de Martín Rubio;
   - leer a Bauer y otros (2010);
   - revisar las láminas de Guamán Poma;
   - el nombre del quipucamayoc (GDD §5.2).
5. **Deudas de F6 y anteriores** («Pasa a F7» de `F6-ajuste-del-combate.md`), sin cambios.

# F7 · Preproducción del Capítulo I — backlog

**Estado:** aprobado por el desarrollador el 2026-11-24.

- **Criterio de salida (GDD §15, `DECISIONS/0016`):** el Capítulo I diseñado y planificado.
  Eso significa: estructura, misiones y escenarios aprobados; canon y armamento documentados;
  y las fases de producción con su estimación. Además, la prueba de la `0.2-slice` corriendo
  en paralelo, con sus resultados registrados.
- **Estimación:** 2 semanas (2026-11-24 – 2026-12-08). Si se pasa de 3, se recorta alcance.

**Por qué preproducción y no producción** (`0016`): el combate solo lo ha validado el
desarrollador. Diseñar primero permite cambiar el plan si la prueba dice que algo no
convence, sin tirar escenarios ni animaciones.

**Alcance:**
- el documento del Capítulo I;
- el canon y las referencias que necesita;
- el plan de producción;
- la prueba de la 0.2, que corre sola.

**Fuera del alcance:**
- producir escenarios, personajes o misiones del Capítulo I (eso es F8 en adelante);
- cambiar la build `0.2-slice` mientras dura la prueba;
- los Capítulos II–IV;
- el arte final.

| # | Tarea | Estado |
| --- | --- | --- |
| 1 | **Prueba de la 0.2 en paralelo** (`0016`, punto 1). Lo que te toca a ti: <br>– duplicar la encuesta como «prueba 0.2» y pasarme el enlace (lo pongo en la guía); <br>– difundir el tráiler y el flyer; <br>– si puedes, que alguien la pruebe en Windows y con mando. <br>Lo que hago yo: registrar respuestas y comentarios en `F7-resultados.md` y avisarte si salta la cláusula del punto 3 de `0016` | Pendiente · **tú** difundes; el agente registra |
| 2 | **Canon del Capítulo I** (`HISTORICAL_REFERENCES.md`), con la skill `canon-check` si apruebas crearla (GDD §16.5): <br>– la retirada de Viracocha y Urco; <br>– quiénes se quedan; <br>– los ayllus del Cusco y los exploradores chancas; <br>– Susurpuquio y la visión; <br>– el **armamento y la vestimenta** inca y chanca (deuda de F5). <br>Cada licencia, con su etiqueta. Tú decides las licencias | Hecha: `F7-canon-capitulo-1.md` y `DECISIONS/0017` (visión ambigua con cristal, chancas con lanza larga, sin cascos; `canon-check` en F8) |
| 3 | **Estructura del capítulo** (`docs/capitulo-1.md`): <br>– secuencia de escenas y misiones para 1–2 horas; <br>– qué se reutiliza del slice (Carmenca, tutorial, huaca, Apoyo); <br>– qué escenarios nuevos hacen falta (calles del Cusco, Susurpuquio); <br>– el ritmo combate / exploración / Apoyo. <br>2–3 propuestas de estructura, con un diagrama; tú eliges | Hecha: `docs/capitulo-1.md`; elegida la **B · Cusco como centro** (prólogo, Carmenca, 3 misiones de Apoyo en orden libre, combate visible y Susurpuquio; unos 90–100 min) |
| 4 | **Sistemas que pide el capítulo:** <br>– Apoyo con varias misiones (convencer a ayllus); <br>– exploradores chancas; <br>– la visión jugable de Susurpuquio; <br>– guardado entre escenas; <br>– más entradas del códice. <br>Para cada uno: qué existe ya, qué falta y cuánto cuesta. Sin implementar | Pendiente |
| 5 | **Arte y audio:** qué personajes, escenarios, animaciones y música nuevos hacen falta. Qué sale de packs CC0 y qué no. Si hace falta comprar algo (animaciones Pro, por ejemplo), se te presenta con precio | Pendiente |
| 6 | **Plan de producción:** las fases F8+ con criterio de salida y estimación, para el GDD §15. Qué se recorta primero si el capítulo no cabe. Dónde encaja la próxima prueba con jugadores (la demo del Capítulo I, GDD §20) | Pendiente |
| 7 | **Cierre de F7** con `phase-gate`. Revisa el criterio 8 con lo que haya llegado de la prueba (`0016`, punto 4) | Pendiente |

## Orden propuesto

- **Semana 1:** 1 desde el día 1 (en paralelo todo el tiempo); 2 → 3.
- **Semana 2:** 4 y 5; 6 → 7.

## Decisiones que se te piden por el camino

- **Tarea 2:** las licencias de canon y si se crea la skill `canon-check`.
- **Tarea 3:** qué estructura del capítulo.
- **Tarea 5:** compras de recursos, si las hay.
- **Tarea 6:** las fases y el orden de producción.
- **En cualquier momento:** si salta la cláusula de `0016`, parar o seguir.

## Qué se recorta primero

Si F7 se pasa de 3 semanas, en este orden:

1. El detalle de arte y audio (tarea 5) pasa a cada fase de producción.
2. Los sistemas (tarea 4) se estiman por encima, sin desglose.
3. Una sola propuesta de estructura (tarea 3) en lugar de 2–3.

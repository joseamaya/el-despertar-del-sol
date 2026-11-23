# 0014 · Decisión de la prueba externa: ajustar (F5)

**Fecha:** 2026-11-23 · **Estado:** aceptada (decidida por el desarrollador)

## Contexto
F5 tenía que decidir si el proyecto continúa, se ajusta o se recorta (GDD §15), a partir de
la prueba con jugadores del criterio 8 (GDD §14.4) y del protocolo de `0013`.

**Se cerró con menos respuestas de las previstas:**
- **Dos respuestas al formulario:** P1 y P2, las dos de la build `0.1-slice`. Solo P1
  terminó el slice.
- **Comentarios de jugadores que no rellenaron la encuesta.**
- **Sin más probadores:** el desarrollador no consiguió más y decidió avanzar con lo que
  había.

Análisis completo en `docs/fases/F5-analisis.md`. En resumen:
- **Nadie puso un 4 o un 5** al combate ni al escenario: P1 y P2 dieron un 3 a los dos.
- **Las mismas quejas en varias fuentes independientes:**
  - el bloqueo «no responde»;
  - el combate se queda corto: P1 critica la respuesta de los controles, P2 pide más
    variedad;
  - falta contexto;
  - falta orientación.
- **Funciona:** la estabilidad, el rendimiento y el paisaje, que se siente andino.

## Decisión
1. **Ajustar.** Ni continuar con el plan tal cual ni recortar. La base técnica y el
   escenario se sostienen; los problemas son concretos y están localizados.
2. **Nueva fase F6 · Ajuste del combate, de 2 semanas.** Con el margen del 50 % de §15: si se
   pasa de 3 semanas, se recorta alcance. Líneas de trabajo:
   - **Bloqueo fiable y legible:**
     - revisar el arco frontal de 120°, o que Cusi se oriente hacia el atacante;
     - que se vea que estás bloqueando;
     - que se note cuando un golpe atraviesa el bloqueo.
   - **Respuesta de ataque y esquiva:** medir la latencia y las ventanas de cancelación y
     ajustarlas en sus Resources (GDD §6.5, skill `combat-tuning`).
   - **Orientación:** un indicador ligero hacia el objetivo actual.
   - **Preparar una nueva prueba con jugadores:** una build nueva y probadores buscados con
     más antelación.

   El backlog detallado de F6 se aprueba al abrir la fase.
3. **Se mantiene el GDD §6.1** («pocos movimientos, bien sentidos, en vez de muchos
   combos»). La petición de más movimientos, combos y saltos (P2) no entra en F6. Se vuelve
   a considerar después de la próxima prueba, si el combate sigue pareciendo escaso cuando
   lo que hay ya se siente bien.
4. **Fuera de F6, para decidirlo aparte:**
   - el armamento «medieval» (P2), hasta documentar armas y vestimenta en
     `HISTORICAL_REFERENCES.md`;
   - los aliados del Apoyo;
   - la animación de las llamas;
   - la apertura «espectacular»;
   - la dificultad del paso y el «3 + 3» de §14.1, sin datos.

## Consecuencias
- **El GDD §15** añade F6 a la tabla de fases.
- **`0013`** recibe una enmienda: la regla de decisión no se aplicó por debajo del mínimo
  de 5 respuestas.
- **El criterio 8 de §14.4 sigue sin cumplirse.** Se vuelve a medir en la próxima prueba,
  que debería cerrar F6 o la fase siguiente.
- **Ninguna de las dos respuestas es de la `0.1.1-slice`.** La apertura, el entrenamiento
  opcional y la muerte arreglada siguen sin validar con jugadores.

## Cuándo revisarla
- Al cerrar F6, con la nueva prueba.
- Antes, si el ajuste del bloqueo y de la respuesta de los controles no mejora la sensación
  del combate para el propio desarrollador.

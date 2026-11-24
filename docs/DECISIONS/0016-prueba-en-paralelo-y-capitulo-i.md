# 0016 · La prueba de la 0.2 corre en paralelo; se empieza a preparar el Capítulo I (F7)

**Fecha:** 2026-11-24 · **Estado:** aceptada (decidida por el desarrollador)

## Contexto
Al cerrar F6, el plan era una F7 de dos semanas dedicada solo a probar la `0.2-slice` con
5–10 personas y decidir (`0014`, «Cuándo revisarla»). Pero:
- **conseguir probadores es lento:** en F5, dos semanas dieron 2 respuestas;
- **la `0.2-slice` resuelve lo que señalaron los jugadores** (bloqueo, respuesta, orientación),
  y el desarrollador la ha jugado completa: «está excelente»;
- **la build ya está publicada** (pre-release `v0.2-slice`), con tráiler, flyer y guía.

Esperar dos semanas sin desarrollar, para quizá no llegar a 5 respuestas, frena el proyecto.
Pero el GDD §20 pide validar el slice antes del Capítulo I, y el criterio 8 de §14.4 («7 de
cada 10 dicen que el combate se siente bien») no se ha medido nunca: en F5 la nota fue un 3.

## Decisión
1. **La prueba de la `0.2-slice` deja de ser una puerta.** Corre en segundo plano: el
   desarrollador difunde cuando puede, y el agente registra lo que llega
   (`docs/fases/F7-resultados.md`). La build no cambia durante la prueba, salvo un fallo
   que impida terminar (`0013`, punto 8).
2. **F7 · Preproducción del Capítulo I (2 semanas):** se diseña y se planifica el Capítulo I
   (GDD §9 y §20) sin producir todavía contenido. Así, lo que diga la prueba aún puede
   cambiar el plan sin tirar trabajo.
3. **Cláusula de seguridad:** si las respuestas que lleguen (al menos 3 personas que
   terminen) dan menos del 50 % de 4–5 en combate o en escenario, se para y se ajusta antes
   de producir el Capítulo I (regla de `0013`, punto 7). Con el 50–70 %, el ajuste entra en
   el plan del Capítulo I.
4. **El criterio 8 sigue abierto,** y se revisa al cerrar F7 con lo que haya.

## Consecuencias
- **GDD §15:** F7 pasa a ser «Preproducción del Capítulo I».
- **`AGENTS.md`:** fase actual F7 con el nuevo criterio de salida.
- **Riesgo aceptado:** el diseño del Capítulo I parte de un combate validado solo por el
  desarrollador. Se mitiga con la cláusula del punto 3 y porque F7 no produce contenido.
- **El backlog anterior de F7** (solo prueba) queda sustituido por el de este cambio.

## Cuándo revisarla
- Si se cumple la cláusula del punto 3.
- Al cerrar F7, con las respuestas que haya.

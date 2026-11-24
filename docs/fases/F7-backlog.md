# F7 · Segunda prueba externa — backlog

**Estado:** propuesta del agente, pendiente de aprobación del desarrollador.

- **Criterio de salida (GDD §15):** la `0.2-slice` probada por 5–10 personas, el criterio 8
  de GDD §14.4 medido y la decisión tomada: continuar, ajustar o recortar.
- **Estimación:** 2 semanas (2026-11-24 – 2026-12-08). Si se pasa de 3, se recorta alcance
  (ver «Qué se recorta primero»).

**Base:** el protocolo de `DECISIONS/0013` y sus enmiendas, con la build `0.2-slice` ya
publicada, y la guía `F6-guia-prueba.md`. Lo que se quiere saber es si el ajuste de F6
lleva el combate y el escenario al 4–5 del criterio 8:

> Prueba con jugadores (5–10 personas): al menos 7 de cada 10 dicen que el combate se siente
> bien y que el escenario no parece un juego medieval genérico.

**Alcance:**
- lanzar la prueba;
- conseguir probadores;
- recoger lo que dicen y lo que pasa en sus partidas;
- analizar y decidir.

**Fuera del alcance:**
- cambiar el combate, el contenido o el arte mientras dura la prueba: la build no cambia
  hasta que terminan todos (`0013`, punto 8). La única excepción es un fallo que impida
  terminar;
- las deudas de F6 y anteriores que no estorban a quien prueba (ver «Pasa a F7» de
  `F6-ajuste-del-combate.md`): se ordenan después de la decisión;
- el Capítulo I.

**Lección de F5 que manda en este plan:** el cuello de botella no es la build, son los
probadores. En F5 salieron 2 respuestas. Por eso la difusión empieza el primer día, y la
prueba tiene una fecha de corte y un plan para cuando no se llegue a 5.

| # | Tarea | Estado |
| --- | --- | --- |
| 1 | **Encuesta 0.2:** duplicas el formulario de F5 como «prueba 0.2», sin tocar las preguntas, para poder comparar. El agente añade, si lo apruebas, una pregunta opcional al final: «¿Jugaste la versión anterior (0.1)?». Pegas el enlace y el agente lo pone en `F6-guia-prueba.md` y te deja el mensaje final listo para enviar | Pendiente · **tú** |
| 2 | **Comprobar Windows y mando** con la `0.2-slice`: alguien con Windows abre el zip y juega unos minutos, con mando si lo tiene. Puede ser el primer probador (como la piloto de F5). Si falla algo que impida jugar, se arregla y se publica una `0.2.1-slice` antes de seguir repartiendo | Pendiente · **tú** busca a la persona |
| 3 | **Difusión y probadores** (desde el día 1): envías el tráiler, el flyer y los textos de `F6-difusion.md` a grupos, redes y a quien ya jugó la 0.1. Objetivo: 8–10 personas apalabradas para que terminen al menos 5. Si quieres publicar avances con regularidad, es el momento de proponer la skill `devlog` (GDD §16.5) | Pendiente · **tú** envías; el agente adapta textos si hace falta |
| 4 | **Seguimiento de la prueba:** a mitad de plazo, un recordatorio a quien dijo que jugaría (el agente lo redacta). Registro en `docs/fases/F7-resultados.md` de las respuestas del formulario y de los comentarios fuera de él (mensajes, notas de voz), marcando quién jugó la 0.1 | Pendiente · tú pasas las respuestas; el agente las consolida |
| 5 | **Fecha de corte y regla con pocas respuestas:** la prueba se cierra el **2026-12-04**, o antes si hay 10 respuestas. Si al corte hay menos de 5 de personas que terminaron, decides entre: alargar una semana (dentro del margen de §15), o decidir con lo que haya como en F5 (análisis cualitativo, sin aplicar el umbral). Se registra como enmienda de `0013` | Pendiente · **tú** decides al corte |
| 6 | **Análisis** (`F7-analisis.md`): criterio 8 con la regla de `0013`, comparación con la 0.1 (bloqueo, respuesta y orientación), duración real frente a 8–12 min, derrotas por zona (dificultad del paso), fallos por plataforma y mando, y qué dicen de lo que cambió en F6. Con una propuesta de continuar, ajustar o recortar | Pendiente |
| 7 | **Decisión** (`DECISIONS/0016`) y **cierre de F7** con `phase-gate`. Si la decisión es continuar, se propone la siguiente fase del GDD §15 | Pendiente |

## Orden propuesto

- **Semana 1 (24–30 nov):** 1 y 2 el primer día o dos; 3 desde el primer día; 4 en marcha.
- **Semana 2 (1–8 dic):** recordatorio (4) hacia el día 1; corte el 4 (5); 6 y 7.

## Decisiones que se te piden por el camino

- **Tarea 1:** si se añade la pregunta «¿Jugaste la 0.1?».
- **Tarea 3:** canales y, si quieres, la skill `devlog`.
- **Tarea 5:** qué hacer si al corte no hay 5 respuestas.
- **Tarea 7:** continuar, ajustar o recortar.

## Qué se recorta primero

Si F7 se pasa de 3 semanas, en este orden:

1. **El recordatorio y el registro detallado** (tarea 4): solo las respuestas del formulario.
2. **La comparación con la 0.1** (tarea 6): solo el criterio 8 y los fallos.
3. **Se decide con las respuestas que haya**, como en F5.

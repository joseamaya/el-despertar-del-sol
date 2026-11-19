# 0013 · Protocolo de la prueba externa del slice (F5)

**Fecha:** 2026-11-19 · **Estado:** aceptada (decidida por el desarrollador)

## Contexto
F5 tiene 2 semanas para decidir si el proyecto continúa, se ajusta o se recorta (GDD §15).
La decisión se apoya en el criterio 8 de aceptación del slice (GDD §14.4):

> Prueba con jugadores (5–10 personas): al menos 7 de cada 10 dicen que el combate se
> siente bien y que el escenario no parece un juego medieval genérico.

Antes de enviar nada hay que fijar a quién se invita, cómo responde, qué se guarda y qué
resultado lleva a cada decisión. Así el resultado no se interpreta a posteriori.
Backlog: `docs/fases/F5-backlog.md`.

## Decisión
1. **Probadores: amigos y conocidos, de 5 a 7 personas.**
   - Al menos 2 juegan en Windows y, si es posible, 1 con mando.
   - El amigo de la prueba de Windows hace primero una prueba piloto (tarea 6).
   - Al ser gente cercana, la encuesta pide puntuaciones concretas y momentos concretos, no
     una opinión general, para compensar la amabilidad.
2. **Encuesta en Google Forms, en la cuenta del desarrollador.**
   - El agente redacta las preguntas (tarea 4) y el desarrollador crea el formulario.
   - El formulario **no recoge correos ni nombres**: la opción de recoger direcciones queda
     desactivada.
3. **Idioma: español.** El juego y la encuesta se prueban en español; la traducción inglesa
   existe, pero no forma parte de la prueba.
4. **Qué se pide:**
   - jugar la build de principio a fin, sin ayuda, como lo haría cualquiera;
   - responder la encuesta justo después;
   - pegar el resumen de partida que muestra el «Fin» (tarea 3).

   No se piden datos personales ni grabaciones. La encuesta empieza con un consentimiento:
   las respuestas se usan, sin nombres, para decidir el futuro del proyecto y pueden
   citarse de forma anónima en su documentación.
5. **Qué se guarda en el repositorio** (que es público):
   - solo los resultados anonimizados en `docs/fases/F5-resultados.md`, con cada persona
     como P1, P2…;
   - puntuaciones, el resumen de partida y citas textuales sin nada que identifique a
     nadie.

   La hoja de respuestas completa se queda en la cuenta del desarrollador.
6. **Cuándo «se siente bien»:** una puntuación de 4 o 5 en una escala de 1 a 5, en cada una
   de las dos preguntas del criterio 8:
   - **Combate:** «¿El combate se siente bien?».
   - **Escenario:** «¿El escenario parece un juego medieval genérico?», invertida: 4 o 5
     significa que **no** lo parece.
7. **Regla de decisión** (umbral del GDD), sobre las personas que terminaron el slice:

   | Resultado | Decisión |
   | --- | --- |
   | Combate **y** escenario con al menos el 70 % de 4–5, y ningún fallo que impida terminar | **Continuar** con el plan |
   | Alguna de las dos entre el 50 % y el 70 %, o fallos graves en una plataforma | **Ajustar** esa parte antes de seguir |
   | Alguna de las dos por debajo del 50 % | **Recortar o replantear** el alcance |

   Con pocas personas, el porcentaje se redondea en contra: con 5 respuestas, el 70 % exige
   4 de 5, y el 50 % exige 3 de 5.
8. **La build no cambia durante la prueba.** Todos juegan la misma *release* `0.1-slice`.
   - Lo que salga se arregla después del análisis (tarea 8).
   - Excepción: un fallo que impida terminar. En ese caso se publica `0.1.1-slice` y se
     anota quién jugó cada versión.

## Consecuencias
- **Tareas que dependen de esta decisión:**
  - la encuesta (tarea 4) tiene las dos preguntas del criterio 8 con esa redacción y
    escala;
  - el resumen de partida (tarea 3) no puede incluir nada que identifique a la persona.
- **Una muestra de 5–7 amigos es pequeña y amable.** Si el resultado queda justo en un
  umbral, el análisis lo dice y propone ampliar con 2 o 3 personas ajenas antes de decidir.
- **La decisión final la toma el desarrollador** (`0014`): esta regla es su punto de
  partida, no un automatismo.

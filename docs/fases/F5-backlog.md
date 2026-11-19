# F5 · Prueba externa — backlog

**Estado:** aprobado por el desarrollador el 2026-11-19.

- **Criterio de salida (GDD §15):** decidir si se continúa, se ajusta o se recorta.
- **Estimación:** 2 semanas. Si se pasa de 3, se recorta alcance.

**Base de la decisión.** Son los criterios de aceptación del slice (GDD §14.4), sobre todo el 8:

> Prueba con jugadores (5–10 personas): al menos 7 de cada 10 dicen que el combate se siente
> bien y que el escenario no parece un juego medieval genérico.

**Alcance:**
- preparar la prueba;
- repartir una build fija;
- recoger lo que dicen y lo que pasa en sus partidas;
- decidir.

**Fuera del alcance:**
- añadir contenido o retocar el combate mientras dura la prueba: la build no cambia hasta que
  terminan todos;
- el arte final;
- las ideas del Capítulo I (compañeros que siguen a Cusi, Apoyo completo).

**Deudas heredadas de F4:** `docs/fases/F4-integracion-del-slice.md`, sección «Pasa a F5».

| # | Tarea | Estado |
| --- | --- | --- |
| 1 | **Protocolo de la prueba** (`DECISIONS/0013`): a quién se invita y cuántos (5–10, al menos 2 con Windows y 1 con mando), cómo reciben la build, qué se les pide y qué no (sin datos personales; consentimiento para usar sus respuestas), idioma, y la regla de decisión (qué resultado significa continuar, ajustar o recortar) | Hecha: `DECISIONS/0013`; 5–7 amigos y conocidos, Google Forms sin correos, en español, umbral del GDD (≥ 70 % continuar, 50–70 % ajustar, < 50 % recortar) |
| 2 | **Revisión previa de §14.4 (criterios 1–7)** con una lista de comprobación. Medir 60 FPS a 1080p en el equipo de referencia con la máquina en reposo, que es la medida que quedó pendiente en F4. Corregir solo lo que impida jugar o mida mal | Hecha: `F5-revision-slice.md`; criterios 2–7 cumplidos (119 FPS a 1080p al 83 %, 0,2 % de frames lentos); 1 cumplido en Linux, Windows pendiente de la piloto; sin correcciones necesarias |
| 3 | **Resumen de partida local:** al llegar al «Fin», el juego muestra y guarda en `user://` un resumen para copiarlo en la encuesta. Incluye tiempo total y por acto, derrotas por zona, elección del ayllu, ofrenda en la huaca, códice abierto y si usó mando. Todo queda en el equipo del jugador: nada se envía por red ni lleva datos personales | Pendiente |
| 4 | **Encuesta:** borrador de preguntas (es/en) con las dos de §14.4.8 tal cual, escala 1–5, preguntas abiertas y el campo para pegar el resumen. Tú eliges la herramienta (formulario, documento o mensaje) | Pendiente |
| 5 | **Build de la prueba:** versión `0.1-slice` visible en el menú, una *release* pública de GitHub con los zips de Windows y Linux (no caducan, a diferencia de los artefactos de la CI) y una guía corta para quien prueba, que reutiliza la de `F4-prueba-windows.md` | Pendiente |
| 6 | **Prueba piloto** con tu amigo de Windows: confirma la build de Windows, la guía y la encuesta antes de enviarla al resto (deuda de F4) | Pendiente |
| 7 | **Prueba externa:** envío a 5–10 personas y registro de respuestas en `docs/fases/F5-resultados.md`. Tú envías y recibes; el agente consolida | Pendiente |
| 8 | **Análisis:** criterio 8 (≥ 7/10 en cada pregunta), dificultad de la segunda oleada del paso (derrotas por zona), duración real frente a los 8–12 min y fallos por plataforma o mando. Con eso, una propuesta de continuar, ajustar o recortar, con sus motivos | Pendiente |
| 9 | **Decisión** (`DECISIONS/0014`) y **cierre de F5** con `phase-gate` | Pendiente |

## Notas

- **Dificultad del paso:** no se toca antes de la prueba. Si en el análisis se confirma que la
  segunda oleada frustra, el primer ajuste es que los refuerzos tarden más en llegar
  (`wave_delay`, hoy 2 s); el segundo, bajar a 2 refuerzos.
- **Arreglos menores de «Pasa a F5»:** solo entran antes de la prueba si estorban a quien
  prueba. Son la coma decimal de la sensibilidad, saltar el tutorial y los avisos internos
  del motor. El resto se apunta para después.
- **GDD §14.1:** actualizar «defender un paso contra tres» al 3 + 3 se decide en la tarea 9,
  junto con el resto de cambios que salgan de la prueba.
- **Skills (GDD §16.5):** `devlog` solo si quieres usar publicaciones para encontrar
  probadores; si no, sigue para después. En F5 no hacen falta textos nuevos, así que
  tampoco `canon-check`.

## Qué se recorta primero

Si F5 se pasa de 3 semanas, en este orden:

1. El resumen de partida (tarea 3). La encuesta pregunta lo mismo a mano.
2. La prueba piloto se junta con la prueba externa.
3. Se decide con 5 respuestas en lugar de esperar a 10.

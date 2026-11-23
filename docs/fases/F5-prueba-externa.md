# F5 · Prueba externa — nota de cierre

**Fechas:** 2026-11-19 – 2026-11-23 · **Estado:** cerrada

Criterio de salida confirmado por el desarrollador el 2026-11-23.

## Criterio de salida (GDD §15)

«Decidir: continuar, ajustar o recortar»:

- **Decisión del desarrollador (2026-11-23): ajustar** (`DECISIONS/0014`).
  - Nueva fase F6 · Ajuste del combate, de 2 semanas.
  - El GDD §6.1 no cambia.
- **Base de la decisión:** `F5-analisis.md`. Hay 2 respuestas al formulario, solo una de
  alguien que terminó, y los comentarios de quien jugó sin rellenarlo. La prueba no llegó al
  mínimo de 5 respuestas: no hubo más probadores, y queda escrito en la enmienda de `0013`.
- **Duración:** 5 días de las 2 semanas estimadas.

## Qué se hizo

| Tarea | PR | Resultado |
| --- | --- | --- |
| Backlog de F5 | #60 | Aprobado el 2026-11-19 |
| 1 · Protocolo de la prueba | #61 | `DECISIONS/0013`: 5–7 amigos, Google Forms sin correos, regla de decisión |
| 2 · Revisión previa de §14.4 | #62 | Criterios 1–7 cumplidos; 119 FPS a 1080p en reposo |
| 3 · Resumen de partida | #63 | `SessionSummary` al «Fin»; C / Y lo copia |
| 4 · Encuesta | #64, #66 | 18 preguntas y consentimiento, en Google Forms |
| 5 · Build y guía | #65 | Pre-release `v0.1-slice` y `F5-guia-prueba.md` |
| 6 · Prueba piloto en Windows | #68 | P1 llega al «Fin» sin fallos, con fluidez 5 |
| 7 · Prueba externa | #67, #68, #72 | Tráiler y flyer; 2 respuestas (P1, P2) y comentarios fuera del formulario |
| 7 · Build `0.1.1-slice` | #69, #70 | Muerte arreglada, entrenamiento opcional y apertura de tres planos; pre-release `v0.1.1-slice` |
| CI estable | #71 | Las dos pruebas intermitentes de «Tests (Sistemas)» pasan a ser deterministas |
| 8 · Análisis | #73 | `F5-analisis.md`; propuesta: ajustar |
| 9 · Decisión y cierre | #73 | `DECISIONS/0014`, enmienda de `0013`, F6 en el GDD §15 y esta nota |

## Verificación

En la rama del cierre, el 2026-11-23:
- **Importación** en headless: correcta.
- **Pruebas:** 408 de 408 en verde.
- **Lint:** `gdlint` sin problemas.
- **Formato:** `gdformat --check` sin problemas en los archivos del repositorio. Solo se
  quejaba de `tools/agent_bridge.gd`, un script local de otra herramienta que no está
  versionado.
- **Builds exportados:** Linux y Windows. El de Linux arranca en headless.
- **CI de `main`:** en verde en el último merge (#72, `9c8dc1f`). Las dos pruebas que fallaban
  de forma intermitente se arreglaron en #71.

## Rendimiento

Slice completo con el bot (`tools/scene_benchmark.gd --playthrough`, 3D al 83 %), en el
equipo de referencia. Hay **tres pasadas, pero la máquina no estaba en reposo**: otros
procesos subieron la carga media de 1,1 a 12,8 en la primera, y a 33 en la tercera.

| Pasada | Carga al empezar | FPS medio | 1 % bajo | Frames > 16,7 ms | Primitivas máx. |
| --- | --- | --- | --- | --- | --- |
| 1 | 1,1 | 120,6 | 41,3 | 0,7 % | 1,12 M |
| 2 | 12,6 | 106,5 | 26,0 | 1,5 % | 1,12 M |
| 3 | 3,6 (33 al final) | 84,8 | 20,4 | 13,5 % | 1,12 M |
| F4, en reposo | 0,9–4,9 | 124,6 | 53,8 | 0,1 % | 1,05 M |

- **La pasada 1 es comparable a F4** en FPS medio (120,6 frente a 124,6). Tiene más
  fotogramas lentos, sobre todo en el cierre (6,5 %), pero la carga subió durante la propia
  medición.
- **Las pasadas 2 y 3 no sirven para comparar.**
- **Primitivas:** de 1,05 M a 1,12 M, por la apertura con 4 guerreros más a la vista. Sigue
  por debajo del límite de 1,2 M de F3.
- **El acto de apertura dura ahora unos 87 s con el bot**, con los tres planos y el
  entrenamiento. La partida completa del bot pasa de 3 min 55 s (F4) a unos 4 min 46 s.
- **Sin conclusión sobre regresiones:** hay que repetir en reposo (pasa a F6).

## Decisiones de la fase

- `0013` · Protocolo de la prueba externa. Tres enmiendas: difusión con desconocidos
  (2026-11-19), build `0.1.1-slice` a mitad de la prueba (2026-11-21) y cierre con 2
  respuestas (2026-11-23).
- `0014` · Decisión de la prueba externa: **ajustar**, con F6 · Ajuste del combate.

## Lo aprendido

- **Conseguir probadores es la tarea más difícil de la fase, y empezó tarde.** El tráiler y
  el flyer llegaron cuando la prueba ya estaba en marcha. Para la próxima prueba hay que
  buscar gente desde el principio de la fase anterior, por ejemplo con un *devlog* (GDD
  §15).
- **Quien juega no siempre rellena el formulario.** La mayor parte de lo útil llegó por
  mensajes y una nota de voz. Hay que pedir el formulario de forma explícita, también a
  quien no termina, y registrar los comentarios informales en lugar de descartarlos.
- **Nadie lee los rótulos.** El contexto hay que mostrarlo, no escribirlo. La apertura de
  tres planos salió de ahí.
- **Las capturas reales encuentran lo que las pruebas no ven:** los chancas de la apertura
  estaban a 46 m y no se veían.
- **Un tutorial obligatorio con un paso difícil bloquea la prueba entera:** el parry
  atascaba a la mayoría en la primera parte.
- **`git add -A` puede meter archivos ajenos:** en esta fase entró por error un script local
  de otra herramienta (`tools/agent_bridge.gd`) y hubo que sacarlo. Hay que añadir los
  archivos por nombre.

## No verificado

- **Ninguna persona ha jugado la `0.1.1-slice`.** La apertura, el entrenamiento opcional y la
  muerte arreglada siguen sin validar con jugadores.
- **Build de Windows de la 0.1.1:** no se ha probado en Windows; la 0.1 sí funcionó.
- **Mando físico:** sin probar.
- **Criterio 8 de §14.4:** pendiente; con 1 persona que cuenta no se puede medir.
- **Rendimiento en reposo de la build actual:** ver «Rendimiento».
- **Dificultad de la segunda oleada del paso:** sin datos.

## Pasa a F6 · Ajuste del combate

F6 dura 2 semanas (`DECISIONS/0014`); su backlog se aprueba al abrirla.

1. **Lo que señalaron los jugadores** (`F5-analisis.md`, §5):
   - el bloqueo, fiable y legible (arco frontal de 120°, pose visible, aviso cuando un golpe
     lo atraviesa);
   - la respuesta de ataque y esquiva;
   - la orientación hacia el objetivo.
2. **Nueva prueba con jugadores:**
   - una build nueva;
   - buscar probadores con antelación;
   - volver a medir el criterio 8;
   - pedir el formulario también a quien no termine.
3. **Rendimiento en reposo** de la build actual, para descartar la caída que apunta la
   pasada 1 en el cierre.
4. **Mando físico y Windows** de la build nueva.
5. **Fuera de F6, para decidir aparte** (`0014`, punto 4):
   - el armamento «medieval», tras documentar armas y vestimenta en
     `HISTORICAL_REFERENCES.md`;
   - los aliados del Apoyo;
   - la animación de las llamas;
   - la apertura «espectacular»;
   - la dificultad del paso y el «3 + 3» de §14.1.
6. **Deudas que siguen abiertas desde F4:**
   - **Canon:** el campamento chanca en Betanzos y el desnivel de Santa Ana.
   - **Presentación:**
     - la cámara hacia la familia;
     - la faldilla del *anacu*;
     - la coma decimal de la sensibilidad;
     - el aviso «2 resources still in use at exit»;
     - el aviso «Tween started with no Tweeners» de `SliceAudio`, que sigue saliendo en el
       benchmark;
     - el tocado chanca.
   - **Arte y animación:**
     - arte final de F3;
     - animaciones Pro, que pueden ayudar a que el bloqueo se vea;
     - tiempo del navmesh.
   - **Skills:** `devlog`, para conseguir probadores; `canon-check`, antes de escribir textos
     del Capítulo I.

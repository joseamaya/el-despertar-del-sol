# F6 · Ajuste del combate — nota de cierre

**Fechas:** 2026-11-23 – 2026-11-23 · **Estado:** cerrada

Criterio de salida confirmado por el desarrollador el 2026-11-23. Siguiente fase:
F7 · Segunda prueba externa.

## Criterio de salida (GDD §15)

«Bloqueo fiable y legible, controles que responden, orientación y build lista para una nueva
prueba» (`DECISIONS/0014`):

- **Bloqueo fiable:** sin fijar objetivo, los golpes que atraviesan la guardia pasan del
  48–79 % al 0 % en los escenarios medidos (`F6-diagnostico-bloqueo.md`). Probado por el
  desarrollador: «está excelente».
- **Bloqueo legible:** Cusi alza la huallcanca, y cada golpe parado deja un destello con
  chispas (`DECISIONS/0015`).
- **Controles que responden:** las esquivas perdidas pasan del 87 % al 0 % con 1 guerrero, y
  del 81 % al 26 % con 3 (`F6-diagnostico-respuesta.md`). Probado por el desarrollador:
  «está todo correcto».
- **Orientación:** marcador dorado hacia el destino de cada paso, con la distancia y una
  flecha en el borde de la pantalla.
- **Build lista:** pre-release pública `v0.2-slice` (2026-11-23, `main` `4484c6b`), con la
  guía `F6-guia-prueba.md`, el tráiler, el flyer y los textos de `F6-difusion.md`.
- **Prueba del desarrollador (tarea 10):** jugó la `0.2-slice` completa: «está excelente».
- **Lo que falta para lanzar la prueba,** que depende del desarrollador:
  - la encuesta 0.2: duplicar el formulario y poner el enlace en la guía;
  - los probadores apalabrados (tarea 9).
- **Duración:** 1 día de las 2 semanas estimadas.

## Qué se hizo

| Tarea | PR | Resultado |
| --- | --- | --- |
| Backlog | #74 | Aprobado el 2026-11-23 |
| 2 · Diagnóstico del bloqueo | #75 | El 68–79 % de los golpes que entraban lo hacían por fuera del arco de 120°; ninguna guardia rota |
| 3 · Bloqueo fiable | #76 | La guardia encara al atacante más cercano que amenaza (`BlockFacing`, 4 m); el entrenamiento enseña a fijar objetivo |
| 4 · Bloqueo legible | #78, #79 | Pose de guardia procedural, destello con chispas y huallcanca en el antebrazo (`0015`) |
| 5 · Golpe que atraviesa el bloqueo | — | Recortada por el desarrollador: con la tarea 3 ya no entran golpes en los escenarios medidos |
| 6 · Diagnóstico de la respuesta | #80 | A ritmo normal se perdía el 96–97 % de las esquivas |
| 7 · Respuesta de ataque y esquiva | #81 | Búfer de 0,3 s, la esquiva corta la anticipación, aviso de resistencia y recuperación tras 0,3 s |
| 8 · Orientación | #82 | Marcador de objetivo, elegido frente a una brújula con capturas |
| Arreglo: deslizamiento sin control | #77 | Un diálogo que corta una esquiva o un ataque ya no deja al jugador deslizándose |
| 1 · Rendimiento en reposo | #84, #85 | Mediana de 3 pasadas: 121,3 FPS, 0,1 % de frames lentos |
| 9 · Probadores | #84, #85 | Tráiler, flyer y textos listos; la difusión y los probadores, pendientes |
| 10 · Prueba del desarrollador | #84, #85 | «Está excelente» |
| 11 · Build `0.2-slice` | #83, #85 | Versión en el menú, guía y pre-release `v0.2-slice` |
| 12 · Cierre | este PR | Esta nota |

## Verificación

En la rama del cierre (`main` `5ad53cf`), el 2026-11-23:
- **Importación** en headless: correcta.
- **Pruebas:** 432 de 432 en verde (408 al cerrar F5).
- **Lint y formato:** `gdlint` y `gdformat --check` sin problemas en los archivos del
  repositorio.
- **Builds exportados:** Linux y Windows. El de Linux arranca en headless; solo sale el aviso
  conocido «2 resources still in use at exit».
- **CI de `main`:** en verde en el último merge (#85, `5ad53cf`).

## Rendimiento

Medido en la tarea 1 sobre el código final del juego (`docs/rendimiento/2026-11-slice-completo.md`).
Desde entonces solo han cambiado documentos, así que no se repite. Slice completo con el bot,
3D al 83 %, máquina en reposo, mediana de 3 pasadas:

| | Cierre de F4 (reposo) | Cierre de F5 (con carga) | F6 · `0.2-slice` (reposo) |
| --- | --- | --- | --- |
| FPS medio | 124,6 | 120,6 (pasada 1) | 121,3 |
| 1 % bajo | 53,8 | 41,3 | 46,2 |
| Frames > 16,7 ms | 0,1 % | 0,7 % | 0,1 % |
| Primitivas máx. | 1,05 M | 1,12 M | 1,12 M |
| Draw calls máx. | 200 | — | 201 |

- **Sin regresión:** la caída que apuntaba el cierre de F5 era la carga de la máquina.
- **Primitivas:** 1,12 M por la apertura con los chancas a la vista, cerca del límite de
  1,2 M de F3.

## Decisiones de la fase

- `0015` · Escudo de Cusi: huallcanca (rodela). Forma y decoración son «Licencia del juego»;
  la existencia del escudo, «Según los cronistas» (Garcilaso), en `HISTORICAL_REFERENCES.md`.
- Ajustes de combate registrados en `combat-tuning-log.md`:
  - `block_face_range` 4 m;
  - destello de bloqueo;
  - pose de guardia con escudo;
  - `player_response.tres`: búfer de esquiva y ataque de 0,3 s;
  - `regen_delay` de 0,6 a 0,3 s, que cambia el GDD §6.5.

## Lo aprendido

- **Diagnosticar antes de ajustar.** Los bots con sonda dieron cifras que cambiaron el
  arreglo previsto:
  - el problema del bloqueo era el arco, no la resistencia;
  - el de la esquiva era la espera de recuperación de la resistencia, más que la falta de
    búfer. El primer ajuste de la tarea 7 no mejoraba nada hasta bajar `regen_delay`.
- **Lo que el jugador no ve no existe.** El destello quedaba tapado por el cuerpo; hubo que
  dibujarlo encima y sobre el escudo. Sin escudo, el bloqueo parecía hecho «con la mano».
- **Las capturas desde la cámara del juego evitan rehacer:** la pose de guardia, el escudo
  que «flotaba» y el marcador se decidieron mirando imágenes, no descripciones.
- **Retener al jugador también es cortar su acción.** Congelar el combate a mitad de una
  esquiva lo dejaba deslizándose.
- **Los PRs apilados se pueden mergear contra la rama equivocada:** #84 entró en
  `chore/build-0-2` y no en `main`, y hubo que repetirlo en #85. Mejor no apilar PRs de
  documentación, o retargetearlos antes de mergear.
- **Con agentes, la fase cabe en un día;** lo que no se acelera es conseguir probadores.

## No verificado

- **Ningún jugador externo ha probado la `0.2-slice`,** ni tampoco la `0.1.1-slice`. El
  criterio 8 de §14.4 sigue sin medirse.
- **Windows:** la `0.2-slice` no se ha probado en un PC con Windows.
- **Mando físico:** sin probar.
- **Con 3 guerreros,** el 26 % de las esquivas se siguen perdiendo y un golpe por la espalda
  puede entrar sin una señal distinta (la tarea 5 se recortó).

## Pasa a F7 · Segunda prueba externa

1. **La prueba con jugadores de la `0.2-slice`:**
   - encuesta 0.2: duplicar el formulario de F5 y poner el enlace en `F6-guia-prueba.md`;
   - probadores: difundir el tráiler y el flyer (tarea 9);
   - medir el criterio 8 y decidir: continuar, ajustar o recortar (`0014`, «Cuándo
     revisarla»).
2. **Windows y mando** con la `0.2-slice`.
3. **Deudas de F6:**
   - la tarea 5 recortada, si los jugadores no entienden por qué entra un golpe;
   - los escudos de los chancas;
   - el sonido del aviso de resistencia, que necesita un recurso CC0;
   - la velocidad de la batería de pruebas;
   - el margen de primitivas en la apertura.
4. **Fuera del ajuste, para decidir aparte** (`0014`, punto 4; siguen igual):
   - el armamento «medieval»;
   - los aliados del Apoyo;
   - la animación de las llamas;
   - la apertura «espectacular»;
   - la dificultad del paso.
5. **Deudas que siguen abiertas desde F4 y F5:** las de «Pasa a F6» de
   `F5-prueba-externa.md`, puntos 5 y 6, sin cambios.

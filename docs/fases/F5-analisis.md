# F5 · Análisis de la prueba externa (tarea 8)

**Estado:** propuesta del agente, pendiente de la decisión del desarrollador (tarea 9,
`DECISIONS/0014`) · Datos: `F5-resultados.md` · Protocolo: `DECISIONS/0013`

## 1. Con qué se decide

La prueba se cierra **sin llegar al mínimo de 5 respuestas**. El desarrollador no consiguió
más probadores (2026-11-23) y decide avanzar con lo que hay.

| Fuente | Qué es | Build | Cuenta para el criterio 8 |
| --- | --- | --- | --- |
| **P1** | Formulario. Terminó el slice (prueba piloto, Windows) | 0.1 | Sí |
| **P2** | Formulario. Lo dejó en el ayllu o las casas (Linux) | 0.1 | No |
| **O1** | Nota de voz, sin formulario | 0.1 | No |
| **«Varios»** | Lo que contaron otros jugadores al desarrollador, sin formulario | 0.1 | No |

**Límites que hay que tener presentes:**
- **Muestra mínima:** 1 persona cuenta para el criterio 8. Ningún porcentaje es fiable.
- **Nadie ha jugado la 0.1.1.** No sabemos si la apertura, el entrenamiento opcional y la
  muerte arreglada cambian las impresiones.
- **Hay sesgo:** son amigos y conocidos (`0013`), y P1 dio señales de responder con prisa.
- **Lo cualitativo pesa más que los números:** coincide entre fuentes independientes.

## 2. Criterio 8 (GDD §14.4)

| Pregunta | P1 | P2 (no cuenta) | Umbral para continuar |
| --- | --- | --- | --- |
| ★7 El combate se siente bien | 3 | 3 | ≥ 70 % de 4–5 |
| ★12 El escenario no parece medieval genérico | 3 | 3 | ≥ 70 % de 4–5 |

Aplicada al pie de la letra, la regla de `0013` (punto 7) da 0 de 1 en las dos preguntas,
por debajo del 50 %: **recortar o replantear**. Pero la regla pide al menos 5 respuestas y
dice que es «un punto de partida, no un automatismo». Con una sola persona solo indica que
**nada apunta a «continuar» tal cual**: nadie ha puesto un 4 o un 5.

## 3. Lo que pedía la tarea 8

- **Dificultad de la segunda oleada del paso:** sin datos suficientes. P1 perdió una vez en
  el paso y puntuó la dificultad con 1. P2 no llegó al paso y la puntuó con 3. No se toca
  `wave_delay`.
- **Duración real frente a los 8–12 min:** solo P1 (4:11), con señales de prisa. Sin
  conclusión.
- **Fallos por plataforma:** ninguno que impida jugar. Windows (P1) y Linux (P2) van con
  fluidez 5 y 4.
- **Fallos con mando:** **sin probar**. Nadie jugó con mando físico.

## 4. Patrones que se repiten

Ordenados por cuántas fuentes independientes los mencionan.

### 4.1. El bloqueo «no responde» (P2, O1, «varios»)
- P2: «no detecta los bloqueos a veces». O1: «el bloqueo está medio raro». La mayoría se
  atascaba en el entrenamiento por el bloqueo.
- **Causa probable en el código:** el bloqueo solo cubre un arco frontal de 120°
  (`DefenseTuning.block_arc_deg`). Sin fijar objetivo, Cusi mira hacia donde se movió por
  última vez, y un golpe de lado entra aunque F esté pulsada. Además, el pack gratuito no
  tiene animación de bloqueo (`DECISIONS/0007`), así que no se ve que estás bloqueando.
- **Ya arreglado en la 0.1.1:** el texto y que el parry no atasque. **Sin arreglar:** el arco
  y lo visual.

### 4.2. El combate se queda corto (P1, P2)
- P1 cambiaría «la respuesta de los controles (Esquivar y atacar)». P2 pide «más recursos,
  armas, movimientos, combo» y saltos.
- Son dos quejas distintas:
  - **Respuesta** (P1): latencia, cancelaciones, sensación al pulsar. Encaja con el
    pilar del GDD.
  - **Variedad** (P2): más movimientos y combos. **Choca con el GDD §6.1:** «Pocos
    movimientos, bien sentidos, en vez de muchos combos».
- Lectura del agente: antes de añadir movimientos, hay que conseguir que los que hay se
  sientan bien. Si el bloqueo «no responde» y esquivar o atacar no se siente inmediato, el
  combate parecerá escaso por muchos movimientos que se añadan.

### 4.3. Falta contexto (P2, O1, «varios»)
- P2 puntuó la historia con 2 («se entiende, pero poco contexto»). P1 la puntuó con 1. Varios
  jugadores no sabían quiénes eran los chancas ni quién era el protagonista, y algunos
  creyeron que el entrenamiento ya era el combate.
- **Respuesta en la 0.1.1:** la apertura de tres planos que muestra a los chancas, y el
  entrenamiento presentado como tal. **Sin validar** con jugadores.

### 4.4. Orientación (O1, «varios»)
- No sabían adónde ir. O1 pide flechas.
- El HUD muestra el objetivo, pero no la dirección. Sin cambios en la 0.1.1.

### 4.5. Lo que funciona
- **Estabilidad y rendimiento:** sin cuelgues ni fallos que impidan terminar, con fluidez
  4–5. Se cumplen los criterios 1–7 de §14.4 (`F5-revision-slice.md`).
- **El paisaje se siente andino:** P1 lo dice por «las estructuras» y P2 por «el paisaje» y
  «las gráficas incaicas».
- **El entrenamiento enseña:** P1 lo puntuó con 5 y P2 con 4.

### 4.6. Comentarios sueltos (una sola fuente)
- **Armamento «medieval»** (P2): es la primera crítica concreta a la ★12.
  `HISTORICAL_REFERENCES.md` todavía no tiene entradas sobre armas ni vestimenta; habría
  que documentarlas antes de cambiar nada.
- **Aliados del Apoyo** (O1): dejan de ayudar cuando un enemigo cambia de objetivo, y no
  vienen a ayudarte al acabar con el suyo.
- **Llamas sin animación de caminar** (O1).
- **«Los gráficos» como frustración** (P2). Contradice que le gusten «las gráficas
  incaicas»; seguramente se refiere a la calidad técnica y no al estilo.

## 5. Propuesta del agente: **ajustar**

**No continuar con el plan tal cual:** nadie ha puesto un 4 o un 5 al combate ni al escenario,
y las quejas coinciden entre fuentes independientes.

**No recortar ni replantear:**
- La base técnica es sólida: criterios 1–7 cumplidos, sin fallos y con buen rendimiento.
- El escenario ya transmite «Andes».
- Los problemas están **localizados y son concretos**: el bloqueo, la respuesta de los
  controles, el contexto y la orientación. No indican que la idea falle.
- La muestra es demasiado pequeña para sostener una decisión tan fuerte.

**Qué significaría «ajustar»:** una fase corta, antes del Capítulo I, centrada en lo que
han señalado los jugadores. Para cada tarea, el desarrollador decide alcance y prioridad:

1. **Bloqueo legible y fiable:**
   - revisar el arco frontal (más amplio, o que Cusi gire hacia el atacante al bloquear);
   - una pose o un efecto visible al bloquear;
   - un sonido claro cuando el bloqueo falla.
2. **Respuesta de ataque y esquiva:** medir la latencia entre la pulsación y la acción, y las
   ventanas de cancelación, con la skill `combat-tuning` y el GDD §6.5.
3. **Orientación:** un indicador ligero hacia el objetivo actual, que no tiene por qué ser
   una flecha permanente.
4. **Volver a probar** al final de esa fase con la build que salga, buscando probadores con
   más margen. Por ejemplo, un *devlog* (GDD §15, «publicar avances») que empiece antes de
   necesitar a la gente.

**Lo que esta propuesta deja fuera, para decidirlo aparte:**
- más movimientos, combos o saltos (tocaría el GDD §6.1);
- el armamento, hasta documentar el canon;
- los aliados del Apoyo y las llamas;
- la apertura «espectacular».

## 6. Lo que decide el desarrollador (tarea 9)

1. **Continuar, ajustar o recortar**, con sus motivos, en `DECISIONS/0014`.
2. **Si es «ajustar», qué entra en la fase siguiente** y su duración (§15: una fase de
   2 semanas tiene un margen del 50 %).
3. **La petición de más movimientos y combos:** se mantiene §6.1 o se revisa.
4. **Enmienda de `0013`:** dejar constancia de que F5 se cerró con 2 respuestas por falta
   de probadores, y de que la regla de decisión no se aplicó por debajo del mínimo.
5. **GDD §14.1** («defender un paso contra tres»): sin datos sobre el paso. Se propone
   dejarlo como está y volver a mirarlo en la próxima prueba.

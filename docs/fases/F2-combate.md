# F2 · Combate — nota de cierre

**Fechas:** 2026-11-13 – 2026-11-16 · **Estado:** pendiente de confirmación del desarrollador

## Criterio de salida (GDD §15)

«Pelear contra 3 guerreros es divertido» — el desarrollador jugó la arena de combate
(`scenes/tests/combat_arena.tscn`, escena principal del build) después de los ajustes de
la tarea 11 y la valoró el 2026-11-16: «está genial». Antes había visto la partida grabada
por el bot de prueba (32 s, 3 guerreros) y pedido los tres arreglos del PR #23.

## Qué se hizo

| Tarea | PR | Resultado |
| --- | --- | --- |
| 1 · Decisiones previas | #11 | `DECISIONS/0007`: ataques con resistencia parcial, sprint 8/s, animaciones gratuitas |
| 2 · Salud y resistencia | #12 | `HealthComponent`, `StaminaComponent` (gasto opcional parcial/completo y obligatorio), barras |
| 3 · Detección de golpes | #13 | `Hitbox` con barrido entre frames, `Hurtbox`, capas, hitstop |
| 4 · Ataques del jugador | #14 | `CombatComponent`: cadena de 3 ligeros y pesado como datos (`AttackData`); skill `combat-tuning` |
| 5 · Defensa | #15 | Bloqueo, parry (0,15 s) y esquiva (0,25 s de invulnerabilidad) |
| 6 · Postura | #16 | `PostureComponent`, aturdimiento y ejecución |
| 7 · Guerrero chanca: percepción | #17 | Máquina de estados, percepción (cono + línea de visión + oído), persecución en navmesh |
| 8 · Guerrero chanca: combate | #18 | Ataques telegrafiados, bloqueo, retroceso, finta, muerte; skill `enemy-from-resource` |
| 9 · EncounterDirector | #19 | 2 fichas de ataque, espaciado y separación entre guerreros |
| 10 · Arena y HUD | #20 | Arena de 3 guerreros, derrota/victoria/reinicio, HUD con postura del objetivo |
| 11 · Sensación de combate | #21, #22, #23 | Sonido (Kenney CC0) e impacto (sacudida, destello de parry, ejecución); arreglos tras la partida del bot: segundo ataque que no conectaba, cámara atraída por los cuerpos, lock-on que seguía al muerto, postura 70; sin animaciones Pro (`0008`) |
| 12 · Rendimiento | #24 | 4 enemigos en combate: 223 FPS al 83 %, 0 % de frames > 16,7 ms |
| 13 · Cierre | este PR | Esta nota y la propuesta de recálculo del plan |

## Verificación (commit `24682fa`)

- Pruebas: **223/223** en verde (gdUnit4). gdformat y gdlint sin errores (`scripts`,
  `tests`, `tools`).
- CI de `main` en verde (lint, pruebas, exportación). La primera ejecución tras el merge
  del #24 se canceló sin error; relanzada, pasó.
- Builds exportados en local: Linux (73 MB) y Windows (107 MB). El de Linux arranca.
- El build abre la arena de combate (`scenes/main.tscn` → `combat_arena.tscn`).

## Rendimiento (UHD 770, renderer Mobile, salida a 1080p)

| Escena | 3D al | FPS medio | 1 % bajo | Frames > 16,7 ms | F1 (FPS medio) |
| --- | --- | --- | --- | --- | --- |
| Arena, 3 guerreros en combate | 83 % | 228,0 | 151,6 | 0 % | — |
| Arena, 4 guerreros en combate | 83 % | 223,1 | 127,3 | 0 % | — |
| Arena, 4 guerreros en combate | 75 % | 246,8 | 152,9 | 0 % | — |
| Escena gris, jugador corriendo en círculo (mediana de 3) | 83 % | 226,6 | 100,9 | 0,04 % | 244,2 |
| Proxy de Carmenca (mediana de 3) | 83 % | 70,7 | 53,4 | 3,5 % | 83,6 |
| Proxy de Carmenca (mediana de 3) | 75 % | 87,6 | 60,7 | 0,3 % | 92,5 |

Detalle de la arena en `docs/rendimiento/2026-11-arena-combate.md`.

**Las cifras de Carmenca y de la escena gris tienen ruido.** Se midieron con el equipo
cargado (carga media entre 7 y 25 por otros programas abiertos) y variaron mucho entre
pasadas: Carmenca al 83 % dio 58,9, 70,7 y 76,2 FPS. F2 no cambió esa escena ni el render.
Al 75 % (87,6 frente a 92,5) la diferencia cabe en ese ruido. **Hay que repetir la medición
de Carmenca con el equipo en reposo al empezar F3**, que es la fase que depende de ella.

## Decisiones de la fase

- `0007` aceptada: ataques con resistencia parcial; esquiva y bloqueo con coste completo;
  sprint 8/s; animaciones gratuitas para prototipar.
- `0008` aceptada: sin animaciones UAL1 Pro en F2.
- Ajustes de combate registrados en `docs/combat-tuning-log.md` (valores iniciales,
  golpe rápido del guerrero, postura 100 → 70).

## Herramientas, skills y recursos

- Skills nuevas: `combat-tuning` (tarea 4) y `enemy-from-resource` (tarea 8).
- `tools/scene_benchmark.gd` con `--fight` y `--enemies`; `tools/arena_fight_driver.gd`.
- Recursos de terceros: Kenney Impact Sounds (CC0), en `docs/ASSET_SOURCES.md`.

## Deudas heredadas de F1

| Deuda | Estado |
| --- | --- |
| 1 · Golpes que atraviesan a alta velocidad | Resuelta: barrido entre frames en `Hitbox` (#13) |
| 2 · Guardia lateral real | Aceptada sin resolver: sin clips laterales (`0008`) |
| 3 · Marcador temporal de lock-on | Resuelta: retícula de objetivo del HUD (`TargetReticle`) |
| 4 · Escalón de 0,25 m | Sin revisar: la arena es plana |
| 5 · Resistencia parcial y sprint | Resuelta: `0007` |
| 6 · Publicar avances | Pendiente: hay un vídeo de partida del bot, pero no se ha publicado nada |

## Lo aprendido

- **Un bot que juega encuentra fallos que las pruebas no buscaban.** La partida grabada
  sacó a la luz un ataque que nunca conectaba, la cámara atraída por los cuerpos de los
  guerreros, el lock-on pegado a un muerto y ejecuciones casi imposibles. Cada uno quedó
  cubierto después con una prueba.
- **El tiempo en las pruebas tiene trampas propias del combate.** Durante el hitstop no hay
  frames de física; `process_frame` llega antes que los `_process` de los nodos; las
  pulsaciones simuladas (`just_pressed`) se pierden. Todo está en la skill
  `godot-component`.
- **Medir con el reloj real.** El hitstop encoge el `delta` y la herramienta de
  rendimiento daba FPS imposibles en combate.
- **El timing de los ataques en datos funciona.** Un segundo ataque se resolvió con el mismo
  clip a otra velocidad, sin animaciones nuevas.
- **La CI es más lenta que el equipo local.** Los umbrales de tiempo ajustados fallan allí;
  las pruebas comprueban comportamientos, no milisegundos.
- **Comprobar «0 errors | 0 failures» antes de abrir un PR.** Una vez se abrió uno con
  pruebas en rojo (#19).
- **Duración:** el GDD estimaba 6 semanas; se completó en 4 días con agentes. Ver la
  propuesta de recálculo.

## No verificado

- Rendimiento y comportamiento en **Windows** (solo se exporta).
- **Mando físico** en combate (bloqueo mantenido, cambio de objetivo con el stick).
- **Rendimiento de Carmenca con el equipo en reposo** (ver arriba).
- **Equilibrio a largo plazo:** el criterio se juzgó en una sesión de juego; la frecuencia de
  ejecuciones y la dificultad con 2 fichas solo tienen esa partida y la del bot.

## Recálculo del plan (GDD §15) — propuesta para decidir

El GDD pide recalcular al cerrar F2. Ritmo real: F0, F1 y F2 (11 semanas estimadas) se
hicieron entre el 2026-11-13 y el 2026-11-16. Ese ritmo **no se traslada tal cual** a lo que
queda:

- F3 es sobre todo arte y escenario (kit modular, terrazas, vegetación, «reconocible
  andino»). Ahí los agentes ayudan menos y el cuello de botella es la dirección artística
  y el tiempo del desarrollador en Blender y probando.
- F5 depende de personas externas: no se acelera con agentes.

| Fase | GDD | Propuesta | Por qué |
| --- | --- | --- | --- |
| F3 · Escenario de Carmenca | 5 sem | 3 sem | El código (streaming, LOD, medición) va rápido; el arte y su revisión no |
| F4 · Integración del slice | 5 sem | 3 sem | Sistemas de F1–F2 reutilizables; narrativa y apoyo nuevos (GDD §9–10) |
| F5 · Prueba externa | 2 sem | 2 sem | Depende de los probadores |
| **Total restante** | **12 sem** | **8 sem** | |

La regla del 50 % se aplicaría sobre la nueva estimación: si F3 pasa de 4,5 semanas, se
recorta alcance. **La decide el desarrollador**; si la acepta, se actualiza la tabla del
GDD §15 en este PR.

## Pasa a F3 · Escenario de Carmenca

1. **Repetir la medición de Carmenca** con el equipo en reposo antes de producir escenario.
2. **Primitivas por personaje:** cada guerrero son unas 70 k (UAL sin LOD); vigilar junto al
   presupuesto de 1,2 M cuando haya enemigos en el escenario.
3. **Animaciones Pro** (`0008`): volver a plantearlo cuando un enemigo o ataque nuevo lo
   pida; sin pasos laterales ni bloqueo animado mientras tanto.
4. **Escalón de 0,25 m** (deuda de F1): revisar en las terrazas de Carmenca.
5. **Ideas surgidas al jugar**, para decidir:
   - evitación entre guerreros en la navmesh (se rozan un instante);
   - sprint manteniendo B en el mando;
   - que los enemigos de un encuentro esperen a que el jugador se acerque.
6. **Publicar avances** (GDD §15): proponer la skill `devlog` cuando se quiera empezar.
7. **Mando físico y Windows**: probarlos en algún momento antes de F5.

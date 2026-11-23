# F6 · Diagnóstico de la respuesta de ataque y esquiva (tarea 6)

**Fecha:** 2026-11-23 · **Estado:** cifras y opciones; la decisión es del desarrollador
(tarea 7)

## La queja

P1 cambiaría «la respuesta de los controles (Esquivar y atacar)» (`F5-analisis.md`, §4.2).

## Las reglas de hoy

Tiempos reales, sacados de los `.tres` de los ataques (fase ÷ velocidad del clip):

| Acción | Comprometido, sin poder esquivar | La siguiente pulsación se acepta desde | El golpe conecta a los |
| --- | --- | --- | --- |
| Ligero 1 | 0,42 s | 0,10 s | 0,24 s |
| Ligero 2 | 0,29 s | 0 s | 0,13 s |
| Ligero 3 | 0,45 s | 0,52 s | 0,26 s |
| Pesado | 0,68 s | 1,03 s | 0,38 s |
| Esquiva | 0,65 s, sin poder atacar | — | — |

- **La esquiva cancela un ataque solo en su recuperación**, no en la anticipación ni durante
  el golpe (`DefenseComponent.request_dodge`).
- **La esquiva exige el coste completo de resistencia (20)** (`DECISIONS/0007`). Los
  ataques gastan lo que quede.
- **Las pulsaciones a destiempo se pierden:**
  - un ataque pulsado mientras esquivas se pierde;
  - una esquiva pulsada mientras atacas se pierde;
  - un ataque pulsado demasiado pronto dentro de otro se pierde.

  Solo hay un búfer para encadenar ataques, de 0,35 s antes de que se pueda encadenar.

## Cómo se midió

`tools/response_diagnosis.gd` pone a un bot a pelear en la arena:
- pulsa ataque a un ritmo fijo, y una de cada cuatro pulsaciones es un ataque pesado;
- pulsa esquivar 0,2 s antes de que cada golpe de un guerrero cercano se active, como un
  jugador que reacciona;
- con el objetivo fijado;
- `ResponseProbe` anota qué pasó con cada pulsación: empezó al momento, se guardó o se
  perdió, y por qué. También anota los golpes recibidos hasta 0,6 s después de una
  esquiva perdida.

En headless con paso fijo, 120 s por escenario. Cusi no puede morir; la resistencia es
real.

```bash
godot --headless --fixed-fps 60 --path . -s res://tools/response_diagnosis.gd -- \
    --enemies=3 --attack-every=0.7 --seconds=120
```

## Resultados

| Escenario | Esquivas | Perdidas | Por qué | Golpes recibidos (tras esquiva perdida) |
| --- | --- | --- | --- | --- |
| 1 guerrero, machacando (ataque cada 0,3 s) | 23 | **23 (100 %)** | atacando: 16 · sin resistencia: 7 | 14 (14) |
| 1 guerrero, normal (cada 0,7 s) | 23 | **22 (96 %)** | atacando: 12 · sin resistencia: 10 | 14 (14) |
| 1 guerrero, paciente (cada 1,2 s) | 24 | 6 (25 %) | atacando: 6 | 5 (5) |
| 3 guerreros, machacando | 66 | **63 (95 %)** | atacando: 34 · sin resistencia: 29 | 37 (37) |
| 3 guerreros, normal | 63 | **61 (97 %)** | atacando: 38 · sin resistencia: 23 | 37 (37) |
| 3 guerreros, paciente | 62 | 31 (50 %) | atacando: 29 · durante otra esquiva: 2 | 25 (18) |

| Escenario | Ataques | Perdidos | Por qué |
| --- | --- | --- | --- |
| 1 guerrero, machacando | 379 | 183 (48 %) | demasiado pronto: 141 · sin resistencia: 42 |
| 1 guerrero, normal | 172 | 43 (25 %) | demasiado pronto: 42 · durante la esquiva: 1 |
| 1 guerrero, paciente | 101 | 17 (17 %) | durante la esquiva: 17 |
| 3 guerreros, machacando | 379 | 189 (50 %) | demasiado pronto: 141 · sin resistencia: 42 · durante la esquiva: 6 |
| 3 guerreros, normal | 172 | 44 (26 %) | demasiado pronto: 42 · durante la esquiva: 2 |
| 3 guerreros, paciente | 101 | 28 (28 %) | durante la esquiva: 28 |

**Conclusiones:**
1. **La esquiva casi nunca responde a quien ataca a un ritmo normal:** se pierde el 96–97 %.
   **Todos los golpes que recibe Cusi llegan justo después de pulsar esquivar sin que pase
   nada.** Esto es «la respuesta de los controles».
2. **Dos causas, a partes casi iguales:**
   - estar en mitad de un ataque (anticipación o golpe), que la esquiva no cancela;
   - no tener los 20 de resistencia, porque los ataques la gastan.
3. **Los ataques pulsados a destiempo se pierden sin aviso:** del 17 al 50 %, según el
   ritmo. Machacando, casi la mitad se pierde.
4. **Lo que el jugador nota es que «no responde»:** no recibe ningún aviso de por qué no
   pasa nada.

## Opciones (tarea 7)

1. **Búfer de pulsaciones**, unos 0,3 s y ajustable:
   - una esquiva pulsada durante un ataque se hace en cuanto se puede (al empezar la
     recuperación, o antes si se elige la opción 2);
   - un ataque pulsado durante la esquiva sale al terminarla.

   **Efecto:** la pulsación no se pierde; el juego «obedece», aunque un poco después.
   **Coste:** bajo-medio, con pruebas. No cambia los tiempos de los ataques.
2. **La esquiva cancela también la anticipación de un ataque** (no el golpe activo).
   - **Efecto:** el compromiso de un ataque ligero baja de 0,42 s a unos 0,18 s (solo la
     fase activa), y el del pesado de 0,68 s a 0,30 s.
   - **Riesgo:** atacar se vuelve más seguro, porque se puede «amagar» y esquivar.
   - **Coste:** bajo, una regla en `DefenseComponent` con un valor en `DefenseTuning`.
3. **Resistencia de la esquiva:** dejar esquivar con menos del coste completo, por ejemplo
   desde 10, gastando lo que quede, como los ataques.
   - **Toca `DECISIONS/0007`** y el GDD §6.1 («sin resistencia no hay esquiva ni
     bloqueo»).
   - **Alternativa que no cambia la regla:** que la barra de resistencia parpadee y suene un
     aviso cuando una esquiva se rechaza por resistencia, para que el jugador entienda el
     motivo.
4. **Aviso de pulsación rechazada en general:** que el jugador vea y oiga por qué no pasó
   nada.

**Recomendación del agente: 1 + 2, y el aviso de resistencia de la opción 3,** sin cambiar
la regla de `0007`.
- El búfer (1) quita la sensación de que «no responde» sin tocar el ritmo de los ataques.
- Cancelar la anticipación (2) hace que esquivar a tiempo funcione de verdad cuando atacas.
- El aviso (3) explica la otra mitad de las esquivas perdidas sin abaratar la resistencia.

Las opciones 2 y 3 cambian la sensación del combate: se prueban jugando.

## No verificado

- **Es un bot:** pulsa a ritmo fijo y esquiva siempre 0,2 s antes. Una persona no es tan
  regular, pero los dos motivos de rechazo son los mismos.
- **El efecto de cada opción** se mide al implementarla, con esta misma herramienta.

## Resultado de la tarea 7 (1 + 2 + aviso, elegidas por el desarrollador)

**Qué se implementó:**
- **Búfer** (`ResponseTuning`, en `player_response.tres`):
  - una esquiva pulsada durante un golpe o durante otra esquiva se guarda 0,3 s;
  - un ataque pulsado durante una esquiva o un aturdimiento se guarda 0,3 s.
- **La esquiva corta la anticipación** de un ataque, además de la recuperación.
- **Aviso:** si la esquiva no sale por falta de resistencia, `DefenseComponent` lo avisa
  con la señal `dodge_refused` y el HUD hace parpadear en rojo la barra de resistencia.

Para medir con justicia, el bot deja ahora de atacar 0,4 s antes de cada esquiva, como
haría una persona que ve venir el golpe, y `--old-rules` mide el mismo bot con las reglas
antiguas.

**Primera medición:** con la resistencia de entonces, las reglas nuevas casi no mejoraban
nada. Las esquivas guardadas caducaban porque, al llegar su momento, no había
resistencia: solo empezaba a recuperarse tras 0,6 s sin gastar. Ataque cada 0,7 s:

| Resistencia (reglas nuevas) | 1 guerrero: esquivas perdidas / golpes | 3 guerreros |
| --- | --- | --- |
| Esquiva de 20, espera de 0,6 s (antes) | 87 % / 15 | 81 % / 44 |
| Esquiva de 12, espera de 0,6 s | 52 % / 8 | 49 % / 25 |
| **Esquiva de 20, espera de 0,3 s (elegida)** | **0 % / 1** | **26 % / 15** |
| Esquiva de 12, espera de 0,3 s | 0 % / 0 | 4 % / 9 |

Con la espera en 0,3 s, las reglas nuevas frente a las antiguas, con 3 guerreros: los
golpes recibidos bajan de 27 a 15, y ya no se pierde ninguna esquiva por estar atacando.

**Decisión del desarrollador:** espera de recuperación de 0,3 s; la esquiva sigue costando
20 (`DECISIONS/0007` sin cambios). GDD §6.5 y `combat-tuning-log.md` actualizados.

**No verificado:**
- cómo se siente jugando (más agresivo, ¿demasiado fácil?);
- el aviso de resistencia sin sonido (falta un efecto CC0).


---
name: combat-tuning
description: Ajusta los valores de combate y movimiento de Pachacútec en sus Resources (.tres) — daño, costes de resistencia, fases y ventanas de los ataques, hitstop, parry, esquiva, velocidades, cámara, lock-on — comprobando las invariantes y los rangos del GDD §6.5, y registra cada cambio con su motivo en docs/combat-tuning-log.md. Úsala siempre que el desarrollador describa una sensación de juego («el golpe se siente lento», «el pesado no pesa», «el parry es imposible», «me quedo sin resistencia muy rápido», «la cámara marea») o pida subir, bajar o cambiar un valor de combate, aunque no nombre el archivo.
---

# combat-tuning

El GDD manda que los valores de juego vivan en Resources para ajustarlos sin tocar código
(§6.5, §13.2). La sensación la decide el desarrollador con el mando en la mano; esta skill
traduce lo que siente a cambios pequeños, trazables y reversibles.

## 1. Traducir la sensación a parámetros

Pregunta por el momento concreto si no está claro («¿lento al empezar el golpe o al poder
moverte después?»). Mapa de dónde vive cada cosa:

| Sensación | Archivo | Parámetros |
| --- | --- | --- |
| El golpe tarda en salir / se siente lento | `resources/combat/attacks/*.tres` | `clip_speed` (todo el golpe) o `windup_end` |
| No puedo encadenar / encadena solo | `attacks/*.tres` | `chain_from`; `AttackRules.BUFFER_WINDOW` (código: pedir aprobación) |
| Me quedo clavado tras golpear | `attacks/*.tres` | `recovery_end`, `clip_speed` |
| El golpe no llega / llega demasiado lejos | `attacks/*.tres` | `lunge_distance` |
| Hace poco / mucho daño | `attacks/*.tres`, `*_health.tres` | `damage`, `posture_damage`, `max_health` |
| Resistencia se acaba rápido / nunca | `player_stamina.tres`, `attacks/*.tres`, `player_movement.tres` | `regen_per_second`, `regen_delay`, `stamina_cost`, `sprint_stamina_per_second` |
| El impacto no pesa / se siente pegajoso | `combat_feel.tres` | `hitstop_duration`, `hitstop_time_scale` |
| Movimiento, giro | `player_movement.tres` | velocidades, `turn_sharpness`, `lock_face_max_angle_deg` |
| Cámara, lock-on | `player_camera.tres`, `player_lock_on.tres` | encuadre, sensibilidad, alcance, umbrales |

Cambia **un parámetro por vez** salvo que el desarrollador pida otra cosa: si se cambian
tres a la vez no se sabe cuál arregló la sensación.

## 2. Comprobar antes de escribir

- **Invariantes de los ataques** (en segundos del clip): `windup_end < active_end <=
  chain_from <= recovery_end`. La prueba `test_shipped_attacks_are_consistent` lo vigila.
- **Las fases están sincronizadas con la animación** (se midieron con la velocidad de la
  mano). Para que el golpe sea más rápido, sube `clip_speed`: escala todo y mantiene la
  sincronía. Mover `windup_end`/`active_end` desincroniza el golpe del gesto; hazlo solo
  si el desarrollador lo pide explícitamente.
- **Rangos del GDD §6.5** (valores de partida, no límites duros): ventana de parry 0,15 s,
  invulnerabilidad de esquiva 0,25 s, hitstop 0,05–0,08 s, anticipación enemiga 0,6–0,8 s,
  5–6 ligeros para matar a un guerrero básico, 6–8 golpes enemigos para matar al jugador,
  2–3 parries para romper postura. Si un cambio sale de esos rangos, dilo y propón
  registrarlo como decisión (`docs/DECISIONS/`).
- **Reglas de `DECISIONS/0007`**: ataque con resistencia parcial, esquiva y bloqueo con
  coste completo, sprint con coste. No las cambies por tuning: son decisiones.

## 3. Editar el .tres

- Godot **no guarda los valores iguales al default** del script: si la línea no está en
  `[resource]`, añádela (`hitstop_duration = 0.07`). Si el nuevo valor es igual al default,
  borra la línea.
- Nunca cambies los defaults en el código para tunear: el código no es el sitio.
- Respeta el formato de Godot (decimales con punto, `&"..."` para StringName).

## 4. Verificar y registrar

```bash
godot --headless --path . --import
GODOT_BIN=$(command -v godot) bash addons/gdUnit4/runtest.sh --headless --ignoreHeadlessMode -a res://tests
```

Si una prueba falla porque fija el valor antiguo a propósito (p. ej. daño exacto), dilo y
actualízala; si falla una invariante, el cambio es incorrecto.

Añade una fila a `docs/combat-tuning-log.md` (más reciente arriba):

```markdown
| 2026-11-14 | `attacks/light_1.tres` | `clip_speed` 1.25 → 1.4 | «el primer golpe se siente lento» (prueba del desarrollador) |
```

## 5. Entregar

Rama `tuning/<tema>` y PR pequeño con la tabla de cambios y el motivo. Termina pidiendo al
desarrollador que lo pruebe: el tuning no está terminado hasta que él dice que se siente
bien. Si tras dos o tres ajustes la sensación no mejora, el problema puede no ser de números
(animación, falta de feedback, diseño): dilo.

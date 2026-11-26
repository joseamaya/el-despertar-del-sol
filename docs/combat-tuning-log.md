# Registro de ajustes de combate

Cada cambio de valores de combate o movimiento hecho con la skill `combat-tuning`, con su
motivo. Más reciente arriba.

| Fecha | Archivo | Cambio | Motivo |
| --- | --- | --- | --- |
| 2026-11-26 | `attacks/enemy/chanca_estocada.tres`, `tuning/lancer_thrust_pose.tres` | Embestida 0,5 → 0,1 m; la lanza se desliza 0,4 m por el puño al estocar (`thrust_slide`, nuevo) | F9, tarea 11: el desarrollador vio la lanza atravesando el pecho en la estocada. Al deslizarse, la contera queda delante del cuerpo. Alcance de la punta sin cambios: 2,65 m antes y después (medido) |
| 2026-11-23 | `tuning/player_stamina.tres` | `regen_delay` 0,6 → 0,3 s | F6, tarea 7: con 0,6 s, quien ataca a un ritmo normal no recupera nunca la resistencia y pierde el 81–87 % de las esquivas. Con 0,3 s, el bot de `response_diagnosis.gd` pierde el 0 % con 1 guerrero y el 26 % con 3. La esquiva sigue exigiendo sus 20 completos (`DECISIONS/0007`) |
| 2026-11-23 | `tuning/player_response.tres` (nuevo) | Búfer de esquiva 0,3 s, búfer de ataque 0,3 s, la esquiva corta la anticipación | F6, tarea 7: las pulsaciones a destiempo se perdían sin aviso (`F6-diagnostico-respuesta.md`) |
| 2026-11-23 | `tuning/player_guard_pose.tres` | Pose con escudo: antebrazo izquierdo alzado en vertical delante y a la izquierda de la cara, con la huallcanca centrada en él; torso inclinado 8°; los brazos cruzados se retiran | F6, tarea 4: el desarrollador pidió un escudo porque bloquear con la mano no es creíble (`DECISIONS/0015`). El destello sale ahora del escudo |
| 2026-11-23 | `tuning/combat_feel.tres` | Destello de bloqueo nuevo: color (0,78; 0,88; 1), 0,9 m, 0,12 s, 7 chispas a 0,9 m, sacudida 0,08 | F6, tarea 4: los jugadores no notaban que bloqueaban. Sale en la cabeza de la maza y se dibuja por encima del cuerpo, que lo tapaba desde la cámara |
| 2026-11-23 | `tuning/player_guard_pose.tres` | Pose de guardia nueva: brazos cruzados delante de la cara, maza junto al hombro izquierdo, torso inclinado 12° | F6, tarea 4: la guardia con `Sword_Idle` casi no se distinguía de estar quieto. Elegida con capturas desde la cámara del juego |
| 2026-11-23 | `tuning/player_defense.tres` | `block_face_range` nuevo: 4,0 m | F6, tarea 3: sin objetivo fijado, la guardia encara al guerrero que golpea a menos de 4 m. El diagnóstico (`F6-diagnostico-bloqueo.md`) mostró que la mayoría de los golpes entraban por fuera del arco de 120°. Arco sin cambios |
| 2026-11-14 | `tuning/chanca_warrior_posture.tres` | `max_posture` 100 → 70 | Las ejecuciones eran raras: los guerreros morían por daño antes de romperse su postura. Jugador automático, 4 partidas: 1 ejecución con 100, 7 con 70. Ahora 2 parries rompen la postura (GDD §6.5: 2–3) |
| 2026-11-14 | `attacks/enemy/chanca_estocada.tres` → `chanca_golpe_rapido.tres` | `Punch_Cross` ×0,25 → `Sword_Attack` ×0,55 (anticipación 0,6 s, 12 de daño, avance 1 m) | La estocada no conectaba nunca: con un puñetazo la maza quedaba arriba y detrás (≥ 0,8 m del cuerpo). Encontrado al grabar una partida automática |
| 2026-11-13 | `resources/combat/attacks/*.tres` | Valores iniciales | Tarea 4 de F2: fases medidas en los clips (velocidad de la mano); daños y costes de GDD §6.5 |

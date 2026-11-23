# Registro de ajustes de combate

Cada cambio de valores de combate o movimiento hecho con la skill `combat-tuning`, con su
motivo. Más reciente arriba.

| Fecha | Archivo | Cambio | Motivo |
| --- | --- | --- | --- |
| 2026-11-23 | `tuning/player_defense.tres` | `block_face_range` nuevo: 4,0 m | F6, tarea 3: sin objetivo fijado, la guardia encara al guerrero que golpea a menos de 4 m. El diagnóstico (`F6-diagnostico-bloqueo.md`) mostró que la mayoría de los golpes entraban por fuera del arco de 120°. Arco sin cambios |
| 2026-11-14 | `tuning/chanca_warrior_posture.tres` | `max_posture` 100 → 70 | Las ejecuciones eran raras: los guerreros morían por daño antes de romperse su postura. Jugador automático, 4 partidas: 1 ejecución con 100, 7 con 70. Ahora 2 parries rompen la postura (GDD §6.5: 2–3) |
| 2026-11-14 | `attacks/enemy/chanca_estocada.tres` → `chanca_golpe_rapido.tres` | `Punch_Cross` ×0,25 → `Sword_Attack` ×0,55 (anticipación 0,6 s, 12 de daño, avance 1 m) | La estocada no conectaba nunca: con un puñetazo la maza quedaba arriba y detrás (≥ 0,8 m del cuerpo). Encontrado al grabar una partida automática |
| 2026-11-13 | `resources/combat/attacks/*.tres` | Valores iniciales | Tarea 4 de F2: fases medidas en los clips (velocidad de la mano); daños y costes de GDD §6.5 |

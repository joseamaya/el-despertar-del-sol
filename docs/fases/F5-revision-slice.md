# F5 · Revisión previa de los criterios del slice (tarea 2)

**Fecha:** 2026-11-19 · **Build:** `main` 95aa11d · **Equipo:** el de referencia (Intel RPL-S
integrada, `DECISIONS/0004`), renderer Mobile

Antes de repartir la build se comprueban los criterios 1–7 de aceptación del slice (GDD
§14.4). El 8 lo mide la prueba externa (`DECISIONS/0013`). Regla de la tarea: solo se
corrige lo que impida jugar o mida mal, porque la build de la prueba debe ser esta.

## Resultado

| # | Criterio (GDD §14.4) | Estado | Evidencia |
| --- | --- | --- | --- |
| 1 | Se recorre de principio a fin sin errores críticos en una build exportada (Windows y Linux) | **Linux: sí. Windows: sí** (prueba piloto, P1 en `F5-resultados.md`) | Linux: partida del desarrollador en la build exportada (10 min, 2026-11-19); el bot termina el slice 4 veces seguidas (abajo); la build arranca con `--quit-after`. Windows: se exporta en local y en CI, pero falta jugarla en un equipo con Windows → prueba piloto (tarea 6) |
| 2 | 60 FPS estables a 1080p en el equipo de referencia | **Sí** (ver detalle) | 3 pasadas del bot al 83 %: mediana de **119 FPS**, 0,2 % de frames lentos. Al 100 %: 107 FPS. Ver «Rendimiento a 1080p» |
| 3 | Golpes sincronizados con la animación e impactos que se detectan siempre | **Sí** | `test_hitbox`: `test_fast_swings_never_tunnel`, `test_each_hurtbox_hit_once_per_activation…`; `test_player_attacks`: `test_hitbox_only_active_in_active_phase_and_hand_moves_fastest_then`; `test_attack_rules`: `test_shipped_attacks_are_consistent` (fases medidas en los clips); `test_warrior_combat`: `test_every_attack_connects_with_a_still_player_in_front` |
| 4 | Bloqueo, parry, esquiva y resistencia según la tabla de tuning | **Sí** | Valores de los `.tres` frente al GDD §6.5 (tabla siguiente) y pruebas `test_player_defense`, `test_defense_rules`, `test_stamina_rules`, `test_stamina_component` |
| 5 | Los enemigos detectan, rodean, atacan por turnos y reaccionan al daño | **Sí** | `test_chanca_warrior` (vista, oído, muro, alerta, persecución, rodeo, vuelta a casa); `test_encounter_director` y `test_encounter_three_warriors` (nunca más de 2 atacan a la vez; turnos); `test_warrior_combat` (reacción al golpe, retroceso ante el pesado, bloqueo ocasional). La prueba de aglomeración es frágil en CI (pasa a F5, `F4-integracion-del-slice.md`) |
| 6 | Condición clara de victoria y derrota, con reaparición en checkpoint | **Sí** | `test_carmenca_slice`: `test_whole_slice_reaches_the_end`, `test_defeat_in_the_second_skirmish_respawns_at_its_checkpoint`; `test_combat_arena`: `test_defeat_stops_the_player_and_shows_the_message`, `test_restart_restores_player…`; `test_carmenca_reinforcements`: una derrota en el paso lo reinicia entero |
| 7 | La decisión de Apoyo produce una diferencia visible | **Sí** | `test_support_allies`: sin llamas no viene nadie; con las llamas libres llegan 2 comuneros con cartel, cada uno entretiene a un chanca y luego a los refuerzos; `test_carmenca_slice`: `test_helping_the_family_frees_the_llamas`, `test_passing_by_leaves_the_llamas_tied` |

**Nada bloquea la prueba.** No hace falta ninguna corrección antes de repartir la build. Lo
único abierto era Windows real, y la prueba piloto (P1 en `F5-resultados.md`) lo confirmó.

## Tabla de tuning (GDD §6.5) frente a los valores del juego

| Parámetro | GDD | Juego |
| --- | --- | --- |
| Salud del jugador | 100 | 100 |
| Resistencia | 100; 30/s tras 0,6 s | 100; 30/s tras 0,6 s |
| Coste ataque ligero / pesado | 12 / 25 | 12 / 25 |
| Coste esquiva / bloqueo por golpe | 20 / 15 | 20 / 15 |
| Invulnerabilidad de la esquiva | 0,25 s | 0,25 s |
| Ventana de parry | 0,15 s | 0,15 s |
| Anticipación del ataque enemigo básico | 0,6–0,8 s | 0,66 s (`windup_end` 0,33 a velocidad 0,5) |
| Ligeros para matar a un guerrero básico | 5–6 | 6 (18 + 18 + 22 + 18 + 18 + 18 sobre 100) |
| Golpes enemigos para matar al jugador | 6–8 | 8–9 (12–14 de daño sobre 100) |
| Parries para romper la postura | 2–3 | 2 (40 cada uno sobre 70) |
| Hitstop | 0,05–0,08 s | 0,06 s |

- **Golpes enemigos para matar al jugador:** el golpe básico de 12 necesita 9 golpes, uno más
  que el máximo del rango. El rápido, de 14, necesita 8. Está en el borde y a favor del
  jugador, así que no se toca antes de la prueba. Si la prueba dice que el combate es
  demasiado fácil, es un ajuste candidato.
- **El rango del GDD es de partida, no un límite** (`combat-tuning`).

## Rendimiento a 1080p

El bot juega el slice entero con todos los sistemas, con la resolución de la ventana
(1920 × 1080) y el 3D escalado. La carga media de la máquina estuvo entre 1,2 y 6,6.

| Pasada | Escala 3D | FPS medio | 1 % bajo | Frames > 16,7 ms | p99 | Primitivas máx. | Draw calls máx. |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A | 83 % | 113,6 | 50,0 | 0,2 % | 14,1 ms | 1,07 M | 192 |
| B | 83 % | 120,7 | 56,2 | 0,2 % | 13,1 ms | 1,07 M | 189 |
| C | 83 % | 119,1 | 60,9 | 0,0 % | 12,4 ms | 1,09 M | 191 |
| **Mediana 83 %** | | **119,1** | **56,2** | **0,2 %** | **13,1 ms** | 1,07 M | 191 |
| Comparación | 100 % | 107,0 | 48,3 | 0,2 % | 14,8 ms | 1,13 M | 201 |

Peor tramo por pasada: la **exploración** (terrazas, huaca y barrio), con 101–108 FPS de
media al 83 % y un 1 % bajo de 38–49.

**Lectura de «estables»:**
- El 99,8 % de los frames dura menos de 16,7 ms, y el p99 está en 13 ms.
- Con la sincronización vertical a 60 Hz, que es lo que ve el jugador, eso supone perder un
  frame cada 4 segundos aproximadamente.
- El «1 % bajo» por debajo de 60 viene de esos tirones aislados (el peor 1 % de los frames),
  no de una caída sostenida.

**Se considera cumplido.** Si en la prueba alguien nota tirones, el primer sitio que mirar
es la exploración.

## Lo que no cubre esta revisión

- El mando físico: queda para la prueba externa. La build de Windows ya se jugó en un equipo
  con Windows en la prueba piloto.
- Equipos más lentos que el de referencia: la prueba externa dirá con qué juega cada uno,
  porque la encuesta lo pregunta (tarea 4).

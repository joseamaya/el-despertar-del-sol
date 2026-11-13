# 0007 · Reglas de resistencia y animaciones para F2

**Fecha:** 2026-11-13 · **Estado:** aceptada (decididas por el desarrollador)

## Contexto
El GDD (§6.1, §6.5) fija costes de resistencia pero deja abiertas dos reglas, detectadas
al probar la skill `godot-component` con un StaminaComponent. Además, la versión gratuita
de las animaciones (`docs/ASSET_SOURCES.md`) trae pocos clips de combate.

## Decisión

1. **Ataques con resistencia parcial: sí.** Un ataque se puede lanzar mientras quede
   resistencia (> 0); la resistencia baja hasta 0 como mínimo. La **esquiva** y el
   **bloqueo** exigen el coste completo (§6.1: «sin resistencia no hay esquiva ni
   bloqueo»). Un golpe bloqueado siempre resta; si no alcanza, rompe la guardia.
2. **El sprint gasta resistencia: sí, poco.** Valor de partida **8/s** mientras se esprinta
   con movimiento; con resistencia 0 el sprint se corta. La recuperación sigue las reglas
   de §6.5 (30/s tras 0,6 s sin gastar).
3. **Animaciones de combate: versión gratuita para prototipar.** Se usan los clips del
   paquete Standard (`Sword_Attack`, `Sword_Idle`, `Punch_Jab`, `Punch_Cross`, `Hit_Chest`,
   `Hit_Head`, `Death01`, `Roll`) y el timing de cada ataque vive en Resources de datos,
   no en las animaciones. Se decide en la **tarea 11** (sensación de combate) si hace
   falta la versión Pro (9,99 USD, CC0).

## Consecuencias
- `StaminaComponent` distingue gasto **opcional parcial** (ataque: permitido si > 0),
  **opcional completo** (esquiva) y **obligatorio** (golpe bloqueado).
- `MovementTuning` gana el coste de sprint; el sprint necesita la resistencia del jugador.
- El timing de combate (preparación, golpe activo, recuperación) se ajusta en datos, así
  que cambiar de animaciones en T11 no obliga a reescribir el sistema.
- Con la versión gratuita no hay desplazamiento lateral real ni bloqueo animado: la
  sensación de combate se juzgará con esa limitación.

## Revisar
En la tarea 11 de F2 (animaciones) y al cerrar F2.

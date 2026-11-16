# 0008 · Animaciones gratuitas en F2 (sin UAL1 Pro por ahora)

**Fecha:** 2026-11-16 · **Estado:** aceptada (decidida por el desarrollador)

## Contexto
`DECISIONS/0007` dejó para la tarea 11 de F2 la decisión de comprar la versión Pro de las
animaciones (9,99 USD, CC0). En la tarea 11 se ajustó el combate con los clips gratuitos
(el segundo ataque del guerrero reutiliza `Sword_Attack` con otro ritmo, PR #22) y el
desarrollador jugó la arena el 2026-11-16: «está genial».

## Decisión
**No se compra la versión Pro en F2.** El combate cumple su criterio con los clips del
paquete Standard, y el timing de cada ataque sigue en datos (`AttackData`).

## Consecuencias
- Sin desplazamiento lateral real ni bloqueo animado: se acepta para F2.
- Variar enemigos y ataques con los mismos clips tiene un límite visible; cuando un tipo
  de enemigo o un ataque nuevo lo necesite, se vuelve a plantear.
- La compra, si llega, la hace el desarrollador; el agente solo integra los clips.

## Revisar
Al planificar los enemigos y ataques nuevos de fases futuras (pasa como pregunta abierta
a la nota de cierre de F2).

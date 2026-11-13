# F0 · Preproducción — nota de cierre

**Fechas:** 2026-11-13 – · **Estado:** pendiente de validación por el desarrollador

## Criterio de salida (GDD §15)

| Criterio | Estado |
| --- | --- |
| GDD fijado | GDD 1.2 con las decisiones de Fase 0 |
| AGENTS.md | Creado; `CLAUDE.md` lo importa |
| Repo | GitHub privado `el-despertar-del-sol`, Git LFS configurado |
| CI | Lint + pruebas gdUnit4 + exportación Windows/Linux |
| Godot fijado | 4.7.2.stable, renderer Mobile |

## Build exportado

La CI publica los builds de Linux y Windows como artefactos de cada ejecución en `main`.
En local se verificaron la exportación de ambos y el arranque del build de Linux (headless).

## Lo aprendido

- El equipo de referencia solo tiene GPU integrada (UHD 770). Se eligió medir siempre
  en él y usar el renderer Mobile. Es la decisión de más impacto en el arte (`DECISIONS/0004`).
- gdUnit4 6.x no corre en headless sin `--ignoreHeadlessMode`; las pruebas con input
  simulado deben ir sin headless (la CI usa display virtual).
- Las advertencias de tipado como error funcionan: una variable sin tipo rompe la carga
  del script.

## No verificado

- El build de Windows no se ha ejecutado en una máquina Windows (solo se exporta en CI).
- Rendimiento: no hay nada que medir todavía; la primera medición es en F1.

## Para F1

- Escena de prueba de rendimiento en la UHD 770 (revisar `DECISIONS/0004`).
- Evaluar Jolt frente a Godot Physics.
- Activar el MCP de Godot tras revisar su código y fijar su versión.

# F3 · Escenario de Carmenca — backlog

Aprobado por el desarrollador el 2026-11-16. Criterio de salida (GDD §15): **recorrible a
60 FPS y reconocible andino**. Estimación: 3 semanas (`DECISIONS/0009`); si se pasa de 4,5,
se recorta alcance.

Alcance: el escenario del vertical slice (§14): un sector de Carmenca con terrazas, camino,
sitio de la huaca y el Cusco abajo, recorrible y con espacio para los combates. Fuera (F4):
interacción con la huaca, NPC, narrativa, Apoyo, música y ambiente, checkpoints.

| # | Tarea | Estado |
| --- | --- | --- |
| 1 | Decisiones previas (`DECISIONS/0010`, licencias del escenario) | Hecha |
| 2 | Medición de Carmenca con el equipo en reposo (deuda de F2) | Hecha: 73 FPS al 83 %, 79 al 75 %; sin regresión (A/B con F1) |
| 3 | Guía visual de una página (paleta, escala, pirca/adobe/ichu, referencias) | Hecha: variante A · amanecer cálido |
| 4 | Blockout del sector: relieve, terrazas, camino, huaca, 3 zonas de encuentro, límites; escalón de 0,25 m | Hecha: recorrido del desarrollador (2026-11-16): «es largo, pero me gusta»; terrazas cansan pero bien; zonas de buen tamaño; el paso se siente como paso |
| 5 | Kit modular v1 por script (10–15 piezas); proponer skill `godot-scene-audit` | Pendiente |
| 6 | Paisaje lejano: apus, valle del Cusco, columnas de humo | Pendiente |
| 7 | Luz de amanecer: cielo, niebla compatible con Mobile, sol rasante, sombras ~100 m | Pendiente |
| 8 | Vegetación y detalle: ichu y rocas con MultiMesh y rangos de visibilidad | Pendiente |
| 9 | Combate en el escenario: navmesh, guerreros en las zonas, pendientes | Pendiente |
| 10 | Rendimiento del recorrido guionizado: 60 FPS, < 1 % de frames > 16,7 ms | Pendiente |
| 11 | Prueba «reconocible andino»: recorrido del desarrollador, capturas, ajustes | Pendiente |
| 12 | Cierre de F3 con `phase-gate` | Pendiente |

Deudas heredadas de F2: `docs/fases/F2-combate.md`, sección «Pasa a F3».

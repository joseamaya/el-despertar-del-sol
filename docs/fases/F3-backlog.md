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
| 5 | Kit modular v1 por script (10–15 piezas); proponer skill `godot-scene-audit` | Hecha: 12 piezas en el catálogo, Carmenca vestida; skill `godot-scene-audit` creada |
| 6 | Paisaje lejano: apus, valle del Cusco, columnas de humo | Hecha: valle con parcelas, Cusco en 7 barrios, 10 apus genéricos, 4 columnas de humo |
| 7 | Luz de amanecer: cielo, niebla compatible con Mobile, sol rasante, sombras ~100 m | Hecha: ambiente cálido, fondo sin iluminar con sol cocido; relleno y glow probados y descartados; coste medido en la tarea 10: las 4 cascadas de sombra eran el 37 % de las primitivas; se pasa a 2 |
| 8 | Vegetación y detalle: ichu y rocas con MultiMesh y rangos de visibilidad | Hecha: 13.445 matas de ichu y arbustos en parcelas de 40 m, 65 m de alcance, ichu sin sombras; +45–57 k primitivas |
| 9 | Combate en el escenario: navmesh, guerreros en las zonas, pendientes | Hecha: navmesh al cargar (80–350 ms), 2+2+3 guerreros con el ArenaController de F2, persecución en pendiente; el build abre Carmenca |
| 10 | Rendimiento del recorrido guionizado: 60 FPS, < 1 % de frames > 16,7 ms; incluye el coste de la luz (tarea 7) y las primitivas del mirador (~1 M, tarea 6) | Hecha: 116,6 FPS, 0 % de frames lentos y 0,89 M primitivas con 2 cascadas y laderas de 8 m; el combate del paso, 109,6 FPS (`docs/rendimiento/2026-11-carmenca-recorrido.md`) |
| 11 | Prueba «reconocible andino»: recorrido del desarrollador, capturas, ajustes | Hecha: superada tras pasar el color de vértices a sRGB y poner tope de 8 m a las laderas; puertas rectangulares (`docs/fases/F3-prueba-andina.md`) |
| 12 | Cierre de F3 con `phase-gate` | Hecha: criterio confirmado el 2026-11-17 (`docs/fases/F3-escenario-carmenca.md`) |

Deudas heredadas de F2: `docs/fases/F2-combate.md`, sección «Pasa a F3».

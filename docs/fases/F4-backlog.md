# F4 · Integración del slice — backlog

Aprobado por el desarrollador el 2026-11-17. Criterio de salida (GDD §15): **8–12 min
completos en build exportada**. Estimación: 3 semanas (`DECISIONS/0009`); si se pasa de
4,5, se recorta alcance.

Alcance: el vertical slice 0.1 del GDD §14 sobre la Carmenca de F3. La secuencia de cinco
actos (§14.1) y lo que lista el §14.2. Fuera: la prueba con 5–10 jugadores (F5) y todo lo
del §14.3.

| # | Tarea | Estado |
| --- | --- | --- |
| 1 | Decisiones previas (`DECISIONS/0012`): textos del slice, aspecto de los personajes, qué hace el aliado del Apoyo, fuentes CC0 de audio, alcance de la visión | Hecha: borradores del agente, comuneros que distraen, tintes y accesorios, siluetas en la niebla |
| 2 | Esqueleto del recorrido: director que encadena los 5 actos por zonas y señales, checkpoints con reaparición, victoria y derrota | Hecha: `SliceDirector` con la secuencia en datos, un encuentro por zona, 4 checkpoints, «Fin» y volver a empezar |
| 3 | Diálogo mínimo: caja de texto con `tr()`, líneas en `.tres`, Vicaquirao en el mirador | Hecha: caja de diálogo, `DialoguePlayer`, paso `DIALOGUE` del slice; apertura de 5 líneas aprobada; acción `interact` (E / A) |
| 4 | Huaca: interacción, ofrenda y visión breve (siluetas de piedra en la niebla, compatible con Mobile) | Hecha: aviso «ofrendar hojas de coca», +10 de resistencia máxima, visión de 6 s con 6 figuras de piedra, línea de Cusi |
| 5 | Códice: una entrada con su etiqueta (Documentado / Según los cronistas / Licencia del juego) | Hecha: entrada «Huaca» (Según los cronistas) al terminar la visión; aviso y pantalla con Tab / Back, que pausa el juego |
| 6 | Decisión de Apoyo: la familia y las llamas, aceptar o seguir, con diferencia visible en el combate del paso | Hecha: familia, elección y llamas (#43); 2 comuneros que distraen a 2 chancas en el paso |
| 7 | Cierre: pututus chancas, Cusi Yupanqui mira al Cusco, fin | Hecha: Cusi gira hacia el Cusco, rótulo de pututus (sonido en la tarea 9), dos líneas y 3 s mirando el valle |
| 8 | Interfaz: menú de pausa y ajustes básicos (volumen, sensibilidad, escala 3D) guardados con un autoload | Hecha: pausa con Esc / Start; volumen, sensibilidad y calidad gráfica (75/83/100 %, por defecto 83 %) en el autoload `Settings` |
| 9 | Audio: ambiente, pasos y una pieza musical | Hecha: viento, pasos por superficie, música provisional (apertura y cierre), pututu en el paso y en el cierre, visión amortiguada |
| 10 | Personajes: Cusi Yupanqui, Vicaquirao y el comunero distinguibles (tintes y accesorios por script) | Hecha: `CharacterLook` por personaje; Cusi (unku rojo y amarillo, llauto, orejeras), Vicaquirao (unku ocre, llauto), comunero (unku pardo, manta), también los del paso |
| 11 | Mando físico y build de Windows (deuda de F3) | Hecha en lo posible: mapa de mando probado (A/B arreglados en menús) y F3 con FPS; build de Windows con un tester (`F4-prueba-windows.md`); mando físico pasa a F5 (el resultado de Windows y el mando físico pasan a F5) |
| 12 | Partida completa: 8–12 min en la build exportada, rendimiento con todo integrado, partida de bot de principio a fin | Hecha: bot de principio a fin (3 min 55 s, 124,6 FPS, 0,1 % lentos en reposo); partida del desarrollador en la build exportada: **10 min** (antes 4 min 28 s → 12a y 12b) |
| 12a | Tutorial con Vicaquirao en el mirador: bloquear, parry, esquivar y golpear (GDD §5.2) | Hecha: 4 ejercicios con objetivos, Vicaquirao no hace daño ni cae; flag `skip_training` |
| 12b | Refuerzos en el paso: 3 chancas más tras los 3 primeros, anunciados con el pututu | Hecha: bajan desde lo alto tras el pututu y el cartel; los comuneros libres los entretienen; una derrota reinicia el paso; nunca más de 3 chancas a la vez |
| 12c | Carmenca recién abandonada: más casas, señales de huida, pocas personas (familias bajando, ancianos, leales) | Hecha: 10 casas en una sola malla, fogones humeantes y objetos tirados, una familia de 4 que baja por el mirador y se va, 2 ancianos y 2 leales; licencia histórica propuesta, la registra el desarrollador |
| 13 | Cierre de F4 con `phase-gate` | Hecha: `docs/fases/F4-integracion-del-slice.md`; criterio confirmado el 2026-11-19 |

**Qué se recorta primero** si se pasa de 4,5 semanas:
1. La visión de la huaca se reduce a un destello y un texto.
2. La música: queda solo el ambiente.
3. El aliado del Apoyo: la diferencia visible pasa a ser un guerrero chanca menos en el
   paso.

Las ideas de combate de F2 (evitación entre guerreros, sprint con B, enemigos que esperan)
solo entran si aparecen al jugar el slice completo.

Deudas heredadas de F3: `docs/fases/F3-escenario-carmenca.md`, sección «Pasa a F4».

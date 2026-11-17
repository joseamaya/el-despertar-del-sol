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
| 4 | Huaca: interacción, ofrenda y visión breve (siluetas de piedra en la niebla, compatible con Mobile) | Pendiente |
| 5 | Códice: una entrada con su etiqueta (Documentado / Según los cronistas / Licencia del juego) | Pendiente |
| 6 | Decisión de Apoyo: la familia y las llamas, aceptar o seguir, con diferencia visible en el combate del paso | Pendiente |
| 7 | Cierre: pututus chancas, Cusi Yupanqui mira al Cusco, fin | Pendiente |
| 8 | Interfaz: menú de pausa y ajustes básicos (volumen, sensibilidad, escala 3D) guardados con un autoload | Pendiente |
| 9 | Audio: ambiente, pasos y una pieza musical | Pendiente |
| 10 | Personajes: Cusi Yupanqui, Vicaquirao y el comunero distinguibles (tintes y accesorios por script) | Pendiente |
| 11 | Mando físico y build de Windows (deuda de F3) | Pendiente |
| 12 | Partida completa: 8–12 min en la build exportada, rendimiento con todo integrado, partida de bot de principio a fin | Pendiente |
| 13 | Cierre de F4 con `phase-gate` | Pendiente |

**Qué se recorta primero** si se pasa de 4,5 semanas:
1. La visión de la huaca se reduce a un destello y un texto.
2. La música: queda solo el ambiente.
3. El aliado del Apoyo: la diferencia visible pasa a ser un guerrero chanca menos en el
   paso.

Las ideas de combate de F2 (evitación entre guerreros, sprint con B, enemigos que esperan)
solo entran si aparecen al jugar el slice completo.

Deudas heredadas de F3: `docs/fases/F3-escenario-carmenca.md`, sección «Pasa a F4».

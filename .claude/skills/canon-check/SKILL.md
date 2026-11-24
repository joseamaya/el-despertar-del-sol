---
name: canon-check
description: Revisa los textos de Pachacútec (diálogos, rótulos, objetivos, entradas del códice, nombres de misiones y ayllus) contra el canon registrado en docs/HISTORICAL_REFERENCES.md y el GDD §3, marca la etiqueta que les corresponde (Documentado / Según los cronistas / Licencia del juego) y señala lo que no está registrado, contradice el registro o rompe lo que «no se cambia». Úsala siempre antes de escribir o cambiar textos visibles del juego o del códice, cuando el desarrollador pregunte «¿esto es histórico?», «¿está en el canon?», «revisa los textos» o «canon-check», y al cerrar una tarea que añada filas de texto a localization/*.csv o recursos de diálogo.
---

# canon-check

El GDD permite licencias sin límite con una condición: **quedan registradas** (§3.1). Esta
skill no decide el canon —eso es del desarrollador (AGENTS.md, «Lo que no decide un
agente»)—; comprueba que cada afirmación histórica de un texto está registrada con su
etiqueta, y si no, lo dice y propone la entrada.

## 1. Reunir los textos

- **Qué revisar:** las filas nuevas o cambiadas de `localization/*.csv` (columna `es`, la
  original) y los recursos de diálogo y códice tocados (`resources/dialogue/`,
  `resources/codex/`). Con una rama: `git diff main -- localization resources/dialogue
  resources/codex`.
- **Qué no:** textos de interfaz sin contenido histórico (botones, ajustes, controles).
  Se listan como «sin contenido histórico» y no se revisan más.

## 2. Separar las afirmaciones

Parte cada texto en afirmaciones sueltas, una por hecho: un nombre propio, un lugar, una
fecha, un parentesco, un suceso, una práctica, un objeto. «El Inca Viracocha deja la
ciudad con su hijo Urco, camino de Caquia Xaquixaguana» son cuatro: Viracocha deja el
Cusco; Urco es su hijo; se va con él; el destino es Caquia Xaquixaguana.

## 3. Buscar cada afirmación en el registro

Por orden:

1. `docs/HISTORICAL_REFERENCES.md`: episodios (GDD §3.2) y «Otras licencias registradas».
2. GDD §3 (canon, Pururaucas, cosmovisión, lo que no se cambia) y §5 (personajes).
3. Las decisiones de canon (`docs/DECISIONS/`, p. ej. `0015`, `0017`) y su documento de
   fase (`docs/fases/F7-canon-capitulo-1.md`).

Resultado por afirmación:

| Estado | Qué significa | Qué hacer |
| --- | --- | --- |
| **Registrada** | Coincide con una entrada | Anotar la etiqueta y la fila |
| **Contradice** | El registro dice otra cosa (lugar, momento, quién) | Error: proponer el texto corregido |
| **Sin registrar** | No aparece | Proponer la entrada nueva con su etiqueta y fuente; **no** añadirla sin el OK del desarrollador |
| **Rompe §3.5** | Material de otra época o cultura, chancas como monstruos, conquista española | Error: proponer otro texto |

No inventes fuentes. Si una afirmación parece histórica pero no tienes la fuente leída, la
etiqueta propuesta es «Licencia del juego» con la nota «sin fuente consultada».

## 4. Comprobaciones de forma

- **Nombres:** la grafía del registro (Vicaquirao, Uscovilca, Caquia Xaquixaguana,
  Vilcaconga, Carmenca…), igual en es y en. Los términos quechuas se mantienen en inglés.
- **Ambigüedad de lo sobrenatural** (GDD §3.3, `0017`): ningún texto explica los
  Pururaucas ni dice quién es la figura de Susurpuquio.
- **Nombres provisionales** (ayllus, misiones): se marcan como tales; no son canon hasta
  que el desarrollador los fije.

## 5. Informe

Escribe el informe en la conversación (o en el documento de la tarea si es largo):

```markdown
## canon-check · <qué se revisó>

| Clave | Afirmación | Estado | Etiqueta | Fuente / fila del registro |
| --- | --- | --- | --- | --- |

**Errores:** … (contradicciones y §3.5), con el texto propuesto.
**Entradas propuestas para HISTORICAL_REFERENCES.md:** … (pendientes del desarrollador).
**Sin contenido histórico:** claves.
```

Si hay errores, la tarea no se da por terminada hasta corregirlos o hasta que el
desarrollador los acepte como licencia y se registren.

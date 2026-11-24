# F8 · canon-check de los textos del prólogo y del capítulo (tarea 9)

Primer uso de la skill `canon-check` (`.claude/skills/canon-check/SKILL.md`). Revisa las filas
de `localization/ui.csv` añadidas en F8 (tareas 4–8) contra `HISTORICAL_REFERENCES.md`, el
GDD §3 y `DECISIONS/0017`.

**Resultado:**
- **Sin errores:** ninguna afirmación contradice el registro ni rompe GDD §3.5.
- **2 entradas nuevas en el registro**, aprobadas por el desarrollador (sección 2).
- **Los nombres de misiones y ayllus son provisionales.**

## 1. Afirmaciones

| Clave | Afirmación | Estado | Etiqueta | Fuente / fila del registro |
| --- | --- | --- | --- | --- |
| `CTX_PROLOGUE_1` | Cusco, hacia 1438 | Registrada | Según los cronistas | «Fecha» (Cabello Valboa) |
| `CTX_PROLOGUE_1` | Uscovilca acampa en Vilcaconga, a siete leguas | Registrada | Según los cronistas | «Campamento chanca» (Betanzos, caps. VI–VII) |
| `CTX_PROLOGUE_2` | El Inca Viracocha deja la ciudad | Registrada | Según los cronistas | «Huida» (Betanzos) |
| `CTX_PROLOGUE_2` | Urco es su hijo y se va con él | Registrada | Según los cronistas | «Huida»; GDD §5 (Urco, heredero) |
| `CTX_PROLOGUE_2` | Camino de Caquia Xaquixaguana | Registrada | Según los cronistas | «Huida» (Betanzos, cap. VII) |
| `CTX_PROLOGUE_3` | Muchos se van con él | Registrada en parte | Según los cronistas + Licencia | Betanzos, índice del cap. VI («llevando consigo todos los de la ciudad»). La fila «Carmenca a medio vaciar» habla de Carmenca, no del Cusco: ver propuesta 2 |
| `CTX_PROLOGUE_3` | Cusi Yupanqui se queda | Registrada | Según los cronistas | «Huida» |
| `OBJ_PROLOGUE` | Vicaquirao lo espera en el Cusco | Registrada | Según los cronistas + Licencia | «Aliados» y «Huida» (Betanzos, cap. VII) |
| `OBJ_PROLOGUE` | Una calle del Cusco | Sin registrar | Licencia del juego | Ver propuesta 1 |
| `MISSION_PROLOGUE` | «La corte se va» | Registrada | Según los cronistas | «Huida» |
| `MISSION_CARMENCA` | «Amanecer en Carmenca» | Registrada | Licencia del juego | El slice (F3–F4) |
| `MISSION_LLAMAS`, `MISSION_PRISONERS`, `MISSION_DISPUTE` | Misiones de Apoyo | Provisional | Licencia del juego | GDD §8.2. Se revisan al escribir cada misión (F10) |
| `MISSION_SHOW_OF_FORCE` | «Ante los curacas»: Cusi demuestra que tiene gente | Registrada | Según los cronistas | «Curacas vecinos» (Betanzos, cap. VII) |
| `MISSION_SUSURPUQUIO` | Susurpuquio | Registrada | Según los cronistas + Licencia | «Visión de Susurpuquio» (`0017`) |
| `AYLLU_*`, `CURACA_C` | Nombres de ayllus y curaca | Provisional | Licencia del juego | Sin nombre propio hasta las misiones (F10) |
| `NOTICE_SUPPORT_*` | Un ayllu simpatiza o se alía con Cusi | Registrada | Licencia del juego | Sistema de Apoyo (GDD §8.2), basado en «Curacas vecinos» |

**Forma:**
- Las grafías coinciden con el registro (Uscovilca, Vilcaconga, Caquia Xaquixaguana, Vicaquirao).
- En inglés se mantienen los nombres propios.
- Ningún texto explica lo sobrenatural.

**Sin contenido histórico:** `TITLE_*`, `PAUSE_*`, `LOADING`, `DOOR_PROMPT`, `NOTICE_TEST_DOOR`, `MISSION_DONE`, `MISSION_GO_ON` y `SUPPORT_*`.

## 2. Entradas para `HISTORICAL_REFERENCES.md`

Aprobadas por el desarrollador el 2026-11-24 y añadidas al registro.

1. **Calle del Cusco del prólogo:** casas de pirca y adobe con techo de ichu a ambos lados de una calle recta. Es **Licencia del juego**: no reproduce un trazado real, igual que la disposición de Carmenca. Revisar con especialista. Se decide en F8, tarea 8.
2. **El Cusco se vacía con la corte:** mucha gente sale de la ciudad con Viracocha y lleva sus fardos. Es **Según los cronistas + Licencia**: Betanzos, índice del cap. VI, dice «llevando consigo todos los de la ciudad»; quién y cuántos es licencia. Amplía la fila «Carmenca a medio vaciar» al Cusco.

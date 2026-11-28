# Rendimiento · carga de los niveles dentro del capítulo (F10, tarea 3)

**Fecha:** 2026-11-27 · **Equipos:** la GPU de referencia (Intel RPL-S, Vulkan, ventana
de 1600×900) y este mismo equipo **fuera de pantalla** (`xvfb-run`, llvmpipe) ·
**Renderer:** Mobile · **Herramienta:** `tools/chapter_load_probe.gd`, nueva.

**Para qué:** deuda 3 de F9. El frame de 3 s del centro se había medido con la escena
suelta, no con el juego de verdad: armazón, pantalla de carga y partida.

**Cómo se midió:** la sonda juega el capítulo por señales: prólogo → Carmenca → centro →
una misión → centro. De cada nivel apunta dos cosas:
- **Carga:** lo que dura la pantalla de carga, desde la petición hasta que el nivel está
  en el árbol. Incluye construir el sector y hornear el navmesh.
- **Peor frame después:** el frame más lento de los 90 siguientes. Es lo que nota el
  jugador cuando la pantalla ya se ha ido.

La partida se guarda en el archivo de `PROBE_SAVE`, nunca en `user://partida.json`.

**En la GPU de referencia** (tres pasadas con la máquina descargada; la tabla da el
intervalo):

| Nivel | Carga | Peor frame después |
| --- | --- | --- |
| Prólogo | 0,54–0,55 s | 65–67 ms |
| Carmenca | 1,26–1,32 s | 46–47 ms |
| **Centro** (desde Carmenca) | **2,40–2,43 s** | **58–61 ms** |
| Misión provisional | 0,35–0,38 s | 43–51 ms |
| **Centro** (vuelta de una misión) | **2,45–2,51 s** | **59–64 ms** |

**Fuera de pantalla** (una pasada):

| Nivel | Carga | Peor frame después |
| --- | --- | --- |
| Prólogo | 0,76 s | 642 ms |
| Carmenca | 0,95 s | 500 ms |
| Centro (desde Carmenca) | 1,45 s | 545 ms |
| Misión provisional | 0,29 s | 467 ms |
| Centro (vuelta de una misión) | 1,42 s | 509 ms |

**Corrección:** la primera versión de la sonda contaba como «peor frame después» el
propio frame en que se monta el nivel, que va dentro de la carga. Por eso daba un tirón
de ~1,8 s fuera de pantalla que no existía. Ya está corregida, y las tablas de arriba son
las de la sonda corregida.

## Lo que dice

- **La carga del centro dura unos 2,5 s en la GPU de referencia,** tapados por la pantalla
  de carga. Es más que fuera de pantalla (1,4 s). Casi todo es un solo frame: montar el
  nivel (construir el sector y hornear el navmesh) ocurre de golpe (con la sonda sin
  corregir, ese frame medía 2,47 s), después de cargar la
  escena en segundo plano. Durante ese frame la pantalla de carga se queda quieta.
- **Después no hay tirón:** el peor frame tras la carga es de unos 60 ms (el
  primer dibujo), no un parón de segundos.
- **Si 2,5 s de pantalla de carga parecen mucho,** lo indicado es repartir el montaje del
  centro en varios frames, o hornear el navmesh en el editor. No se propone ahora: no
  hay criterio de salida de la fase que lo pida.

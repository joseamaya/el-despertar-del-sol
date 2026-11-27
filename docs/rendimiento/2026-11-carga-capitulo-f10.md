# Rendimiento · carga de los niveles dentro del capítulo (F10, tarea 3)

**Fecha:** 2026-11-27 · **Equipo:** este, **fuera de pantalla** (`xvfb-run`, llvmpipe) ·
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

| Nivel | Carga | Peor frame después |
| --- | --- | --- |
| Prólogo | 0,85 s | 963 ms |
| Carmenca | 1,00 s | 1.518 ms |
| **Centro** (desde Carmenca) | **1,25 s** | **1.792 ms** |
| Misión provisional | 0,31 s | 758 ms |
| **Centro** (vuelta de una misión) | **1,50 s** | **1.783 ms** |

## Lo que dice

- **La carga del centro, 1,3–1,5 s,** queda tapada por la pantalla de carga. No se alarga
  dentro del capítulo.
- **Después hay un tirón de unos 1,8 s,** ya sin pantalla de carga. En cada nivel coincide
  con el primer frame que se dibuja. Fuera de pantalla, con llvmpipe, compilar los shaders
  es mucho más lento que en una GPU. En la GPU de referencia, el benchmark de la tarea 1 no
  tuvo ningún frame de más de 25 ms en sus dos últimas pasadas.
- **Sin medir:** la sonda en la GPU de referencia, que hace falta abrir ventana. Si allí el
  tirón sigue, lo indicado es mantener la pantalla de carga un frame más, hasta después del
  primer dibujo, en vez de repartir la construcción.

# Rendimiento · carga de niveles (F8, tarea 3)

**Fecha:** 2026-11-24 · **Equipo:** el de referencia (Intel RPL-S integrada) · **Renderer:**
Mobile · **Ventana:** 1920 × 1080.

Tiempo desde «Nueva partida» hasta Carmenca en el árbol, medido por `LevelHost`
(`last_load_seconds`). Carga en segundo plano con `ResourceLoader.load_threaded_request`.
Herramienta: `tools/shell_capture.gd`.

| Pasada | Carga media de la máquina | Carmenca |
| --- | --- | --- |
| 1 (título liso) | 2,9 | 1,91 s |
| 2 (título con imagen) | 2,9 | 2,82 s |
| 3 (título con imagen) | 2,9 | 3,09 s |

- **Entre 2 y 3 s,** con la pantalla de carga a la vista. Es razonable para un nivel entero.
- **La imagen del título no debería influir,** porque ya está cargada al pulsar. La variación
  parece ruido: la máquina no estaba en reposo. Se repetirá en reposo al cerrar F8, con el
  centro y el prólogo.
- **No incluye** el tiempo que el nivel tarda después en generar el sector: el terreno y el
  kit se construyen en `_ready`, así que forma parte de esos segundos.

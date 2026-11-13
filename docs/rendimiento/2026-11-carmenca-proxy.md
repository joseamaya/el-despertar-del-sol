# Medición de rendimiento · proxy de Carmenca (F1, tarea 3)

**Fecha:** 2026-11-13 · **Equipo de referencia:** i7-13700, Intel UHD 770 (RPL-S), 32 GB, Linux (Wayland) · **Godot:** 4.7.2

## Objetivo

Cerrar la revisión pendiente de `DECISIONS/0004`: ¿llega el renderer Mobile a 60 FPS a
1080p con una carga parecida a la de Carmenca, y llegaría Forward+?

## Escena y método

`scenes/tests/perf_carmenca_proxy.tscn` (proxy de carga, no arte):

- Ladera de 40 terrazas con muros de pirca, 30 casas de adobe con techo de ichu.
- 2000 rocas y 1500 matas de ichu con MultiMesh.
- Sol con sombras, 4 luces puntuales (2 con sombras), niebla de profundidad y de altura, glow.
- 4 cápsulas (jugador y 3 guerreros).
- ~270 draw calls y ~0,94 M primitivas por frame.

`scripts/core/perf_benchmark.gd`: vsync desactivado, render interno fijo a **1920×1080**
(escalado a la ventana), 3 s de calentamiento y 30 s de captura con la cámara orbitando
la ladera. Tres repeticiones por configuración; se reporta la **mediana**.

```bash
godot --path . res://scenes/tests/perf_carmenca_proxy.tscn --rendering-method mobile \
    -- --benchmark --out=/ruta/resultado.json
# Forward+: --rendering-method forward_plus · con efectos: añadir --effects tras --
```

## Resultados (mediana de 3)

| Configuración | FPS medio | 1 % bajo | p99 frame | Frames > 16,7 ms | VRAM |
| --- | --- | --- | --- | --- | --- |
| **Mobile** | **87,9** | **76,6** | **13,0 ms** | **0 %** | 175 MB |
| Forward+ | 57,5 | 35,2 | 23,2 ms | 40,9 % | 230 MB |
| Forward+ con niebla volumétrica y SSAO | 41,7 | 26,2 | 33,5 ms | 100 % | 265 MB |

Repeticiones (FPS medio): Mobile 87,9 / 86,6 / 97,6 · Forward+ 46,8 / 57,5 / 58,1 ·
Forward+ con efectos 30,0 / 45,8 / 41,7.

| Mobile | Forward+ | Forward+ con efectos |
| --- | --- | --- |
| ![Mobile](img/2026-11-carmenca-proxy-mobile.jpg) | ![Forward+](img/2026-11-carmenca-proxy-forward_plus.jpg) | ![Forward+ con efectos](img/2026-11-carmenca-proxy-forward_plus_fx.jpg) |

## Conclusiones

1. **Mobile cumple con margen:** ningún frame pasa de 16,7 ms y el 1 % más lento va a
   ~77 FPS (13 ms). Quedan ~3,7 ms por frame para lo que el proxy no tiene.
2. **Forward+ no cumple** ni sin efectos: 4 de cada 10 frames pasan del presupuesto.
   Con niebla volumétrica y SSAO no llega a 60 en ningún frame.
3. A este nivel de detalle, Mobile y Forward+ se ven prácticamente iguales.
4. **Se confirma `DECISIONS/0004`** (renderer Mobile, sin efectos exclusivos de Forward+).

## Presupuesto propuesto para F3

Valores orientativos para no perder el margen; se vuelven a medir con el escenario real.

| Recurso | Proxy | Presupuesto F3 |
| --- | --- | --- |
| Draw calls por frame | ~270 | ≤ 350 |
| Primitivas por frame | ~0,94 M | ≤ 1,2 M |
| Luces con sombras | sol + 2 | sol + 2 |
| VRAM | 175 MB | ≤ 1 GB (memoria compartida) |
| 1 % bajo | 76,6 FPS | ≥ 65 FPS |

## Lo que el proxy no mide

- **CPU de juego:** IA, animación esquelética, física de combate, UI. Hoy el margen es de
  GPU; los personajes animados (F2) y la IA son el siguiente riesgo.
- **Personajes con skinning**, partículas y transparencias (humo, niebla en tarjetas).
- **Windows:** solo se midió en Linux.
- **Ruido:** una sola máquina, con la carga de fondo del momento (la repetición 3 de Mobile
  salió un 11 % más rápida). La mediana amortigua, no elimina.

## Nota sobre la pantalla

El monitor del equipo de referencia es **1600×900**. La medición se hizo a 1080p internos,
como pide el GDD; a resolución nativa del monitor el rendimiento sería mayor.

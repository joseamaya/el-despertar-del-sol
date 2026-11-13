# Medición de rendimiento · proxy de Carmenca (F1, tarea 3)

**Fecha:** 2026-11-13 · **Equipo de referencia:** i7-13700, Intel UHD 770 (RPL-S), 32 GB, Linux (Wayland), monitor 1600×900 · **Godot:** 4.7.2

## Resumen

- **Ningún renderer llega a 60 FPS estables a 1080p nativos** en un escenario con relieve.
  Mobile se queda en 60 FPS de media con 1 de cada 5 frames por encima de 16,7 ms.
- **El límite es la cantidad de píxeles** (fill rate de la GPU integrada), no la geometría
  ni las sombras.
- **Renderizando el 3D al 75–83 % de 1080p**, Mobile cumple: 76–88 FPS de media y menos del
  0,5 % de frames lentos. La interfaz sigue a 1080p nítidos.
- **Forward+ queda descartado:** 44 FPS de media a 1080p.

## Escena y método

`scenes/tests/perf_carmenca_proxy.tscn` (proxy de carga, no arte):

- Terreno de 640×640 m con relieve: valle llano, ladera que sube hacia el norte, una
  quebrada y colinas; un anillo de 14 cerros lejanos (apus) a 420–650 m.
- Ladera con 40 terrazas y muros de pirca, 30 casas de adobe con techo de ichu.
- 2000 rocas y 1500 matas de ichu con MultiMesh.
- Sol con sombras hasta 250 m, 4 fogatas (2 con sombras), niebla de profundidad y de altura, glow.
- 4 cápsulas (jugador y 3 guerreros).

`scripts/core/perf_benchmark.gd`: vsync desactivado, salida a **1920×1080** (escalada a la
ventana), 3 s de calentamiento y 30 s con la cámara orbitando la ladera.

```bash
godot --path . res://scenes/tests/perf_carmenca_proxy.tscn --rendering-method mobile \
    -- --benchmark --out=/ruta/resultado.json
# Forward+: --rendering-method forward_plus · efectos: --effects · 3D al 75 %: --scale3d=0.75
```

## Resultados a 1080p nativos (mediana de 3)

| Configuración | FPS medio | 1 % bajo | p99 frame | Frames > 16,7 ms |
| --- | --- | --- | --- | --- |
| Mobile | 60,1 | 35,5 | 20,0 ms | 19,5 % |
| Forward+ | 44,1 | 35,1 | 26,2 ms | 100 % |
| Forward+ con niebla volumétrica y SSAO | 31,2 | 14,6 | 48,4 ms | 99,9 % |

~286 draw calls (Mobile) / ~425 (Forward+) y ~1,2 M primitivas por frame.

| Mobile | Forward+ | Forward+ con efectos |
| --- | --- | --- |
| ![Mobile](img/2026-11-carmenca-proxy-mobile.jpg) | ![Forward+](img/2026-11-carmenca-proxy-forward_plus.jpg) | ![Forward+ con efectos](img/2026-11-carmenca-proxy-forward_plus_fx.jpg) |

## Qué lo encarece (Mobile, media de 2 pasadas)

| Variante | FPS medio | 1 % bajo | Frames > 16,7 ms |
| --- | --- | --- | --- |
| Base (sombras del sol a 250 m) | 60,1 | 35,5 | 19,5 % |
| Sombras del sol a 100 m | 63,8 | 42,5 | 1,7 % |
| Fogatas sin sombras | 62,1 | 43,9 | 12,4 % |
| Sombras del sol a 100 m y fogatas sin sombras | 63,4 | 46,8 | 5,8 % |
| Sin sombras del sol (cota superior) | 75,5 | 51,4 | 14,5 % |
| **3D al 83 % (≈ 1600×900)** | **76,0** | 49,9 | **0,3 %** |
| **3D al 75 % (1440×810)** | **88,1** | 60,7 | **0,1 %** |

- Quitar las sombras del sol elimina ~1 M primitivas por frame y aun así quedan frames
  lentos: la geometría no es el límite.
- Bajar la resolución del 3D es lo único que lo resuelve de verdad.
- Acortar la distancia de sombras a 100 m ayuda (y es razonable en tercera persona).

## Primera ronda: sin relieve

La primera versión del proxy tenía suelo plano y sin cerros. Mobile daba 87,9 FPS de media
(1 % bajo 76,6) y Forward+ 57,5 (35,2). **Esa medición sobreestimaba el margen**: un
terreno con relieve llena la pantalla de superficie iluminada y con niebla en todas
direcciones. Se descartó a favor de la actual.

## Conclusiones

1. Se mantiene el **renderer Mobile**; Forward+ va peor en todos los casos.
2. Para cumplir 60 FPS en el equipo de referencia hace falta **renderizar el 3D por debajo
   de 1080p**. Decidido en `DECISIONS/0005`: 3D al 75–83 % con salida a 1080p.
3. **Sombras del sol hasta ~100 m** como valor de partida.

## Presupuesto propuesto para F3

Orientativo, para no perder el margen; se vuelve a medir con el escenario real.

| Recurso | Proxy | Presupuesto F3 |
| --- | --- | --- |
| Resolución del 3D en el equipo de referencia | 100 % | 75–83 % |
| Draw calls por frame | ~286 | ≤ 350 |
| Primitivas por frame | ~1,2 M | ≤ 1,2 M |
| Distancia de sombras del sol | 250 m | ~100 m |
| Luces con sombras además del sol | 2 | ≤ 2 |
| Frames > 16,7 ms | 19,5 % | < 1 % |

## Lo que el proxy no mide

- **CPU de juego:** IA, animación esquelética, física de combate, UI.
- **Personajes con skinning**, partículas y transparencias.
- **Calidad visual del escalado:** las cifras dicen que llega a 60; si el 3D al 75–83 % se
  ve bien en tu monitor lo decides tú (sobre todo con FSR 1 frente a bilineal).
- **Windows:** solo se midió en Linux.
- **Ruido:** una sola máquina con carga de fondo; el 1 % bajo varía mucho entre pasadas
  (p. ej. 27,8 frente a 60,0 en la misma variante). Las medias y el porcentaje de frames
  lentos son más estables.

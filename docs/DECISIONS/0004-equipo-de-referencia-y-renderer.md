# 0004 · Equipo de referencia con GPU integrada y renderer Mobile

**Fecha:** 2026-11-13 · **Estado:** aceptada

## Contexto
El GDD (§17) proponía una referencia de gama media (GTX 1660 / RX 6600). El equipo de
desarrollo tiene un Intel Core i7-13700, 32 GB de RAM y solo gráfica integrada
**Intel UHD Graphics 770**, unas cuatro veces menos potente que una GTX 1660.
El desarrollador prefiere que el criterio de 60 FPS se pueda medir siempre en su equipo.

## Decisión
- **Equipo de referencia:** i7-13700 + Intel UHD 770 + 32 GB, Linux. 60 FPS a 1080p.
- **Renderer:** Mobile (Vulkan). Es el más ligero que mantiene luces y sombras
  dinámicas y glow con calidad razonable en GPU integrada.
- El build de Windows se valida solo en CI (no hay equipo Windows).

## Consecuencias
- Sin efectos exclusivos de Forward+: SDFGI, VoxelGI, niebla volumétrica, SSAO/SSIL, SSR.
  La niebla y la luz rasante (GDD §10.1) se logran con niebla de profundidad/altura,
  tarjetas de niebla, luz direccional con sombras, cielos pintados e iluminación horneada
  (LightmapGI) donde sirva.
- La «iluminación cinematográfica» del GDD se reinterpreta como dirección de luz y color,
  no como efectos de pantalla caros.
- Presupuesto ajustado de draw calls, sombras y partículas desde la Fase 1.

## Revisar
- En F1: escena de prueba con cápsulas, terreno y niebla. Si Mobile no llega a 60 FPS o
  Forward+ sí con margen, se reabre.
- En F3: con el escenario de Carmenca real. Si se consigue una GPU dedicada, se reabre.

## Revisión F1 (2026-11-13)

Medida en el proxy de Carmenca con relieve (`docs/rendimiento/2026-11-carmenca-proxy.md`):
a 1080p nativos Mobile da 60,1 FPS de media con el 19,5 % de frames lentos; Forward+ 44,1.
**Se mantiene el renderer Mobile.** El objetivo de 60 FPS exige además renderizar el 3D
por debajo de 1080p: ver `0005`.

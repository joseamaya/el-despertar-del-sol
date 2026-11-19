# Rendimiento · el slice completo (F4, tarea 12)

**Fecha:** 2026-11-18 · **Equipo:** el de referencia (Intel RPL-S integrada, `DECISIONS/0004`)
· **Renderer:** Mobile · **3D:** 83 % (`DECISIONS/0005`, ya aplicado por los ajustes)

## Cómo se mide

El bot `SlicePlaythroughDriver` juega la partida entera con todos los sistemas activos:
director del slice, diálogos, huaca y visión, elección del ayllu, llamas, las tres
escaramuzas con los comuneros, audio, atuendos y cierre. El jugador es invulnerable y
ataca con lock-on y golpes ligeros.

```bash
godot --path . -s res://tools/scene_benchmark.gd -- \
    --scene=res://scenes/levels/carmenca.tscn --playthrough --scale3d=0.833
```

## Resultado (primera pasada, máquina con carga media de 4–10 por otros procesos)

| Tramo (acto) | Tiempo del bot | FPS medio | 1 % bajo | Frames > 16,7 ms | Primitivas máx. |
| --- | --- | --- | --- | --- | --- |
| Apertura | 15 s | 138,4 | 69,8 | 0,1 % | 0,67 M |
| Exploración | 46 s | 96,4 | 41,0 | 0,2 % | 1,05 M |
| Apoyo | 16 s | 106,4 | 76,7 | 0,0 % | 0,83 M |
| Combate | 62 s | 110,8 | 32,9 | 1,1 % | 1,04 M |
| Cierre | 17 s | 116,2 | 54,7 | 0,7 % | 0,91 M |
| **Partida completa** | **2 min 54 s** | **109,0** | **40,5** | **0,6 %** | **1,05 M** |

Draw calls máx.: 191. Física media: 8,0 ms.

**Criterio de F3:** más de 60 FPS de media, menos de 1 % de frames lentos y menos de
1,2 M primitivas.
- **Partida completa:** se cumple.
- **Combate:** su 1,1 % de frames lentos queda justo por encima del límite. Con esta carga
  de la máquina no se puede separar del ruido; se repite en reposo.

## Duración

El bot termina en 2 min 54 s: no explora, no muere, lee cada línea en 2,5 s y no abre el
códice. El criterio de salida de F4 (8–12 min) se mide con una persona jugando la build
exportada: el «Fin» muestra ahora el tiempo de partida.

## Pasadas en reposo (2026-11-19, cierre de F4)

Las dos pasadas del bot se hicieron con la máquina casi en reposo (carga media 0,9 y 4,9),
ya con el tutorial (12a) y los refuerzos del paso (12b). La segunda incluye además la
Carmenca habitada (12c).

| Tramo (acto) | `main` antes de 12c: FPS / 1 % bajo / lentos | Con 12c: FPS / 1 % bajo / lentos |
| --- | --- | --- |
| Apertura (con tutorial) | 134,2 / 78,8 / 0,1 % | 127,3 / 69,7 / 0,1 % |
| Exploración | 108,7 / 47,6 / 0,2 % | 111,7 / 43,7 / 0,1 % |
| Apoyo | 118,9 / 79,4 / 0,1 % | 128,6 / 99,3 / 0,0 % |
| Combate (con refuerzos) | 118,9 / 49,9 / 0,1 % | 128,9 / 49,3 / 0,1 % |
| Cierre | 119,6 / 60,6 / 0,3 % | 127,3 / 64,0 / 0,1 % |
| **Partida completa** | **120,2 / 55,3 / 0,1 %** | **124,6 / 53,8 / 0,1 %** |

- **Tiempo del bot:** 4 min 6 s antes de 12c y 3 min 55 s con 12c.
- **Primitivas máximas:** 1,08 M y 1,05 M.
- **Draw calls máximas:** 196 y 200.

**Conclusión:**
- En reposo, el combate baja de 1,1 % a **0,1 % de frames lentos**: aquel 1,1 % era ruido de la
  carga de la máquina.
- El slice completo cumple el criterio de F3 (más de 60 FPS de media, menos de 1 % de frames
  lentos y menos de 1,2 M primitivas) con margen.
- Después de estas pasadas, el #56 dejó de animar y dibujar a la gente a más de 70 m, que
  abarata, y el #57 añadió un subtítulo. No se repitió la medida: al cerrar la fase, otros
  procesos tenían la máquina con una carga de 22–29.

## Duración

- **Partida del desarrollador** en la build exportada de Linux (`main` 5acffb8,
  2026-11-19): **10 min** hasta el «Fin».
- **Reintentos:** incluye derrotas en la segunda oleada del paso.
- **Criterio de salida de F4:** 8–12 min.

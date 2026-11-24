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

## Referencia de F6: build `0.2-slice` en reposo (F6, tarea 1)

**Fecha:** 2026-11-23 · **Código:** `chore/trailer-0-2` 21ac041 (`0.2-slice` con todo F6) ·
mismo comando que arriba (`--playthrough --scale3d=0.833`) · 3 pasadas seguidas, con la
máquina en reposo (carga media 1,0–1,9 al empezar cada una).

Incluye todo lo nuevo desde F4: la apertura de tres planos con los chancas a la vista, el
entrenamiento con fijar objetivo, la huallcanca con la pose de guardia y el destello, los
búferes de respuesta y el marcador de objetivo.

| Tramo (acto) | Tiempo del bot | Mediana: FPS / 1 % bajo / lentos | Pasada 2 (atípica) |
| --- | --- | --- | --- |
| Apertura (con presentación y tutorial) | 72 s | 130,0 / 49,2 / 0,0 % | 124,3 / 49,2 / 0,0 % |
| Exploración | 46 s | 103,1 / 43,1 / 0,2 % | 81,8 / 22,2 / 13,2 % |
| Apoyo | 16 s | 111,4 / 56,8 / 0,4 % | 78,1 / 23,6 / 22,6 % |
| Combate (con refuerzos) | 88 s | 124,4 / 50,9 / 0,1 % | 105,9 / 23,8 / 4,5 % |
| Cierre | 16 s | 127,6 / 54,7 / 0,1 % | 127,6 / 42,6 / 0,7 % |
| **Partida completa** | **4 min 30 s** | **121,3 / 46,2 / 0,1 %** | **105,7 / 23,7 / 5,0 %** |

Las tres pasadas, partida completa (FPS / 1 % bajo / lentos): 129,7 / 55,8 / 0,0 %;
105,7 / 23,7 / 5,0 %; 121,3 / 46,2 / 0,1 %.

- **Primitivas máximas:** 1,12 M en las tres, en la apertura (antes 1,05 M).
- **Draw calls máximas:** 201 (antes 200). **Física media:** 6,5 ms.
- **La pasada 2 es atípica:** sus frames lentos se concentran en la exploración y el
  apoyo, sin cambio de escena que lo explique, y la carga de la máquina subió durante
  ella. Se toma la mediana de las tres, que es lo que pedía la tarea.

**Conclusión:**
- Frente al cierre de F4 en reposo (124,6 / 53,8 / 0,1 %), la `0.2-slice` queda
  **prácticamente igual: 121,3 / 46,2 / 0,1 %**. Los cambios de F6 no tienen un coste de
  rendimiento apreciable.
- Cumple el criterio de F3 (más de 60 FPS de media, menos de 1 % de frames lentos y menos
  de 1,2 M primitivas).
- **Margen en primitivas:** la apertura, con los guerreros chancas a la vista, sube el
  máximo a 1,12 M, cerca del límite de 1,2 M. Si se añaden más figuras a la apertura,
  conviene medir antes.

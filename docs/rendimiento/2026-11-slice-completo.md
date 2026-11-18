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

## Pendiente

- Repetir la pasada con la máquina en reposo para cerrar el 1 % bajo y los frames lentos del
  combate.
- La partida del desarrollador en la build exportada y su tiempo.

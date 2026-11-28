# Rendimiento · la zona de la misión B (F10, tarea 6a)

**Fecha:** 2026-11-28 · **Equipo:** la GPU de referencia (Intel RPL-S, Vulkan) ·
**Renderer:** Mobile · **3D:** 83 %.

**Qué es:** la quebrada de «Los presos de Conchacalla» (`F10-diseno-misiones.md` §4).
Mide 80 × 270 m y es casi un pasillo:
- **La boca, abajo:** por donde se entra y adonde se vuelve con los presos.
- **El fondo:** un arroyo que baja por un lado desde un manantial bajo el mirador, con
  laderas altas a los dos lados y peñas sueltas.
- **El mirador:** una loma desde la que se ve el campamento, más abajo.
- **El campamento:** en una hondonada al final, con su fogón, fardos y cestos. Ahí estarán
  los presos atados (6b).

Datos en `resources/levels/presos_layout.tres`; escena `scenes/levels/mision_presos.tscn`,
que hereda de Carmenca. El catálogo ya manda aquí la misión. Hasta la 6b se juega con la
secuencia provisional: rótulo y llegar al final del camino, en el campamento.

## Capturas

A la altura de los ojos de Cusi, salvo la última.

| | |
| --- | --- |
| ![Boca](../img/f10/presos-boca.jpg) La boca de la quebrada | ![Arroyo](../img/f10/presos-arroyo.jpg) El arroyo |
| ![Subida](../img/f10/presos-subida.jpg) Subiendo hacia el mirador | ![Mirador](../img/f10/presos-mirador.jpg) Desde el mirador, el campamento |
| ![Campamento](../img/f10/presos-campamento.jpg) El campamento | ![Vuelta](../img/f10/presos-vuelta.jpg) Desde el campamento, mirando atrás |

![Plano](../img/f10/presos-alto.jpg)

**Plano desde lo alto.** Solo sirve para ver la forma: desde ahí se ve dónde acaba la zona,
algo que Cusi no ve. Desde el campamento, mirando atrás, el horizonte es la loma del
mirador.

## Medido

Benchmark: el recorrido entero del camino (`--walk`), dos pasadas.

| | Pasada 1 | Pasada 2 |
| --- | --- | --- |
| FPS medios | 145,6 | 151,5 |
| 1 % más lento | 101 FPS | 103 FPS |
| Frames de más de 16,7 ms | 0 | 0 |
| Primitivas máx. | 0,42 M | 0,42 M |
| Draw calls máx. | 89 | 89 |

**Lo que dice:** es la zona más barata del capítulo, por ser un pasillo. Sobra margen
para los siete chancas, los tres presos y el refuerzo de la 6b.

## Un fallo del navmesh, corregido

**El síntoma:** la boca de la quebrada quedaba fuera del navmesh, el mapa por el que andan
los enemigos (y ahora los presos).

**La causa:** el horneado se limita a una caja alrededor del pasillo. Esa caja se calculaba
en coordenadas del mundo, pero Godot la aplica en las del sector, que está girado 45°.
Resultado: cada nivel perdía unos 20 m de cada punta, y a lo ancho no se limitaba nada.

**A quién afectaba:** a todos los niveles. En Carmenca, la salida de Cusi y el final del
paso estaban fuera del navmesh, pero ningún enemigo llegaba hasta ahí y no se notaba.

**El arreglo:** la caja se da en las coordenadas del sector
(`SectorNavigation.bake`). Ahora cada nivel tiene navmesh en todo su largo y solo en el
ancho del pasillo, y hornea en 16–76 ms. Hay una prueba nueva que comprueba que los dos
extremos del camino de cada nivel del capítulo están en el navmesh
(`tests/world/test_sector_navigation.gd`). Con el filtro antiguo falla en Carmenca y en la
quebrada.

**Un efecto secundario, también corregido:** con el navmesh nuevo, los puntos del camino
quedaban unos 0,55 m sobre el suelo, en vez de 0,45 m. El agente de los guerreros da por
alcanzado un punto a menos de 0,5 m, contando la altura, así que un explorador se quedaba
parado sin llegar a su ronda (lo pilló la prueba de las patrullas de Carmenca). Ahora el
agente baja los puntos 0,5 m (`path_height_offset`) en los guerreros y en los presos.

**Carmenca con el navmesh nuevo:** el bot la juega entera (`--playthrough`) en la GPU de
referencia. Termina, sin atascos, en 286 s de juego, con 129,5 FPS de media, 0,96 M
primitivas como máximo y un frame de 31 ms (de compilar shaders, en la exploración).

## Sin verificar

- **Andarla a mano.** Solo la ha recorrido el benchmark.
- **Los combates de Carmenca** con el navmesh nuevo los ha jugado el bot (arriba), no una
  persona.

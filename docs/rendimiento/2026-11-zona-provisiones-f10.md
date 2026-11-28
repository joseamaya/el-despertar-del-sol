# Rendimiento · la misión A, zona y misión (F10, tarea 4)

**Fecha:** 2026-11-28 · **Equipo:** la GPU de referencia (Intel RPL-S, Vulkan) ·
**Renderer:** Mobile · **3D:** 83 %.

**Qué es:** la ladera de «Lo que se llevaron» (`F10-diseno-misiones.md` §3), hecha con el
kit de Carmenca. Mide 160 × 220 m:
- **Abajo:** las casas del ayllu, dos corrales vacíos y los depósitos saqueados (dos casas
  de piedra con fardos y vasijas tirados delante).
- **En medio:** siete terrazas con sus muros, sus escaleras y un canal de riego.
- **Arriba:** una cuesta que acaba en el paso, entre peñas, con el fogón de los porteadores.
  Su humo se ve desde abajo y señala adónde ir.

Datos en `resources/levels/provisiones_layout.tres`; escena
`scenes/levels/mision_provisiones.tscn`, que hereda de Carmenca. El catálogo ya manda aquí
la misión. La misión llegó en la 4b (abajo).

## Capturas

A la altura de los ojos de Cusi, salvo la última.

| | |
| --- | --- |
| ![Llegada](../img/f10/provisiones-llegada.jpg) Llegada desde el Cusco | ![Depósitos](../img/f10/provisiones-depositos.jpg) Los depósitos saqueados |
| ![Terrazas](../img/f10/provisiones-terrazas.jpg) Las terrazas desde abajo | ![Rastro](../img/f10/provisiones-rastro.jpg) La cuesta, sobre la última terraza |
| ![Porteadores](../img/f10/provisiones-porteadores.jpg) El paso y el sitio de los porteadores | ![Vuelta](../img/f10/provisiones-vuelta.jpg) De vuelta, mirando al valle |

![Plano](../img/f10/provisiones-alto.jpg)

**Plano desde lo alto.** Solo sirve para ver la forma: desde ahí se ve dónde acaba la zona,
algo que Cusi no ve.

## Medido

Benchmark: el recorrido entero del camino (`--walk`), dos pasadas.

| | Pasada 1 | Pasada 2 |
| --- | --- | --- |
| FPS medios | 126,6 | 131,1 |
| 1 % más lento | 79 FPS | 95 FPS |
| Frames de más de 16,7 ms | 0 | 0 |
| Primitivas máx. | 0,73 M | 0,73 M |
| Draw calls máx. | 128 | 128 |

Por tramo, el más caro es el de los depósitos: unos 115 FPS y 0,73 M primitivas. Arriba,
en el sitio de los porteadores, baja a 0,50 M primitivas y sube a 153 FPS.

**Lo que dice:** sobra margen para la 4b. El límite es 1,2 M primitivas y 60 FPS. Quedan
casi 0,5 M para seis enemigos, la mujer y el anciano. Cada personaje de cerca ronda los
14 k triángulos.

## Cambios en las herramientas

- **El recorrido del benchmark** (`SectorWalkDriver`) nombraba los tramos con los puntos
  de Carmenca. En un nivel con puntos propios, ahora los nombra con esos puntos.
- **Si el recorrido se atasca,** el benchmark dice ahora por qué tanto por ciento del
  camino iba y en qué tramo. Así se encontró el atasco de esta zona: los giros del camino
  caían encima de las escaleras y Cusi chocaba con su costado. Hay una prueba que lo
  impide.

## Sin verificar

- **Andarla a mano.** Solo la ha recorrido el benchmark.
- **Mirando hacia el valle se ve el fondo de Carmenca,** con el humo del Cusco a lo lejos.
  Lo dejo así: el ayllu está cerca del Cusco. Si no te convence, se cambia el fondo.

## 4b · La misión

**Qué se añade:**
- **La secuencia** (`resources/slice/mision_provisiones.tres`), los pasos del diseño:
  1. Llegada a las casas del ayllu.
  2. La mujer cuenta qué pasó.
  3. Dos porras en los depósitos.
  4. Un explorador de porra que hace su ronda por una terraza.
  5. Los porteadores: un lancero y dos porras, junto al fogón del paso.
  6. Recoger los tres fardos, uno tras otro: maíz, chuño y charqui.
  7. Vuelta a las casas, donde hablan la mujer y el anciano.

  Cada combate tiene su punto de control: al caer, Cusi vuelve al de ese combate.
- **La mujer y el anciano,** con los aspectos que ya había (`refugee_woman`, `elder`).
- **`PickupProps`** (`scripts/interaction/pickup_props.gd`): pone un fardo del kit en
  cada marcador y lo quita al recogerlo. Es lo único nuevo en el código.
- **Los textos** (`localization/ui.csv`, claves `*_PROV_*` y `PROMPT_BUNDLE_*`) y los dos
  diálogos (`resources/dialogue/provisiones/`). `canon-check`: el saqueo y las provisiones
  están en la fila de la misión A del registro. No hay afirmaciones nuevas.

**La patrulla es un combate.** El árbitro solo crea enemigos al empezar una zona, así que
el explorador de las terrazas es la zona 2, con un solo guerrero que hace la ronda. Hay
que derrotarlo para seguir; no se le puede esquivar.

| | |
| --- | --- |
| ![La mujer en las casas](../img/f10/provisiones-mujer.jpg) La mujer, junto a las casas | ![Los fardos](../img/f10/provisiones-fardos.jpg) Los fardos en el campamento |

**Medido en la GPU de referencia:** el bot juega la misión entera (`--playthrough`), dos
pasadas.

| | Pasada 1 | Pasada 2 |
| --- | --- | --- |
| FPS medios | 130,2 | 131,4 |
| 1 % más lento | 87 FPS | 91 FPS |
| Frames de más de 16,7 ms | 1 (24 ms) | 1 (22 ms) |
| Primitivas máx. | 0,83 M | 0,81 M |
| Draw calls máx. | 166 | 163 |
| Tiempo de juego del bot | 148 s | 149 s |

El frame lento es el del comienzo del primer combate, al dibujar a los chancas por primera
vez. El bot juega más rápido que una persona: el diseño cuenta con 10–15 minutos.

**Sin verificar en la 4b:** jugarla a mano, la sensación de los tres combates y si la
mujer y el anciano se ven bien al hablar.

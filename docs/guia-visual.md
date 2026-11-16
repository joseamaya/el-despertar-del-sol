# Guía visual — Carmenca, c. 1438

**Estado:** borrador, pendiente de que el desarrollador elija la variante · F3, tarea 3.
Fuente: GDD §10 (dirección artística) y §14 (vertical slice). Decisiones:
`DECISIONS/0010` (arte por script) y `HISTORICAL_REFERENCES.md` (licencias del escenario).

Una página de reglas para todo lo que se genere en F3. Si una pieza las incumple, se
corrige la pieza; si la regla no sirve, se cambia aquí con el visto bueno del desarrollador.

## Variantes a elegir

Viñeta de estilo `scenes/tests/style_vignette.tscn`, generada por código. Dos encuadres por
variante: general (terrazas, huaca, apus) y detalle (pirca, casa de adobe con techo de ichu).

![Comparativa de las tres variantes](img/guia-visual/comparativa.jpg)

| Variante | Idea | Capturas |
| --- | --- | --- |
| **A · Amanecer cálido** | Ocres saturados, sol bajo anaranjado (14°), niebla poco densa | [general](img/guia-visual/amanecer_calido-general.jpg) · [detalle](img/guia-visual/amanecer_calido-detalle.jpg) |
| **B · Altura fría** | Grises y verdes secos, cielo azul pálido, más bruma (22°) | [general](img/guia-visual/altura_fria-general.jpg) · [detalle](img/guia-visual/altura_fria-detalle.jpg) |
| **C · Contraste** | Piedra oscura, sol rasante muy marcado (8°), sombras largas | [general](img/guia-visual/contraste-general.jpg) · [detalle](img/guia-visual/contraste-detalle.jpg) |

Regenerar las capturas (abre una ventana):

```bash
godot --path . -s res://tools/capture_style.gd -- --out=docs/img/guia-visual \
    --palettes=amanecer_calido,altura_fria,contraste
```

## Paleta

Cada color vive en un `PaletteTuning` (`resources/style/palette_*.tres`); los generadores no
llevan colores en el código. La variante elegida pasará a ser la paleta del escenario.

| Campo | A · Amanecer cálido | B · Altura fría | C · Contraste |
| --- | --- | --- | --- |
| `stone_light` / `stone_dark` (pirca) | `#9e9485` / `#615952` | `#999994` / `#5c5e5e` | `#8c8073` / `#423d38` |
| `huaca_stone` | `#75665c` | `#706b66` | `#5c4d45` |
| `adobe` | `#a8805c` | `#998066` | `#9e704d` |
| `earth` / `dry_grass` | `#806145` / `#998c57` | `#73614f` / `#85875c` | `#6b4d33` / `#948047` |
| `ichu` (techos) | `#b8995c` | `#a8996b` | `#bd944d` |
| `mountain` (apus, con atmósfera) | `#6b738c` | `#808fa8` | `#4d5473` |
| `sky_top` / `sky_horizon` | `#527ab3` / `#dbb38c` | `#5985c7` / `#bfccdb` | `#38528c` / `#f29e66` |
| `fog_color` | `#c7b8a8` | `#bdccdb` | `#b3998c` |
| `sun_color` · elevación · energía | `#ffc78c` · 14° · 1,3 | `#ffedd1` · 22° · 1,1 | `#ffb373` · 8° · 1,8 |
| Niebla: densidad · altura | 0,0015 · −55 m | 0,0025 · −45 m | 0,001 · −60 m |

**Facciones (iguales en las tres):** inca rojo `#b3241a` y amarillo `#dba829`; chanca
`#296b85` (el teal del guerrero de F2). Son los únicos colores saturados de la escena: el
paisaje se queda en ocres, grises y verdes secos para que los personajes se lean de lejos.

## Escala

| Elemento | Medida | Nota |
| --- | --- | --- |
| Persona | 1,8 m | El modelo UAL; referencia para todo lo demás |
| Muro de terraza (andén) | 1,4–1,8 m de alto, 0,6 m de grueso | En la viñeta, 1,6 m |
| Peldaño | 0,2 m de alto, 0,3 m de huella | El jugador sube escalones de ~0,1 m solo: las escaleras llevan rampa de colisión invisible (skill `godot-component`) |
| Terraza | 5–8 m de fondo | Espacio para un combate de 1 contra 2 |
| Casa de un ambiente | 4–5 × 3–4 m, muros de 2,2 m | Puerta de 0,9 × 1,7 m |
| Techo de ichu | Dos aguas, cumbrera a +1,6–1,8 m, alero de 0,4 m | Grueso: se ve el canto |
| Huaca | Roca de ~2,5 m con pirca baja (0,5 m) en anillo de ~4,5 m | Forma: licencia del juego |
| Apus | 250–420 m sobre el valle, a 1,7–2,5 km | Sin niebla: el color lleva la atmósfera |

## Formas

- **Pirca:** piedras irregulares sin mortero, en hiladas desiguales y con cada piedra de un
  tono distinto. Nada de sillares regulares (§10.2: la cantería fina es posterior).
- **Adobe:** volúmenes simples, esquinas un poco blandas, sin vanos decorativos.
- **Ichu:** techos a dos aguas, gruesos y con alero. En el kit (tarea 5) el techo llevará
  capas escalonadas para que se lea como paja y no como plancha.
- **Terreno:** facetado (low poly), sin texturas; la variación sale del color por vértice.
- **Siluetas claras:** formas grandes y legibles; el detalle va en el color y la luz, no en
  polígonos (§10.1).

## Luz y niebla

- **La luz hace el trabajo** (§10.1): sol bajo de amanecer, rasante, que marca las hiladas de
  la pirca y alarga las sombras.
- Solo efectos compatibles con el renderer Mobile: niebla exponencial y de altura, cielo
  procedural. Nada de niebla volumétrica, SSAO, SSR ni SDFGI (`DECISIONS/0004`).
- Sombras solo del sol, hasta ~100 m (`docs/rendimiento`).
- Lo lejano (apus) se pinta sin niebla y con el tinte atmosférico en su color: más barato
  y controlable que una niebla que lo lava todo.

## Qué evitar (no parecer medieval genérico)

- Almenas, torres, arcos de medio punto, contrafuertes.
- Vigas de madera vistas, entramados, tejas de barro, chimeneas.
- Piedra tallada en sillares regulares o muros ciclópeos (son del Cusco imperial posterior).
- Vegetación de bosque europeo: aquí, ichu, matorral seco y pocos árboles.
- Colores saturados en el paisaje: se reservan para las facciones.
- Cualquier elemento colonial o de otras culturas (`HISTORICAL_REFERENCES.md`, «Lo que no
  se cambia»).

## Preguntas abiertas (decide el desarrollador)

1. **Variante:** A, B, C o una mezcla (p. ej. la luz de C con la piedra de A).
2. **Puertas trapezoidales:** muy reconocibles como andinas, pero pueden ser más propias de
   la arquitectura imperial posterior que de 1438. Por defecto se usan puertas
   rectangulares; si se adoptan las trapezoidales, se registra como licencia en
   `HISTORICAL_REFERENCES.md`.

## No verificado

- Cómo se ve en el monitor del desarrollador y en Windows (capturas hechas en Linux, 1600×900).
- Rendimiento de la viñeta: es una prueba de estilo, no una escena de juego; la medición
  del escenario real es la tarea 10.

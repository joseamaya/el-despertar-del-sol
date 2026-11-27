# F10 · Diseño de las misiones de Apoyo (tarea 2)

**Estado:** aprobado por el desarrollador el 2026-11-27, con todas las recomendaciones: los nombres de la sección 6, las dos opciones de la misión C, el punto de control de la misión B y las cuatro entradas del registro, ya añadidas.

**Para qué sirve:** fijar, antes de construir, qué es cada misión. Para cada una:
- la zona;
- el guion de pasos del director;
- los enemigos;
- qué se gana;
- cómo se falla o se repite.

Además, los nombres definitivos (deuda 6 de F9) y la decisión de la misión C.

**Base:**
- `docs/capitulo-1.md` §3, §6 y §7.3;
- GDD §8.2;
- las filas del registro «Curacas vecinos» y «Los problemas de los tres curacas del
  centro» (F9);
- la lectura de las crónicas de esta tarea (sección 1).

## 1. Lo que dicen las crónicas

Se leyó el texto completo, no resúmenes. Esta vez, cuatro crónicas:
- **Betanzos:** edición de 1880, OCR.
- **Sarmiento:** traducción de Markham, 1907.
- **Cieza:** *Segunda parte*, texto de Gutenberg.
- **Garcilaso:** edición de Biblioteca Ayacucho, 1985, OCR.

Dos citas se comprobaron a mano en el texto: el quilescachi de Sarmiento (cap. XXVII) y la
vuelta de los que se fueron con Viracocha (Betanzos, cap. IX).

| Qué | Dónde | Qué dice |
| --- | --- | --- |
| **Los curacas no tienen nombre** | Betanzos, cap. VII | Los mensajeros van a los caciques «en espacio de tres leguas», sin nombrarlos. Esperan; también pensaban dar obediencia al Chanca |
| **Un quilescachi, preso de los chancas** | Sarmiento, cap. XXVII | En **Conchacalla** los chancas toman un preso, «a Quillis-cachi of Cuzco». Los guía, se arrepiente, huye y al final da la alarma |
| **Gente que mira sin tomar partido** | Sarmiento, cap. XXVII | Gente llegada de lejos «not daring to declare for either party». Sin nombres |
| **Los chancas roban los campos** | Cieza, cap. XLIV | En Curampa, camino del Cusco, no querían cautivos sino «robar los campos». Es lejos del Cusco |
| **Lo que llevaban los chancas** | Betanzos, cap. VI | «carne seca, y maíz, y pescado seco» |
| **Depósitos de comida de las casas** | Betanzos, cap. IX | Cusi no quita a los que se fueron con Viracocha sus «casas, tierras, depósitos de comida, é ropas» |
| **Los primeros depósitos del Estado, después** | Betanzos, cap. XII | Inca Yupanqui hace «los primeros depósitos de comidas» tras la guerra. Unas collcas estatales en 1438 serían un anacronismo |
| **Irse con Viracocha o quedarse** | Betanzos, cap. VI | Viracocha sale con la gente del Cusco y con «los más de los comarcanos que seguirlos quisiesen» |
| **Los que se fueron vuelven, sin reproche** | Betanzos, cap. IX | Muchos vuelven del peñol y se disculpan: «su padre los habia llevado». Cusi no se enoja y les devuelve todo |
| **Vecinos que se negaron a servir** | Sarmiento, cap. XXV | Mohina y Pinahua, a cinco leguas, decían que eran libres. Los capitanes de Viracocha, con Apo Mayta y Vicaquirao, los castigaron con dureza |

**Contradicción a registrar:**
- **Sarmiento** cuenta que los chancas toman un preso.
- **Cieza** dice que «ni querian cativos».

La misión B se apoya en Sarmiento.

## 2. Común a las tres

- **Duración:** 10–15 minutos cada una (`capitulo-1.md` §3).
- **Cómo se entra y se sale:**
  - se entra aceptando la misión al curaca en el centro;
  - se sale al llegar al final, con un diálogo corto, y se vuelve al centro con el Apoyo
    sumado y guardado (tarea 3);
  - desde la pausa se puede abandonar, sin hacer la misión.
- **Si Cusi cae:** vuelve al último punto de control, como en Carmenca.
- **Apoyo:**
  - cada misión da **+1** a su ayllu, que pasa a Simpatizante;
  - «Ante los curacas» da +1 a cada ayllu ya ganado, que pasa a Aliado.

  Son los valores de hoy (`capitulo_1.tres`, `capitulo_1_apoyo.tres`). La misión C reparte
  distinto según la decisión (sección 5).
- **Enemigos:** exploradores chancas de porra y de lanza. Hay patrullas donde la zona lo
  permite (F9). Nunca más de 4 a la vez: el director da dos turnos de ataque (GDD §7.1).
- **Escenarios:** el kit, con un `SectorLayout` por zona. Cada zona se mide (menos de
  1,2 M primitivas y 60 FPS) antes de darla por buena.
- **Cada misión cuenta algo que el centro no cuenta:** el robo, el preso y la duda.

## 3. Misión A · «Lo que se llevaron» (provisiones)

**El problema:** unos exploradores chancas han saqueado los depósitos de un ayllu del valle
y suben la carga hacia su campamento. Es lo que dice Cieza, «robar los campos», trasladado
cerca del Cusco (licencia).

**La zona:** una ladera de cultivo con terrazas, corrales y las casas del ayllu, con los
depósitos de la familia: casas pequeñas con fardos y vasijas, no collcas del Estado (Betanzos,
cap. XII). Es una variante del kit de Carmenca, de coste S. Mide unos 160 × 220 m.

```text
        N (arriba: el paso por donde se van los chancas)
   ┌──────────────────────────────────────┐
   │          ③ los porteadores           │  ← fardos: F1 F2 F3
   │        (lancero + 2 porras)          │
   │   terrazas ─────┐                    │
   │                 │   ② patrulla        │
   │     corral      │   (1 porra)         │
   │  ① depósitos saqueados (2 porras)     │
   │    casas del ayllu · mujer y anciano  │
   │  [S] llegada desde el Cusco           │
   └──────────────────────────────────────┘
```

| # | Paso | Qué pasa |
| --- | --- | --- |
| 1 | REACH «Ayllu» | Llegada a las casas del ayllu |
| 2 | DIALOGUE | Una mujer del ayllu cuenta que se lo llevaron al alba, cuesta arriba |
| 3 | ENCOUNTER 1 | Dos exploradores de porra siguen en los depósitos. **Punto de control** |
| 4 | REACH «Rastro» | Subir por las terrazas; una patrulla de porra hace su ronda |
| 5 | ENCOUNTER 2 | Los porteadores: un lancero y dos porras, con los fardos en el suelo |
| 6 | INTERACT ×3 | Recoger los tres fardos: maíz, chuño y charqui |
| 7 | DIALOGUE + fin | De vuelta abajo, la mujer y el anciano. Se vuelve al centro |

- **Se gana:** +1 de Apoyo con el ayllu.
- **Se falla:** solo si Cusi cae, y entonces vuelve al punto de control.
- **Nuevo en el código:** nada. Usa REACH, DIALOGUE, ENCOUNTER, INTERACT y las patrullas.
- **Cambio en el centro:** el curaca hoy habla de llamas (`HUB_LLAMAS_*`). Pasa a hablar de
  sus depósitos, y la misión, el nodo y las claves dejan de llamarse «llamas» (sección 6).

## 4. Misión B · «Los presos de Conchacalla» (prisioneros, con escolta)

**El problema:** los exploradores han apresado a hombres de un ayllu en Conchacalla y los
bajan por la quebrada para que les enseñen el camino al Cusco. Es lo que cuenta Sarmiento
(cap. XXVII) con un solo preso; aquí son tres (licencia).

**La zona:** una quebrada estrecha con un arroyo, laderas altas y el campamento de los
exploradores, con fogón y fardos. Es nueva, de coste M (`capitulo-1.md` §7.3). Mide unos
80 × 260 m y es casi un pasillo, así que es barata de dibujar.

```text
     N (fondo de la quebrada)
   ┌───────────────┐
   │ ④ campamento  │  presos atados: P1 P2 P3
   │ (2 porras +   │  fogón, fardos
   │  lancero; al  │
   │  caer el 1.º, │
   │  llega otro)  │
   │   ③ mirador   │
   │   ② patrulla  │  (1 lancero)
   │ ≈ arroyo ≈    │
   │ ⑤ emboscada   │  (2 porras, a la vuelta)
   │ [S] boca      │  ← salida con los presos
   └───────────────┘
```

| # | Paso | Qué pasa |
| --- | --- | --- |
| 1 | REACH «Boca» | Entrada a la quebrada |
| 2 | ENCOUNTER 1 | Una patrulla de lancero |
| 3 | REACH «Mirador» + DIALOGUE | Cusi ve el campamento desde arriba, con una línea suya. **Punto de control** |
| 4 | ENCOUNTER 2 | El campamento: dos porras y un lancero, y un refuerzo al caer el primero (como la oleada de Carmenca) |
| 5 | INTERACT ×3 | Desatar a los presos. Uno dice que querían que les enseñaran el camino al Cusco. **Punto de control** |
| 6 | **ESCORT** «Boca» | Los presos siguen a Cusi quebrada abajo |
| 7 | ENCOUNTER 3 | Emboscada a la vuelta, con dos porras. Los presos se agachan y se apartan |
| 8 | DIALOGUE + fin | En la boca, el mayor de los presos. Se vuelve al centro |

- **Se gana:** +1 de Apoyo con el ayllu.
- **Se falla:** si cae un preso, la misión vuelve al punto de control de los presos
  liberados (paso 5). Los presos aguantan más que Cusi y los enemigos los atacan solo si
  no hay Cusi cerca, para que no sea frustrante.
- **Nuevo en el código:** el paso `ESCORT` (tarea 5).

## 5. Misión C · «Irse o quedarse» (la disputa, con una decisión)

**El problema:** un pueblo cercano está partido. Unos quieren seguir a Viracocha al peñol de
Caquia Xaquixaguana, como hicieron «los más de los comarcanos» (Betanzos, cap. VI); otros, quedarse.
El curaca dejará que pese lo que diga Cusi.

**La zona:** el pueblo del ayllu, con casas del kit en otra disposición: una plazuela, un
camino que sale hacia Xaquixaguana y fardos ya atados para el viaje. Es de coste M, pero
reutiliza las casas y los muros del centro. Mide unos 140 × 140 m.

```text
           camino a Xaquixaguana ──►
   ┌──────────────────────────────┐
   │  fardos atados · llamas      │
   │   ┌plazuela┐                 │
   │   │ A    B │  A: el que se va │
   │   └────────┘  B: la que se queda
   │  casas · pirca               │
   │  ② los exploradores bajan    │
   │     por aquí (3)             │
   │ [S] llegada                  │
   └──────────────────────────────┘
```

| # | Paso | Qué pasa |
| --- | --- | --- |
| 1 | REACH «Plazuela» | Llegada; la gente cargando |
| 2 | DIALOGUE «El que se va» | Un anciano: el Inca se ha ido y el que se queda, muere |
| 3 | DIALOGUE «La que se queda» | Una mujer: aquí están sus tierras y sus muertos |
| 4 | ENCOUNTER 1 | Bajan tres exploradores al pueblo, mientras unos y otros miran. **Punto de control** |
| 5 | CHOICE | Lo que dice Cusi (ver abajo) |
| 6 | DIALOGUE + fin | El curaca. Se vuelve al centro |

**La decisión:** ninguna es la mala. Las dos dan Apoyo, pero cambian cosas distintas.

| | **«Quedaos y luchad conmigo»** | **«Que se vaya quien quiera, sin reproche»** |
| --- | --- | --- |
| Apoyo | +1 con el pueblo, como las otras | +1 con el pueblo, como las otras |
| En el centro | Llegan sus hombres, armados | Llega menos gente; el anciano y los suyos se van |
| En «Ante los curacas» | Dos aliados más del pueblo | Un aliado más del pueblo |
| Más tarde | — | **Los que se fueron vuelven** después de «Ante los curacas», y se ven en el centro. Es Betanzos, cap. IX: Cusi recibe sin enojo a los que se fueron con su padre |
| Lo que dice de Cusi | Firme | Generoso, como en la crónica |

- **Se falla:** solo si Cusi cae.
- **Nuevo en el código:** nada para la decisión, que es el CHOICE de Carmenca. Que su efecto
  se vea en el centro y en el combate es de las tareas 8 y 9.

## 6. Nombres

Las crónicas no nombran a los curacas que esperaron (Betanzos, cap. VII). Por eso:
- los **nombres de pueblo** se toman de las crónicas cuando hay un dato que encaja;
- los **nombres de persona** de los curacas son títulos, no nombres propios.

| | Hoy (provisional) | **Propuesta** | Por qué | Etiqueta |
| --- | --- | --- | --- | --- |
| Misión A | Las llamas robadas | **Lo que se llevaron** | No repite las llamas de Carmenca | Licencia |
| Ayllu A | Ayllu del valle | **Ayllu del valle** (se queda) | Ningún texto nombra a un ayllu saqueado | Licencia |
| Curaca A | Curaca del valle | **Curaca del valle** (se queda) | Igual | Licencia |
| Misión B | Los prisioneros | **Los presos de Conchacalla** | Sarmiento, cap. XXVII | Según los cronistas + Licencia |
| Ayllu B | Ayllu de la quebrada | **Los quilescachis** | El preso de Sarmiento era «a Quillis-cachi of Cuzco»; Quilescachi Urco Guaranga, el compañero de Cusi (Betanzos, cap. VII), lleva el mismo nombre | Según los cronistas + Licencia |
| Curaca B | Curaca de la quebrada | **Curaca de los quilescachis** | Igual | Licencia |
| Misión C | La disputa del curaca | **Irse o quedarse** | Betanzos, caps. VI y IX | Según los cronistas + Licencia |
| Ayllu C | (curaca_c) | **Pueblo del camino** | Está en el camino de Xaquixaguana; ningún texto lo nombra | Licencia |
| Curaca C | Curaca del pueblo | **Curaca del camino** | Igual | Licencia |

**Alternativa para el ayllu A:** **Mohina** (Sarmiento, cap. XXV). Es un pueblo vecino que
decía ser libre y que los capitanes de Viracocha, con Apo Mayta y Vicaquirao, castigaron con
dureza. Daría peso a la misión: ganarse a gente que tiene motivos para no fiarse de los
incas. Pero ese peso pide más texto del que cabe en una misión corta, y los dos compañeros de
Cusi saldrían mal parados. **No se recomienda** para el Capítulo I; quizá para más adelante.

**Cambios de identificadores:** al hacer las misiones de verdad, `llamas` pasa a
`provisiones`. También cambian `MISSION_LLAMAS`, `CuracaLlamas` y `HUB_LLAMAS_*`, y los
ayllus `ayllu_a`, `ayllu_b` y `curaca_c` toman sus nombres. No hay partidas que proteger: la
`0.2-slice` publicada no guarda el capítulo.

## 7. canon-check del diseño

| Afirmación | Estado | Etiqueta | Fuente / fila |
| --- | --- | --- | --- |
| Los curacas cercanos esperan y ayudarán si Cusi tiene gente | Registrada | Según los cronistas | «Curacas vecinos» |
| Exploradores chancas cerca del Cusco | Registrada | Licencia apoyada en las crónicas | «Exploradores chancas…» (F9) |
| Los chancas saquean los depósitos de un ayllu cercano | **Sin registrar** | Licencia del juego, apoyada en Cieza, cap. XLIV (lejos del Cusco) | Entrada propuesta 1 |
| Depósitos de familia (casas con fardos), no collcas del Estado | **Sin registrar** | Interpretación de diseño (Betanzos, caps. IX y XII) | Entrada propuesta 1 |
| Los chancas apresan en Conchacalla a hombres de los quilescachis para que les enseñen el camino | **Sin registrar** | Según los cronistas (un preso, Sarmiento, cap. XXVII) + Licencia (tres presos, la quebrada, el rescate). Cieza dice lo contrario | Entrada propuesta 2 |
| Un pueblo duda entre seguir a Viracocha o quedarse | Registrada en parte | Según los cronistas (Betanzos, cap. VI) + Licencia (el pueblo concreto, los dos personajes) | Amplía la fila de F9 (entrada propuesta 3) |
| Los que se fueron vuelven y Cusi los recibe sin reproche | **Sin registrar** | Según los cronistas | Betanzos, cap. IX. Entrada propuesta 4 |
| Maíz, chuño y charqui como provisiones | Sin registrar | Maíz y «carne seca» documentados (Betanzos, cap. VI); el chuño es andino pero no aparece en lo leído | Entrada propuesta 1 |

**Entradas para `HISTORICAL_REFERENCES.md`,** aprobadas el 2026-11-27 y añadidas al registro:

1. **Misión A:** los exploradores chancas saquean los depósitos de un ayllu del valle.
   Depósitos de familia, no collcas del Estado. **Licencia del juego** apoyada en Cieza,
   cap. XLIV, y en Betanzos, caps. IX y XII.
2. **Misión B:** los chancas apresan en Conchacalla a quilescachis para que los guíen.
   **Según los cronistas** (Sarmiento, cap. XXVII: un preso, «a Quillis-cachi of Cuzco»)
   con licencia: tres presos, la quebrada y el rescate. Contradicción con Cieza,
   cap. XLIV: «ni querian cativos».
3. **Misión C:** un pueblo del camino de Xaquixaguana, partido entre seguir a Viracocha o
   quedarse. **Según los cronistas** (Betanzos, cap. VI) con licencia: el pueblo y sus
   personajes.
4. **Los que se fueron con Viracocha vuelven** y Cusi los recibe sin reproche. **Según los
   cronistas** (Betanzos, cap. IX). En el juego, solo si se elige «Que se vaya quien
   quiera».

**Comprobaciones de forma:**
- **Grafía:**
  - **Quilescachi,** como en el registro (Betanzos). Sarmiento escribe «Quillis-cachi».
  - **Caquia Xaquixaguana** para el peñol de Viracocha, y **Xaquixaguana** para el camino.
- **Sin errores frente a §3.5:**
  - los chancas no son monstruos: roban, apresan para que los guíen y pelean;
  - no hay nada de otras culturas.
- **Una precaución:** el registro sitúa la segunda batalla cerca de Xaquixaguana, y Betanzos,
  cap. X, dice que los naturales de allí se aliaron con los chancas en la huida. Por eso el
  pueblo C es «del camino», sin nombre: un pueblo con nombre de esa zona chocaría con eso.
- **Nombres provisionales:** todo lo de la sección 6 lo es hasta que lo fijes.

## 8. Decisiones que se te piden

1. **Los nombres** de la sección 6. Lo recomendado: A con nombre de licencia, B
   quilescachis en Conchacalla y C «Pueblo del camino».
2. **La decisión de la misión C** (sección 5): ¿te valen las dos opciones y sus efectos? La
   recomendación es que ninguna sea la mala.
3. **Si un preso cae, la misión B vuelve al punto de control,** no se pierde.
4. **Las cuatro entradas del registro** de la sección 7.

Con esto, la tarea 3 hace la ida y vuelta entre el centro y las misiones, y la tarea 4
construye la misión A.

# F9 · Diseño del centro del Cusco (tarea 2)

**Estado:** propuesto, pendiente de las decisiones del desarrollador (sección 6).

**Para qué sirve:** el centro es el sitio al que se vuelve entre misiones (estructura B,
`docs/capitulo-1.md` §3). Tiene que conseguir tres cosas:
- **que se entienda qué hacer:** el fallo del centro de F8, donde no se entendió «La disputa
  del curaca»;
- **que se reconozca andino** (criterio de F9);
- **que más adelante se vea el Apoyo** (F10): gente que vuelve y curacas que mandan
  hombres.

**Lo que no hace en F9:** las misiones siguen siendo de prueba. Al aceptarlas se dan por
cumplidas, como en F8, pero el aviso dice qué ha pasado.

## 1. El Cusco de 1438

- **Ciudad modesta** (GDD §10.2; registro, «Arquitectura de 1438»): pirca, adobe y techo de
  ichu. Sin cantería fina, sin grandes muros y sin Sacsayhuamán.
- **Medio vacía** (registro, «El Cusco se vacía con la corte»): casas cerradas, fardos
  abandonados, hogares apagados y poca gente.
- **El trazado es licencia del juego,** como la calle del prólogo. No reproduce el Cusco
  real.

La propuesta es una **plaza genérica** (opción A de la decisión 1, sección 6). La otra
opción, B, sería basarla en la geografía documentada del Cusco: los dos ríos, la plaza
principal y el templo del Sol en su forma antigua. Pero eso hay que leerlo en las crónicas
antes de construirlo, y hoy no está en el registro.

## 2. Plano

Unos 120 × 120 m, más pequeño que Carmenca (240 × 340). Se cruza andando en un minuto.

```text
                N (arriba: ladera hacia Carmenca)
     ┌───────────────────────────────────────────────┐
     │  [S] llegada desde Carmenca                    │
     │    \                                           │
     │     calle de bajada ─────┐                     │
     │  ┌kancha A┐              │          ┌kancha C┐ │
     │  │ ▪  ▪   │◄ curaca A    │ curaca C►│  ▪  ▪  │ │
     │  └───┬────┘              │          └───┬────┘ │
     │      └──────┐   ┌────────▼───────┐  ┌───┘      │
     │             └──►│     PLAZA      │◄─┘          │
     │                 │ V  · fogón ·  M│             │
     │                 │  gente, fardos │             │
     │                 └───────┬────────┘             │
     │            ┌kancha B┐   │   salida al valle ──►│ (Susurpuquio, F11)
     │            │ ▪  ▪   │◄ curaca B                │
     │            └────────┘   │                      │
     │                  calle de salida ──► combate visible (F10)
     └───────────────────────────────────────────────┘
                S (abajo: el valle; al fondo, la ciudad)

  [S] llegada · V Vicaquirao · M Apo Mayta · ▪ casas de pirca y adobe
```

- **La plaza:** llana, de unos 35 × 25 m, con un fogón en el centro, fardos y vasijas
  dejados por los que huyeron, y algunos asientos de piedra. Vicaquirao y Apo Mayta están
  aquí.
- **Tres kanchas,** una por ayllu: un recinto de pirca baja con 2–3 casas dentro. Cada
  curaca espera a la entrada de la suya.
  - Una kancha cerrada es una pieza nueva del kit: `boundary_walls` alrededor de casas que
    ya existen.
  - La kancha como unidad de vivienda está documentada para el Cusco inca; para 1438 es
    interpretación (ver sección 5).
- **Calles de tierra** de 3–4 m entre muros de pirca.
- **Salidas:**
  - una hacia la ladera de Carmenca, donde se llega;
  - una hacia el valle: Susurpuquio, en F11;
  - una para el combate visible, en F10.

  En F9 son solo calles que se ven; no se cruzan.
- **El fondo:** el valle con más ciudad a lo lejos (`cusco_view`), como en Carmenca.

## 3. Cómo se entiende qué hacer

El cambio principal frente a F8: **se habla con personas,** no con puertas invisibles.

1. **Al llegar** habla Apo Mayta, en un diálogo corto: los curacas esperan a ver quién gana,
   y hay que demostrarles que Cusi tiene gente.
2. **Objetivo en pantalla:** «Habla con los curacas (0/3)». El marcador de objetivo de
   Carmenca (`ObjectiveMarker`) señala al curaca más cercano que queda.
3. **Cada curaca** cuenta su problema en 2–3 líneas y ofrece la misión. Cusi acepta o lo
   deja para luego.
   - **En F9 (misión de prueba):** al aceptarla, un aviso dice «Misión de prueba: [nombre]
     se da por cumplida. +1 Apoyo con [ayllu]».
   - **En F10,** la misión se juega de verdad.
4. **Con 2 de 3,** el objetivo pasa a «Habla con Vicaquirao»: «Ante los curacas».
5. **Volver a hablar** con un curaca ya ayudado da una línea de agradecimiento.

Lo que se ve en el centro según el Apoyo, como gente que vuelve u hombres armados en la
plaza, es de F10. En F9 el centro tiene siempre la misma gente.

## 4. Gente y personajes

| Quién | Dónde | Qué hace |
| --- | --- | --- |
| Vicaquirao | Plaza, junto a la salida del combate | Abre «Ante los curacas» con 2 de 3 |
| Apo Mayta | Plaza, junto al fogón | Explica el Apoyo y dice qué falta |
| Curaca A (ayllu de las llamas) | Entrada de la kancha A | Ofrece la misión A |
| Curaca B (prisioneros) | Entrada de la kancha B | Ofrece la misión B |
| Curaca C (la disputa) | Entrada de la kancha C | Ofrece la misión C, la de la decisión |
| Gente (6–8) | Plaza y calles | Sentados, cargando o hablando, con frases al pasar. No tapan a los curacas |

- **Las misiones y los ayllus siguen con nombre provisional** (canon-check de F8).
- **Ropa:** el aspecto de Apo Mayta y de los curacas es la tarea 5, con capturas.

## 5. canon-check del diseño

| Afirmación | Estado | Etiqueta | Fuente / fila del registro |
| --- | --- | --- | --- |
| Arquitectura de pirca, adobe e ichu, sin cantería | Registrada | Interpretación de diseño | «Arquitectura de 1438»; GDD §10.2 |
| El Cusco medio vacío, con cosas abandonadas | Registrada | Según los cronistas + Licencia | «El Cusco se vacía con la corte» |
| Los curacas esperan a ver quién gana; Cusi debe demostrar que tiene gente | Registrada | Según los cronistas | «Curacas vecinos» (Betanzos, cap. VII) |
| Vicaquirao y Apo Mayta con Cusi en el Cusco | Registrada | Según los cronistas | «Aliados» |
| Apo Mayta conecta con los curacas | Registrada | Personalidad inventada | GDD §5, «Apo Mayta» |
| **Trazado de la plaza, calles y kanchas** | **Sin registrar** | Licencia del juego | Entrada propuesta 1 |
| **La kancha (recinto de pirca con casas) en 1438** | **Sin registrar** | Interpretación de diseño, sin fuente consultada | Entrada propuesta 2 |
| **Los curacas esperan en el Cusco** | **Sin registrar** | Licencia del juego | Entrada propuesta 3. Betanzos cuenta que Cusi les envía mensajeros a sus pueblos, a menos de tres leguas (F7) |

**Entradas propuestas para `HISTORICAL_REFERENCES.md`** (pendientes de tu OK):

1. **Centro del Cusco del Capítulo I:** una plaza con calles y tres kanchas. Es **Licencia
   del juego:** no reproduce un trazado real. Revisar con especialista.
2. **Kanchas en el Cusco de 1438:** recintos de pirca con varias casas. Es
   **Interpretación de diseño,** sin fuente consultada para esa fecha. Revisar con
   especialista.
3. **Los curacas, o sus enviados, acuden al Cusco a hablar con Cusi.** Es **Licencia del
   juego** que condensa el envío de mensajeros a sus pueblos (Betanzos, cap. VII), para que
   las misiones se cojan en el centro.

## 6. Decisiones

1. **¿Cómo es la plaza?**
   - **A · Genérica,** con licencia registrada. **Recomendada:** se construye ya, y una
     revisión posterior la puede cambiar.
   - **B · Basada en la geografía documentada.** Antes hay que leer las fuentes. Retrasa la
     tarea 3 unos días.
2. **¿Dónde se cogen las misiones?**
   - **Cada curaca a la entrada de su kancha.** **Recomendado:** reparte el espacio y obliga
     a recorrerlo.
   - **Todos los curacas en la plaza.** Más rápido de jugar, pero el centro sobra.
3. **¿Apruebas las tres entradas del registro** de la sección 5?

Con esto, la tarea 3 construye el blockout. Se miden el rendimiento y se te mandan capturas
antes del arte (tarea 4).

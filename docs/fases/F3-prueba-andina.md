# Prueba «reconocible andino» (F3, tarea 11)

La segunda mitad del criterio de salida de F3 (GDD §15): Carmenca tiene que **leerse
andina** a primera vista. El veredicto lo da el desarrollador; el agente prepara las
capturas, señala lo que ve y aplica los ajustes que se decidan.

## Capturas
Siete tomas fijas desde la cámara del jugador, con `tools/capture_sector.gd`. Se repiten
igual después de cada ajuste:

```bash
godot --path . -s res://tools/capture_sector.gd -- --out=docs/img/prueba-andina/antes
```

| Toma | Qué enseña |
| --- | --- |
| ![](../img/prueba-andina/antes/1_mirador.jpg) **1 · Mirador** | La apertura: valle, apus, humo, pirca |
| ![](../img/prueba-andina/antes/2_terrazas.jpg) **2 · Terrazas** | Andenes vistos desde abajo |
| ![](../img/prueba-andina/antes/3_huaca.jpg) **3 · Huaca** | La roca sagrada con su anillo de piedras |
| ![](../img/prueba-andina/antes/4_casas.jpg) **4 · Casas** | Casas de adobe con techo de ichu |
| ![](../img/prueba-andina/antes/5_paso.jpg) **5 · Paso** | El estrechamiento entre peñas |
| ![](../img/prueba-andina/antes/6_paso_al_valle.jpg) **6 · Del paso al valle** | Mirada atrás desde lo alto |
| ![](../img/prueba-andina/antes/7_combate.jpg) **7 · Combate** | Los 3 guerreros del paso |

## Lista de lectura
Para cada elemento: **se lee / no se lee / dudoso**. Las observaciones del agente son
propuestas para discutir, no veredictos.

| Elemento (guía visual, GDD §10) | Observación del agente | Veredicto |
| --- | --- | --- |
| Andenes con pirca | Desde abajo (toma 2) se ven como un muro continuo; desde arriba no se distinguen los escalones | |
| Casas de adobe con techo de ichu | Se leen como casas; el techo, como un plano ocre sin espesor de paja | |
| Huaca | Se lee: roca destacada, anillo de piedras y ofrendas (toma 3) | |
| Apus y valle | El mirador funciona (toma 1); los apus son pirámides regulares | |
| Luz de amanecer | Cálida y rasante hacia el valle; mirando cuesta arriba, el cielo se ve de mediodía | |
| Ichu en las laderas | Presente, pero en matas dispersas y del mismo color que el suelo | |
| Paleta de tierra y puna | **Lo más flojo:** todo de cerca es arena amarilla y clara; mirando cuesta arriba (tomas 2, 4, 5) las laderas lisas a 45° encierran el camino como un cañón de desierto | |
| Fondo del sector | Al fondo del paso se ve un muro plano que cierra el sector (tomas 5 y 7) | |

## Decisiones pendientes que entran en esta prueba
1. **Color de los vértices en sRGB** para los materiales cercanos. Hoy se tratan como
   lineales, y eso aclara y desatura los colores oscuros. Es la causa probable del tono
   arena; cambiarlo altera el aspecto aprobado en la tarea 3.
2. **Puertas trapezoidales o rectangulares** (canon; `docs/guia-visual.md`, pregunta 1).
3. **Techos de ichu** que se leen poco desde lejos.
4. **Entrada de orientación** en `HISTORICAL_REFERENCES.md` (la edita el desarrollador).

## Veredicto
Pendiente.

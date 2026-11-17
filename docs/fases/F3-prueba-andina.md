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

## Ajustes aplicados
- **Laderas con tope** (pedido del desarrollador: «parece que el jugador estuviera en un
  acantilado»). Las laderas subían a 54° hasta el borde del sector, con paredes de
  100–135 m. Ahora suben 8 m empinadas (no se pueden escalar) y siguen en lomas suaves
  (`side_max_rise = 8`, `side_far_grade = 0,15` en el layout). El fondo del paso pasa de
  un muro de 30 m a un repecho de 8 m. Recorrido: 117 FPS, 0,07 % de frames lentos y
  0,89 M primitivas, igual que antes del cambio.

## Después de los ajustes
Mismas tomas, con color de vértices en sRGB, `ground_mix = 0,5` y laderas con tope:

| Toma | |
| --- | --- |
| ![](../img/prueba-andina/despues/1_mirador.jpg) **1 · Mirador** | ![](../img/prueba-andina/despues/2_terrazas.jpg) **2 · Terrazas** |
| ![](../img/prueba-andina/despues/3_huaca.jpg) **3 · Huaca** | ![](../img/prueba-andina/despues/4_casas.jpg) **4 · Casas** |
| ![](../img/prueba-andina/despues/5_paso.jpg) **5 · Paso** | ![](../img/prueba-andina/despues/6_paso_al_valle.jpg) **6 · Del paso al valle** |
| ![](../img/prueba-andina/despues/7_combate.jpg) **7 · Combate** | |

## Decisiones del desarrollador
1. **Color de los vértices en sRGB** para los materiales cercanos: adoptado
   (`docs/DECISIONS/0011`). El damero del terreno se suaviza con `ground_mix = 0,5` en la
   paleta A.
2. **Laderas con tope de 8 m:** adoptadas tras recorrerlas.
3. **Puertas rectangulares.** Las trapezoidales podrían ser anacrónicas para 1438.
4. **Techos de ichu:** se quedan como están; engrosarlos pasa al arte final (deuda).
5. **Sin apus cuesta arriba:** las lomas y el cielo bastan.
6. **Entrada de orientación** en `HISTORICAL_REFERENCES.md`: la edita el desarrollador.

## Veredicto
**Superada** (2026-11-17). El desarrollador recorrió Carmenca después de los ajustes:
«está genial». Carmenca se lee andina; cumple la segunda mitad del criterio de salida de
F3.

## Pasa al arte final
- Techos de ichu con espesor de paja visible desde lejos.
- Apus regulares (pirámides) en el fondo del valle.

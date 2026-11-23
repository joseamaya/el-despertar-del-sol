# F6 · Diagnóstico del bloqueo (tarea 2)

**Fecha:** 2026-11-23 · **Estado:** cifras y opciones; la decisión es del desarrollador
(tarea 3)

## La queja

«No detecta los bloqueos a veces» (P2), «el bloqueo está medio raro» (O1), y la mayoría se
atascaba en el entrenamiento con el bloqueo (`F5-analisis.md`, §4.1).

## Cómo se midió

`tools/block_diagnosis.gd` deja a Cusi con el bloqueo pulsado y cuenta qué hace cada golpe
que le llega. Para los que entran, anota el motivo: fuera del arco frontal, guardia rota
por falta de resistencia, atacando, aturdido o sin bloquear. Corre en headless con paso
fijo, así que dos ejecuciones dan el mismo resultado. Cada escenario dura 120 s de juego.
Cusi no puede morir, pero la resistencia, las guardias rotas y los aturdimientos son
reales.

```bash
godot --headless --fixed-fps 60 --path . -s res://tools/block_diagnosis.gd -- \
    --mode=arena --enemies=3 --lock --seconds=120
```

**Escenarios:**
- **Arena, quieto:** Cusi no se mueve ni gira; es el jugador novato que solo pulsa F.
- **Arena, con objetivo fijado:** Cusi mira al guerrero fijado.
- **Arena, peleando:** con objetivo fijado y un golpe ligero cada 2,5 s entre guardias.
- **Entrenamiento:** el paso del bloqueo con Vicaquirao, sin fin, sin fijar objetivo y
  fijándolo.

## Resultados

| Escenario | Golpes | Bloqueados | Entran | Motivo de los que entran |
| --- | --- | --- | --- | --- |
| Arena, 1 guerrero, quieto | 23 | 12 | **11 (48 %)** | Fuera del arco: 11 |
| Arena, 1 guerrero, objetivo fijado | 23 | 23 | 0 | — |
| Arena, 1 guerrero, peleando | 6 | 5 | 1 (17 %) | Atacando, sin guardia: 1 |
| Arena, 3 guerreros, quieto | 67 | 14 | **53 (79 %)** | Fuera del arco: 53 |
| Arena, 3 guerreros, objetivo fijado | 64 | 33 | **31 (48 %)** | Fuera del arco: 31 |
| Arena, 3 guerreros, peleando | 28 | 14 | **14 (50 %)** | Fuera del arco: 9 · atacando, sin guardia: 5 |
| **Entrenamiento, sin fijar** | 25 | 8 | **17 (68 %)** | Fuera del arco: 17 |
| Entrenamiento, objetivo fijado | 25 | 25 | 0 | — |

En «Bloqueados» se incluye un parry, en la arena con 3 guerreros peleando.

**Conclusiones:**
1. **El arco frontal de 120° es casi la única causa.** El guerrero rodea a Cusi antes de
   golpear, y Vicaquirao también. Si Cusi no lo encara, el golpe entra aunque F esté pulsada.
2. **La resistencia no es la causa:** **0 guardias rotas** en todos los escenarios. Con
   15 por golpe bloqueado y la recuperación del GDD §6.5, da tiempo de sobra.
3. **El entrenamiento es el peor caso.** Sin fijar objetivo, 2 de cada 3 golpes de
   Vicaquirao entran. Con objetivo fijado entran 0, pero **el entrenamiento nunca enseña a
   fijar objetivo**: sus objetivos solo hablan de F / LB. Eso explica que la mayoría se
   atascara ahí.
4. **Atacar deja sin guardia** (5 golpes de 28 con 3 guerreros). Es lo esperado: el
   bloqueo se suspende mientras atacas. No parece la queja principal.

### ¿Bastaría con ampliar el arco?

Golpes que quedarían **fuera** con otros arcos, con los mismos ángulos medidos:

| Escenario | 120° (hoy) | 180° | 240° |
| --- | --- | --- | --- |
| Arena, 1 guerrero, quieto | 48 % | 35 % | 22 % |
| Arena, 3 guerreros, quieto | 79 % | 57 % | 39 % |
| Arena, 3 guerreros, objetivo fijado | 48 % | 36 % | 23 % |
| Arena, 3 guerreros, peleando | 39 % | 25 % | 18 % |
| Entrenamiento, sin fijar | 68 % | 36 % | 36 % |

Ampliar el arco mejora algo, pero no lo arregla: incluso con 240°, un tercio de los golpes
del entrenamiento sigue entrando. Además, un bloqueo casi circular quita sentido a que los
enemigos rodeen (GDD §6.1, «leer al enemigo antes de atacar»; §14.4, criterio 5).

## Opciones (tarea 3)

1. **Al bloquear, Cusi se gira hacia quien le ataca.**
   - Sin objetivo fijado, mientras se mantiene F, Cusi gira hacia el guerrero más cercano
     cuyo golpe está en anticipación, a una velocidad de giro limitada y ajustable en
     `DefenseTuning`.
   - Con objetivo fijado, sigue mirando al objetivo, como hoy.
   - **Efecto esperado:** el entrenamiento y los combates contra un guerrero quedan como
     con objetivo fijado (0 % de golpes que entran). Con 3 guerreros siguen entrando los
     golpes simultáneos de dos lados, que es la presión que buscan los encuentros.
   - **Coste:** medio. Afecta a la orientación del jugador, con pruebas, y se vuelve a
     medir con esta misma herramienta.
2. **Ampliar el arco a 180°** (`DefenseTuning.block_arc_deg`).
   - **Efecto:** lo de la tabla de arriba. Ayuda, pero el entrenamiento seguiría con un
     tercio de golpes que entran.
   - **Coste:** mínimo, solo un valor en un `.tres`.
3. **Enseñar a fijar objetivo en el entrenamiento:** un paso nuevo antes del bloqueo,
   «Entrenamiento: fija a Vicaquirao con Q / R3», y los objetivos del bloqueo que lo
   recuerden.
   - **Efecto:** con objetivo fijado, el entrenamiento da 0 %. Además enseña la mecánica
     que más ayuda en todo el combate.
   - **Coste:** bajo. Es un paso de datos en `carmenca_slice.tres`, con su texto y su
     prueba, como los otros pasos del entrenamiento.

**Recomendación del agente: 1 + 3, con el arco en 120°.**
- La opción 1 arregla la queja para quien no fija objetivo.
- La opción 3 enseña la herramienta que el combate ya da.
- El arco de 120° mantiene el peligro de que te rodeen, y la tarea 5 (aviso del golpe que
  atraviesa el bloqueo) explica al jugador por qué entra un golpe por la espalda.

La opción 2 queda como plan B si la 1 no convence al probarla: se puede combinar con ella.

## No verificado

- **Es un bot, no una persona:** una persona gira la cámara y se mueve, así que en la
  práctica los porcentajes «sin fijar» serán algo menores. La tendencia coincide con lo
  que contaron los jugadores.
- **El efecto real de la opción 1** se mide al implementarla (tarea 3).
- **La sensación** (si el giro automático se siente natural o «mágico») solo la puede
  juzgar el desarrollador jugando.

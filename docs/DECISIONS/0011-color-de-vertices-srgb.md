# 0011 · Color de vértices en sRGB para el escenario cercano

**Fecha:** 2026-11-17 · **Estado:** aceptada (decidida por el desarrollador)

## Contexto
Los generadores de F3 cuecen los colores de la paleta (que están en sRGB) como color de
vértice. Godot interpreta el color de vértice como lineal salvo que el material diga lo
contrario. Desde la tarea 7, solo el fondo lejano (`FAR`) lo hacía, así que la pirca, el
terreno y las plantas se veían más claros y desaturados que su color de paleta. En la
prueba «reconocible andino» (tarea 11), mirando cuesta arriba, todo parecía arena de
desierto.

## Decisión
1. **Todos los materiales con color de vértice lo leen como sRGB**: pirca, terreno,
   plantas y fondo lejano. Cambia el aspecto aprobado en la tarea 3 (variante A): la
   tierra pasa de arena clara a ocre y rojiza, con más contraste.
2. **Nuevo valor de paleta `ground_mix`** (0–1): cuánto puede desviarse cada celda del
   terreno de la tierra hacia la hierba seca. Con sRGB, el damero de celdas se notaba
   más; la paleta A lo baja a 0,5. Las paletas B y C quedan en 1,0.

## Consecuencias
- Los colores de `palette_*.tres` se ven ahora tal como se eligieron. Las capturas de
  `docs/img/guia-visual/` son anteriores a este cambio.
- Comparación antes y después en `docs/fases/F3-prueba-andina.md`.

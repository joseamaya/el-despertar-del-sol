# 0012 · Integración del vertical slice en F4

**Fecha:** 2026-11-17 · **Estado:** aceptada (decidida por el desarrollador)

## Contexto
F4 tiene que convertir la Carmenca de F3 en el vertical slice del GDD §14: de 8 a 12
minutos de principio a fin en una build exportada, en 3 semanas (`0009`). Varias piezas
tocan canon, dirección artística o alcance, así que se deciden antes de construirlas
(backlog en `docs/fases/F4-backlog.md`).

## Decisión
1. **Textos.** El agente escribe un borrador corto de cada texto: Vicaquirao en la
   apertura, el comunero, el cierre y la entrada del códice. Cada dato histórico lleva su
   etiqueta según `HISTORICAL_REFERENCES.md`. El desarrollador corrige y aprueba antes de
   que el texto entre en el juego. Toda licencia nueva la registra él.
2. **Diferencia visible del Apoyo: comuneros que distraen.** Si el jugador ayuda a la
   familia, 1–2 comuneros llegan al paso y atraen cada uno a un guerrero chanca, sin dar
   golpes decisivos. Reutilizan la IA del guerrero con la facción cambiada; no hay un
   aliado de combate completo.
3. **Personajes: tintes y accesorios por script** sobre el maniquí UAL. Cusi Yupanqui con
   unku rojo y amarillo (§10.4), y piezas como el llauto, las orejeras o la manta del
   comunero. Sin modelos nuevos.
4. **Visión de la huaca: siluetas en la niebla.** Unos segundos: sube la niebla, aparecen
   siluetas de piedra en las terrazas y se desvanecen. Solo con lo que permite el
   renderer Mobile (`0004`).
5. **Audio:** solo CC0 o licencias claras, registradas en `docs/ASSET_SOURCES.md`. Cada
   descarga se pide al desarrollador con nombre, origen y tamaño.

## Consecuencias
- El orden de recorte de F4 sigue en pie si la fase pasa de 4,5 semanas:
  1. la visión baja a un destello y un texto;
  2. la música;
  3. los comuneros pasan a ser un guerrero chanca menos en el paso.
- Los comuneros que distraen necesitan una facción en el director de encuentros, que hoy
  solo conoce al jugador como objetivo. Es el mayor riesgo técnico de la fase.

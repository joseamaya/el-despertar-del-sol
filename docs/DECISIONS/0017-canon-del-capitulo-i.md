# 0017 · Canon del Capítulo I: visión, armas de los chancas y leales (F7)

**Fecha:** 2026-11-24 · **Estado:** aceptada (decidida por el desarrollador)

## Contexto
F7, tarea 2: contrastar el canon que necesita el Capítulo I con el texto de las crónicas.
Se leyeron Betanzos (caps. I–XIV), Sarmiento (guerra chanca) y Molina (Susurpuquio). El
detalle está en `docs/fases/F7-canon-capitulo-1.md`. Las crónicas no coinciden en la
visión, y Sarmiento da a los chancas un arma distinta de la del slice.

## Decisión
1. **Visión de Susurpuquio:** la noche antes del asalto, en la fuente, **cae un cristal** en
   el agua (Molina) y aparece una **figura de luz con forma humana, ambigua**: el juego no
   dice si es el Sol (Sarmiento, Molina) o Viracocha (Betanzos). Encaja con GDD §3.3.
2. **Los guerreros chancas llevan lanza larga** desde el Capítulo I (Sarmiento, cap.
   XXVIII). El slice `0.2` no cambia mientras dura su prueba (`0016`).
3. **Quilescachi Urco Guaranga,** el tercer señor que se queda con Cusi según Betanzos,
   aparece solo en el códice; no es un personaje con escenas.
4. **Sin cascos ni corazas** en 1438: protección con rodela y ropa (propuesta del agente;
   nada en las crónicas leídas los documenta para esta época).
5. **La skill `canon-check`** se crea en F8, cuando se escriban textos del capítulo
   (propuesta del agente).

## Consecuencias
- `HISTORICAL_REFERENCES.md` y GDD §3.2, §7 y §9 recogen estos puntos.
- **Lanza larga:** es un enemigo de alcance distinto. Afecta a la IA, las animaciones y el
  tuning del guerrero chanca. Se estima en la tarea 4 de F7 y se produce en F8+.
- La duda del registro sobre el campamento chanca queda resuelta: Vilcaconga (Betanzos).

## Cuándo revisarla
- Al cotejar las citas con la edición de Martín Rubio de Betanzos.
- Si la revisión de un especialista (GDD §3.6) lo pide.

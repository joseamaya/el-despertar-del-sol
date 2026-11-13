# 0005 · Resolución del 3D en el equipo de referencia

**Fecha:** 2026-11-13 · **Estado:** propuesta (pendiente de decisión del desarrollador)

## Contexto
El GDD pide 60 FPS a 1080p en el equipo de referencia (UHD 770). La medición con relieve
(`docs/rendimiento/2026-11-carmenca-proxy.md`) muestra que Mobile a 1080p nativos se queda en
60 FPS de media con el 19,5 % de frames por encima de 16,7 ms. El límite es el fill rate:
con el 3D al 83 % se logran 76 FPS (0,3 % lentos) y al 75 %, 88 FPS (0,1 % lentos).
El monitor del equipo de referencia es 1600×900.

## Opciones
1. **Salida a 1080p con el 3D escalado** (`scaling_3d_scale` 0,75–0,83, FSR 1 o bilineal)
   en el preset por defecto del equipo de referencia; la interfaz a resolución completa.
   Ajustable en el menú de opciones. *Recomendada.*
2. **Cambiar el criterio a 1600×900 nativos**, la resolución del monitor de referencia.
   Equivale en coste a la opción 1 al 83 %, pero el GDD deja de hablar de 1080p.
3. **Mantener 1080p nativos** y recortar contenido (menos relieve visible, niebla más
   cerrada, menos distancia de dibujo). Afecta a la identidad del paisaje (GDD §10.3).

## Decisión
Pendiente.

## Revisar
En F3, con el escenario real de Carmenca.

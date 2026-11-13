# 0005 · Resolución del 3D en el equipo de referencia

**Fecha:** 2026-11-13 · **Estado:** aceptada

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
**Opción 1**, elegida por el desarrollador el 2026-11-13.

- La salida sigue siendo 1080p; el 3D se renderiza al **75–83 %** en el preset por defecto
  del equipo de referencia. La interfaz va a resolución completa.
- El valor exacto (75 % o 83 %) y el filtro (FSR 1 o bilineal) se eligen a ojo cuando exista
  el preset de gráficos, y quedan como opción del menú (GDD §12.4, §14.2).
- Sombras del sol hasta ~100 m como valor de partida.

## Consecuencias
- El criterio del GDD se lee como «60 FPS con salida a 1080p», no «3D nativo a 1080p».
- No hay cambio en `project.godot` todavía: en el monitor de 1600×900 de referencia la
  ventana ya renderiza ~83 % de los píxeles de 1080p. El ajuste se implementa con el
  servicio de ajustes (menú de opciones del slice).
- Las mediciones futuras se hacen con `--scale3d=` igual al preset elegido.

## Revisar
En F3, con el escenario real de Carmenca.

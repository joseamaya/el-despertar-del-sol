# 0010 · Producción del escenario de Carmenca en F3

**Fecha:** 2026-11-16 · **Estado:** aceptada (decidida por el desarrollador)

## Contexto
F3 tiene que dejar un sector de Carmenca «recorrible a 60 FPS y reconocible andino»
(GDD §15) en 3 semanas (`0009`). El GDD §10.5 prevé un kit modular propio en Blender, pero
el desarrollador no modela en Blender. Los paquetes CC0 disponibles (Kenney, Quaternius)
son genéricos o medievales: justo lo que el criterio de salida quiere evitar.

## Decisión
1. **Arte generado por script.** Los agentes generan la geometría low poly desde Godot:
   relieve, terrazas, muros de pirca, casas de adobe con techo de ichu, la huaca, el
   paisaje lejano. Mallas por código con colores planos (§10.1, §10.4), guardadas como
   recursos `.tres`/`.tscn` por generadores reproducibles. El desarrollador dirige y
   aprueba la dirección artística.
2. **Sin Blender MCP por ahora.** No se añade la dependencia. Si más adelante alguna pieza
   pide Blender, se revisa el MCP, se fija una versión y se decide de nuevo.
3. **El plan no cuenta con modelado del desarrollador.** Su tiempo va a dirigir, revisar
   capturas y recorrer el escenario.

## Consecuencias
- Los generadores de geometría son código del repositorio (con pruebas de lo que se pueda
  probar: dimensiones, colisiones, número de piezas) y no scripts sueltos de un solo uso.
- El kit modular del GDD §10.5 (20–30 piezas) se construye por script; F3 apunta a 10–15.
- Calidad visual limitada a formas simples con buena luz (§10.1, «la luz hace el
  trabajo»). Si el criterio «reconocible andino» no se alcanza así, se replantea esta
  decisión antes de cerrar F3.
- Licencias de diseño del escenario registradas en `HISTORICAL_REFERENCES.md`.

## Revisar
En la tarea 11 de F3 (prueba «reconocible andino») y al cerrar F3.

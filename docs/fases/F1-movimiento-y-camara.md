# F1 · Movimiento y cámara — nota de cierre

**Fechas:** 2026-11-13 – 2026-11-13 · **Estado:** cerrada

Criterio de salida confirmado por el desarrollador el 2026-11-13.

## Criterio de salida (GDD §15)

«Moverse y fijar objetivo se siente bien» — el desarrollador probó en la escena gris la
locomoción (tarea 1), la cámara (tarea 2), el lock-on (tarea 5) y el maniquí animado con
lock-on (tarea 6) y los dio por buenos.

## Qué se hizo

| Tarea | PR | Resultado |
| --- | --- | --- |
| 1 · Locomoción básica | #2 | `PlayerController` con carrera, sprint, aceleración y giro; escena gris de prueba |
| — · Skill `godot-component` | #3 | Patrón de componente: tuning, lógica pura, nodo delgado, pruebas |
| 2 · Cámara en tercera persona | #4 | `CameraController` con órbita, colisión (`SpringArm3D`) y ajustes del jugador |
| 3 · Medición de rendimiento | #5 | Proxy de Carmenca con relieve; renderer Mobile confirmado; 3D al 75–83 % |
| 4 · Motor de física | #6 | GodotPhysics3D fijado frente a Jolt; herramienta de comparación |
| 5 · Lock-on | #7 | Fijar, cambiar y soltar objetivo; cámara y jugador orientados; maniquíes |
| 6 · Maniquí animado | #8 | Quaternius UAL1 (CC0) con BoneMap humanoide; mezcla por velocidad; giro con lock-on |
| 7 · Cierre | este PR | Skill `phase-gate`, `tools/scene_benchmark.gd`, build jugable |

## Verificación (commit `d50db34`)

- Pruebas: **86/86** en verde (gdUnit4). gdformat y gdlint sin errores.
- CI de `main` en verde (lint, pruebas, exportación).
- Builds exportados en local: Linux (76 MB) y Windows (111 MB). El de Linux arranca.
- **El build ahora abre la escena gris jugable**: `scenes/main.tscn` instancia
  `scenes/tests/locomotion_test.tscn` (antes era una escena vacía).

## Rendimiento (UHD 770, renderer Mobile, salida a 1080p, una pasada)

| Escena | 3D al | FPS medio | 1 % bajo | Frames > 16,7 ms |
| --- | --- | --- | --- | --- |
| Escena gris, maniquí animado corriendo en círculo | 100 % | 190,2 | 84,5 | 0,03 % |
| Escena gris, maniquí animado corriendo en círculo | 83 % | 244,2 | 171,2 | 0 % |
| Proxy de Carmenca con relieve | 83 % | 83,6 | 72,9 | 0 % |
| Proxy de Carmenca con relieve | 75 % | 92,5 | 74,0 | 0,04 % |

Comparado con la medición de la tarea 3 (proxy: 76,0 FPS al 83 %, 88,1 al 75 %), sin
caídas. Un personaje animado no pesa en esta escena; el riesgo de CPU (varios enemigos
con IA y animación) sigue abierto para F2.

## Decisiones de la fase

- `0004` revisada: se mantiene el renderer Mobile.
- `0005` aceptada: salida a 1080p con el 3D al 75–83 % en el equipo de referencia.
- `0006` aceptada: GodotPhysics3D fijado explícitamente.

## Lo aprendido

- **Medir con el paisaje real cambia la conclusión.** Con suelo plano Mobile iba
  sobrado (88 FPS); con relieve, a 1080p nativos no llegaba. El límite es el fill rate de
  la GPU integrada, no la geometría.
- **Las pruebas de integración con input simulado funcionan en headless** y cazan errores
  reales (duraciones que tiran al jugador de una plataforma, comprobaciones dependientes
  del entorno de CI).
- **Generar `.tres`/`.tscn` por script** evita errores de formato; trampas encontradas:
  caché de recursos entre generadores, MultiMesh en headless, instancias que necesitan
  «hijos editables». Están en la skill `godot-component`.
- **Una prueba mal planteada puede esconder un problema** (los golpes siempre pasaban por
  el centro): conviene aleatorizar lo que no se está probando.
- **Duración:** el GDD estimaba 3 semanas; se completó en una sesión con agentes. El GDD
  pide recalcular el plan al cerrar F2, no ahora.

## No verificado

- Rendimiento y comportamiento en **Windows** (solo se exporta).
- **Mando físico**: todas las acciones están mapeadas, pero no se probaron con un mando.
- **Varios personajes animados** a la vez (CPU).

## Pasa a F2 · Combate

Deudas y decisiones que F2 debe resolver:

1. **Golpes que atraviesan** a ≥ 30 m/s (0,4–2,6 %, `0006`): el sistema de Hitbox debe
   cubrir el recorrido del arma entre frames o limitar su velocidad.
2. **Guardia lateral real**: sin clips de desplazamiento lateral, con lock-on el jugador se
   gira hacia donde corre. Si el combate pide pasos laterales mirando al enemigo, hacen
   falta clips (p. ej. UAL1 Pro, 9,99 USD, CC0); la regla actual se sustituye por una
   mezcla 2D.
3. **Marcador temporal de lock-on** (`LockOnMarker`): sustituir por el HUD (GDD §12.1).
4. **Escalón de 0,25 m**: el personaje queda 7 frames en el aire al bajarlo pese al
   `floor_snap_length`; revisar si se nota en combate.
5. **Decisiones de diseño abiertas** (planteadas al probar la skill con un
   StaminaComponent): ¿se puede atacar con la resistencia a medias?, ¿el sprint gasta
   resistencia? (GDD §6.5 no lo dice).
6. **Publicar avances** desde F2 (GDD §15): vídeos cortos o devlog. La skill `devlog`
   (GDD §16.5) se propondrá cuando haga falta.

# F4 · Integración del slice — nota de cierre

**Fechas:** 2026-11-17 – 2026-11-19 · **Estado:** pendiente de confirmación del desarrollador

## Criterio de salida (GDD §15)

«8–12 min completos en build exportada»:

- **Partida del desarrollador:** el 2026-11-19 jugó la build exportada de Linux (`main`
  5acffb8) de principio a fin y tardó **10 min** hasta el «Fin». El tiempo de partida lo
  mide el propio juego, sin contar pausas.
  - Incluye reintentos: le costó ganar la segunda oleada del paso.
  - Antes del tutorial y de los refuerzos tardaba 4 min 28 s, y con el tutorial, 6 min 36 s.
    De ahí salieron las tareas 12a y 12b.
- **Bot de principio a fin** (`--playthrough`): termina el slice en 3 min 55 s sin errores.
  No explora, no muere y lee cada línea en 2,5 s.
- **Builds exportadas:**
  - Linux y Windows se generan en local y en la CI de `main`.
  - La de Linux arranca en headless.
  - **La de Windows no se ha probado en un equipo con Windows** (ver «No verificado»).

## Qué se hizo

| Tarea | PR | Resultado |
| --- | --- | --- |
| 1 · Decisiones previas | #38 | `0012`: textos del slice como borradores, comuneros que distraen, aspecto por tintes y accesorios, siluetas en la niebla |
| 2 · Esqueleto del recorrido | #39 | `SliceDirector` con la secuencia en datos, una zona por encuentro, 4 checkpoints, «Fin» |
| 3 · Diálogo mínimo | #40 | Caja de diálogo y `DialoguePlayer` con `tr()`; apertura con Vicaquirao |
| 4 · Huaca | #41 | Ofrenda de coca, +10 de resistencia máxima, visión de 6 s con siluetas de piedra |
| 5 · Códice | #42 | Entrada «Huaca» con su etiqueta; pantalla con Tab / Back |
| 6 · Decisión de Apoyo | #43, #44 | Familia del ayllu, elección y llamas; 2 comuneros que distraen a 2 chancas en el paso |
| 7 · Cierre del slice | #45 | Pututus, Cusi mira al Cusco, fin |
| 8 · Interfaz | #46 | Menú de pausa; volumen, sensibilidad y calidad gráfica guardados en el autoload `Settings` |
| 9 · Audio | #48 | Viento, pasos por superficie, música provisional, pututu, visión amortiguada |
| 10 · Personajes | #49 | `CharacterLook`: Cusi, Vicaquirao y comuneros distinguibles |
| 11 · Mando y Windows | #50 | Mapa de mando probado y A/B en menús; guía de prueba en Windows. El mando físico pasa a F5 |
| 12 · Partida completa | #51 | Bot que juega el slice entero, tiempo de partida en el «Fin» |
| 12a · Tutorial | #53 | Vicaquirao entrena bloqueo, parry, esquiva y golpe; no hace daño ni cae |
| 12b · Refuerzos en el paso | #54 | 3 chancas más tras los 3 primeros, con pututu y cartel; nunca más de 3 a la vez |
| 12c · Carmenca recién abandonada | #55 | 10 casas, señales de huida, familia que baja, 2 ancianos y 2 leales |
| Voces del mirador | #57 | La familia baja tras el entrenamiento y le habla a Cusi; Vicaquirao guarda el mirador |
| CI y repositorio | #47, #52, #56 | Pruebas en dos jobs; builds de `main` descargables; tres pruebas frágiles corregidas |
| Registro histórico | #58 | 8 licencias del slice registradas y 2 comprobaciones pendientes |
| 13 · Cierre | este PR | Esta nota |

Fuera de los PRs, el **repositorio pasó a ser público** (2026-11-19), sin secretos en el
historial y con licencias de recursos CC0, MIT y CC BY acreditadas. `main` quedó
**protegida**: PR obligatorio, los 5 checks en verde, sin force push ni borrado.

## Verificación (commit `421282d`)

- **Pruebas:** **394/394** en verde (gdUnit4). gdformat y gdlint sin errores (`scripts`,
  `tests`, `tools`).
- **Import:** `godot --headless --import` sin errores.
- **Builds exportadas:**
  - Linux: 78 MB; arranca con `--headless --quit-after 10`.
  - Windows: 113 MB.
- **CI de `main`:** en verde en lint, las dos mitades de pruebas y las dos exportaciones.
  Las builds de cada merge quedan como artefactos durante 7 días.

## Rendimiento

Bot de principio a fin, renderer Mobile, 3D al 83 %, equipo de referencia
(`docs/rendimiento/2026-11-slice-completo.md`):

| | Partida (2026-11-18, carga 4–10) | Partida en reposo (2026-11-19, con 12c) |
| --- | --- | --- |
| FPS medio | 109,0 | 124,6 |
| 1 % bajo | 40,5 | 53,8 |
| Frames > 16,7 ms | 0,6 % (combate 1,1 %) | 0,1 % (combate 0,1 %) |
| Primitivas máx. | 1,05 M | 1,05 M |
| Draw calls máx. | 191 | 200 |

- **Sin regresión:** el slice completo, con tutorial, refuerzos y Carmenca habitada, cumple
  con margen el criterio de rendimiento de F3.
- **Combate:** el 1,1 % de frames lentos de la primera medida era ruido de la carga de la
  máquina.
- **Sin repetir:** el #56 (que abarata) y el #57 (un subtítulo) no se volvieron a medir,
  porque la máquina tenía otra carga de 22–29.

## Decisiones de la fase

- **`0012` · Integración del slice:**
  - textos como borradores del agente que aprueba el desarrollador;
  - los comuneros del Apoyo distraen a chancas y no matan;
  - aspecto de los personajes por tintes y accesorios sobre el maniquí;
  - la visión como siluetas de piedra en la niebla.
- **Alcance, decidido al jugar:**
  - se añadieron el tutorial, los refuerzos en el paso y la Carmenca habitada (tareas 12a–c)
    para llegar a los 8 minutos;
  - **no** se añadieron compañeros que sigan a Cusi por todo el recorrido. El desarrollador
    lo dejó fuera de F4 para no cambiar lo que ya funciona.
- **Repositorio público y `main` protegida:** el desarrollador lo decidió para acabar con el
  límite de almacenamiento de artefactos.

## Lo aprendido

- **Medir con una persona, no con el bot:** el bot terminaba en 3 minutos y el desarrollador
  en 4 min 28 s, aún lejos del criterio. Medir pronto con una persona permitió añadir
  contenido con sentido (tutorial y refuerzos) en lugar de alargar por alargar.
- **Lo que no ve el jugador no existe:** la familia que huía pasaba desapercibida durante el
  entrenamiento. Mostrar cada cosa cuando el jugador mira es más barato que añadir más.
- **El runner de CI es más lento que la máquina local:** varias pruebas de tiempos fallaban
  solo allí.
  - Limitar Godot a un núcleo (`taskset -c 0`) reproduce esos fallos en local.
  - Las pruebas deben medir eventos (señales) o máximos, no un instante.
  - No deben depender de hacia dónde mira la cámara.
- **La cuota de artefactos de un repo privado se agota por acumulación:** borrarlos no la
  libera hasta el ciclo siguiente.
- **Licencias:** registrar las licencias históricas al crear el contenido evita deudas de
  canon al cerrar.

## No verificado

- **Build de Windows en un equipo con Windows:** la prueba con un amigo sigue pendiente
  (`F4-prueba-windows.md`, sin resultados).
- **Mando físico:** no hay mando disponible; el mapa está probado por código.
- **Rendimiento tras el #56 y el #57:** no se midió de nuevo (ver «Rendimiento»).
- **La segunda oleada del paso con jugadores distintos al desarrollador:** a él le costó
  ganarla.
- **El GDD §14.1 dice «defender un paso contra tres»** y el slice tiene 3 + 3. El GDD no se
  ha actualizado.

## Pasa a F5 · Prueba externa

F5 decide si continuar, ajustar o recortar. Para eso:

1. **Windows y mando:** recoger la prueba del amigo (`F4-prueba-windows.md`) y probar con
   un mando físico.
2. **Dificultad del paso:** observar en la prueba externa si la segunda oleada frustra.
   - Arreglo más suave: que los refuerzos tarden más en llegar (`ArenaController.wave_delay`,
     hoy 2 s), para que la resistencia se recupere.
   - Después, 2 refuerzos en lugar de 3.
3. **GDD §14.1:** actualizar «defender un paso contra tres» si el 3 + 3 se queda.
4. **Prueba frágil:** `test_encounter_three_warriors` mide la aglomeración con un margen
   muy justo (0,101 frente a 0,1) y a veces falla en CI. Su umbral depende de la sensación
   del combate: lo decide el desarrollador.
5. **Canon:**
   - confirmar en Betanzos dónde acampa el grueso chanca antes del asalto;
   - medir con un mapa el desnivel real de Santa Ana (`HISTORICAL_REFERENCES.md`, «Por
     verificar»).
6. **Detalles de presentación:**
   - la familia se lee mejor si la cámara la mira unos segundos;
   - la faldilla del *anacu* es rígida;
   - falta la opción de saltar el tutorial (el flag `skip_training` existe);
   - coma decimal en la etiqueta de sensibilidad;
   - el aviso «2 resources still in use at exit»;
   - el aviso «Tween started with no Tweeners» de `SliceAudio` en las pruebas;
   - el tocado chanca quedó fuera.
7. **Ideas para después del slice (Capítulo I):**
   - Vicaquirao y los leales acompañando a Cusi en combate, con más chancas y el combate
     reajustado;
   - el sistema de Apoyo completo.
8. **Deudas de F3 aún abiertas:**
   - arte final (techos de ichu con espesor, apus menos regulares);
   - ideas de combate de F2 sin decidir;
   - animaciones Pro;
   - tiempo del navmesh al cargar.
9. **Skills (GDD §16.5):**
   - `devlog`, si se quiere empezar a publicar avances para la prueba externa;
   - `canon-check`, antes de escribir más textos del Capítulo I.

   Se proponen cuando F5 las necesite.

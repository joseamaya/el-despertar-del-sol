---
name: phase-gate
description: Cierra una fase del plan de desarrollo de Pachacútec (GDD §15) — verifica pruebas, lint y builds exportados, mide rendimiento en el equipo de referencia, hace inventario de PRs, decisiones y deudas, redacta la nota de cierre en docs/fases/ y, solo con la confirmación del desarrollador, pasa AGENTS.md a la fase siguiente. Úsala siempre que el usuario diga «cierra la fase», «cierre de F1/F2…», «phase gate», «¿podemos pasar a la siguiente fase?», «nota de cierre» o pida comprobar si se cumple el criterio de salida de una fase.
---

# phase-gate

Cerrar una fase es una puerta, no un trámite: el GDD exige que cada fase termine con
**un build exportado y una nota de lo aprendido**, y que no se adelante nada de la
siguiente (§15). La skill reúne las pruebas objetivas para que el desarrollador decida;
**el criterio de salida siempre lo confirma él**, porque todos son subjetivos
(«se siente bien», «es divertido», «reconocible andino»).

## 1. Situarse

1. Lee `AGENTS.md` (sección «Fase actual») y la tabla de `docs/GDD.md` §15: nombre,
   duración estimada y criterio de salida de la fase.
2. Lee la nota de la fase anterior en `docs/fases/` para ver qué deudas se le pasaron
   a esta y si se resolvieron.
3. Trabaja en una rama `docs/cierre-fN`.

## 2. Verificar (cada comando por separado; todo debe pasar)

```bash
godot --headless --path . --import
.venv/bin/gdformat --check scripts tests tools
.venv/bin/gdlint scripts tests tools
GODOT_BIN=$(command -v godot) bash addons/gdUnit4/runtest.sh --headless --ignoreHeadlessMode -a res://tests
godot --headless --path . --export-release "Linux" build/linux/el-despertar-del-sol.x86_64
godot --headless --path . --export-release "Windows" build/windows/el-despertar-del-sol.exe
timeout 60 ./build/linux/el-despertar-del-sol.x86_64 --headless --quit-after 10
```

Comprueba también la CI del último commit de `main`
(`gh run list -b main -L1`). Si algo falla, **la fase no se cierra**: arréglalo en otra
rama o anótalo como bloqueo y para.

## 3. Medir rendimiento

Equipo de referencia y escala del 3D: `docs/DECISIONS/0004` y `0005`. Usa la escala
decidida (`--scale3d=0.833` y `0.75`) además de 1,0 para comparar con mediciones previas.

- Escena de carga: `scenes/tests/perf_carmenca_proxy.tscn` con
  `-- --benchmark --scale3d=<s> --out=<json>` (renderer Mobile).
- Escenas de juego: `tools/scene_benchmark.gd` mide cualquier escena con el jugador
  moviéndose (ver su cabecera). Úsala en la escena principal de prueba de la fase.
- Una pasada por configuración basta para el cierre; si una cifra sorprende, repite
  tres veces y da la mediana. Las ventanas se abren en el escritorio del desarrollador:
  avísale antes.
- Compara con la última medición en `docs/rendimiento/` y señala cualquier caída.

## 4. Inventario

- PRs de la fase: `gh pr list --state merged --search "merged:>=<fecha de inicio>"`
  (o los títulos con «(FN, tarea …)»).
- Decisiones nuevas o revisadas en `docs/DECISIONS/` desde el inicio de la fase.
- Skills creadas o cambiadas en `.claude/skills/`.
- Recursos de terceros añadidos: deben estar en `docs/ASSET_SOURCES.md`.
- Deudas: busca en las notas de los PRs las secciones «No verificado» y «Limitación»,
  y en las decisiones las «Consecuencias» que apuntan a fases futuras.
- Duración real frente a la estimada. Si se pasa un 50 %, el GDD pide **recortar
  alcance**, no añadir tiempo: dilo explícitamente.

## 5. Nota de cierre

Escribe `docs/fases/F<N>-<nombre-corto>.md` con esta estructura (la de F0 es el ejemplo):

```markdown
# F<N> · <Nombre> — nota de cierre

**Fechas:** <inicio> – <fin> · **Estado:** pendiente de confirmación del desarrollador

## Criterio de salida (GDD §15)
«<criterio literal>» — <evidencia: qué probó el desarrollador y cuándo>.

## Qué se hizo
| Tarea | PR | Resultado |

## Verificación
Pruebas (N/N), lint, builds exportados, CI del commit <sha>.

## Rendimiento
Tabla con las cifras y comparación con la medición anterior.

## Decisiones de la fase
## Lo aprendido
## No verificado
## Pasa a F<N+1>
Deudas y preguntas abiertas que la siguiente fase debe resolver o decidir.
```

## 6. Confirmación y paso de fase

1. Presenta al desarrollador el criterio de salida y la evidencia, y **pregúntale si
   lo da por cumplido**. No lo marques tú.
2. Con su sí: estado de la nota → «cerrada», `AGENTS.md` «Fase actual» → siguiente fase
   con su criterio de salida, y `README.md` → estado.
3. PR a `main`. El merge lo hace el desarrollador y es lo que cierra la fase.
4. No empieces ninguna tarea de la fase siguiente: espera a que te la den.

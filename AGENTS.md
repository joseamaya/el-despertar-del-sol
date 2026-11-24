# AGENTS.md — Pachacútec: El Despertar del Sol

Guía obligatoria para cualquier agente de IA que trabaje en este repositorio.
Fuente de verdad del diseño: [`docs/GDD.md`](docs/GDD.md). Si este archivo y el GDD discrepan,
manda el GDD y se avisa al desarrollador.

## Fase actual

**F7 · Segunda prueba externa** (2 semanas). Criterio de salida: la `0.2-slice` probada por
5–10 personas, el criterio 8 de GDD §14.4 medido y la decisión tomada: continuar, ajustar o
recortar (GDD §15). Si se pasa un 50 % de la estimación, se recorta alcance.
Solo se trabaja en el alcance de la fase actual. Nada de la fase siguiente se adelanta.
Deudas heredadas de F6: sección «Pasa a F7» de `docs/fases/F6-ajuste-del-combate.md`.
Fases cerradas: F0 (`docs/fases/F0-preproduccion.md`), F1 (`docs/fases/F1-movimiento-y-camara.md`),
F2 (`docs/fases/F2-combate.md`), F3 (`docs/fases/F3-escenario-carmenca.md`),
F4 (`docs/fases/F4-integracion-del-slice.md`), F5 (`docs/fases/F5-prueba-externa.md`),
F6 (`docs/fases/F6-ajuste-del-combate.md`).
Al cambiar de fase, el desarrollador actualiza esta sección.

## Stack fijado

- **Godot 4.7.2.stable** (estándar, sin .NET). No se cambia de versión a mitad de fase.
- **Renderer Mobile** (equipo de referencia con GPU integrada; ver `docs/DECISIONS/0004`).
  Nada de efectos exclusivos de Forward+ (SDFGI, niebla volumétrica, SSAO/SSIL, SSR).
- **Física: GodotPhysics3D**, fijada explícitamente (`docs/DECISIONS/0006`).
- **GDScript con tipado estático**; `untyped_declaration` es error en `project.godot`.
- **Pruebas:** gdUnit4 6.2.3, vendorizado en `addons/gdUnit4/`.
- **Lint/formato:** gdtoolkit 4.5.0 (`requirements-dev.txt`, entorno en `.venv/`).
- **Versionado:** Git + Git LFS (ver `.gitattributes`). **CI:** GitHub Actions.

## Reglas

1. Leer `docs/GDD.md` y este archivo antes de trabajar.
2. Revisar el código existente antes de proponer cambios.
3. Solo el alcance de la fase actual.
4. No inventar datos históricos: consultar `docs/HISTORICAL_REFERENCES.md`. Toda licencia
   nueva se registra allí con su etiqueta (Documentado / Según los cronistas / Licencia del juego)
   y la decide el desarrollador.
5. No reescribir sistemas que funcionan sin justificarlo por escrito.
6. GDScript tipado; sin controladores monolíticos; sin dependencias nuevas (addons, MCPs,
   paquetes, actions de terceros) sin aprobación.
7. Valores de juego en Resources (`.tres`), no en código.
8. Entregar pruebas y decir explícitamente qué no se pudo verificar.
9. Mantener el proyecto ejecutable después de cada cambio.

## Arquitectura

- Un componente, una responsabilidad (sistemas en GDD §13.3).
- Comunicación por señales. Nada de `get_node()` con rutas hacia otros sistemas ni
  `get_parent()` encadenado: las dependencias se inyectan con `@export`.
- Autoloads solo para servicios globales: guardado, eventos, ajustes.
- Sin dependencias circulares. Un script que pasa de ~300 líneas es señal de dividirlo
  (`gdlint` corta en 400).
- Todo texto visible pasa por `tr()` desde el primer día.
- Presupuesto gráfico pensado para la GPU de referencia: medir antes de añadir luces,
  sombras o partículas.

## Convenciones

- Archivos y carpetas en `snake_case`; `class_name` en `PascalCase`.
- Identificadores y comentarios en inglés; docs, commits, issues y PRs en español.
- Señales en pasado (`damage_taken`, `posture_broken`).
- Orden del script: `class_name`, `extends`, docstring, señales, enums, constantes,
  `@export`, variables, `@onready`, métodos built-in, públicos, privados (`_prefijo`).
- Pruebas en `tests/`, espejando la ruta del código: `scripts/combat/x.gd` →
  `tests/combat/test_x.gd`.
- Escenas `.tscn`: preferir construirlas en el editor. Si un agente las edita a mano,
  cambios mínimos y verificados reimportando el proyecto en headless.
- Carpetas solo cuando hacen falta (estructura objetivo en GDD §13.4).

## Comandos

```bash
# Entorno de lint (una vez)
python3 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt

# Importar / validar el proyecto
godot --headless --path . --import

# Pruebas (headless: sin simulación de input; para pruebas de input, quitar --headless)
GODOT_BIN=$(command -v godot) bash addons/gdUnit4/runtest.sh --headless --ignoreHeadlessMode -a res://tests

# Lint y formato (excluye addons/)
.venv/bin/gdlint $(git ls-files '*.gd' ':!:addons/*')
.venv/bin/gdformat --check $(git ls-files '*.gd' ':!:addons/*')

# Exportar
godot --headless --path . --export-release "Linux" build/linux/el-despertar-del-sol.x86_64
godot --headless --path . --export-release "Windows" build/windows/el-despertar-del-sol.exe
```

## Flujo por tarea

1. Tarea pequeña con criterio de aceptación (una tarde como máximo), idealmente un issue.
2. Leer AGENTS.md, el GDD y el código afectado.
3. Proponer un plan y esperar aprobación.
4. Implementar en una rama `feat/…`, `fix/…`, `chore/…` o `docs/…`, con pruebas.
5. Abrir PR a `main`. Con la CI en verde, el desarrollador prueba en el juego y hace merge.
   **El agente nunca hace merge ni push a `main`.**
6. Si cambia una decisión, registrarla en `docs/DECISIONS/NNNN-titulo.md`.

## Lo que no decide un agente

Sensación del combate, dirección artística, canon histórico, alcance y prioridades.
El agente propone; el desarrollador decide.

## Definición de terminado

- Pruebas nuevas o actualizadas, en verde en local y en CI.
- `gdlint` y `gdformat --check` sin errores; cero advertencias de tipado.
- El proyecto se importa y la escena principal se ejecuta.
- Resumen final con: qué cambió, cómo se probó y qué **no** se pudo verificar.

## Recursos y licencias

Solo CC0 o licencias claras. Arte generado por IA solo como concepto o referencia.
Cada recurso de terceros se registra con origen y licencia en `docs/ASSET_SOURCES.md`
(se crea con el primer recurso). Los MCPs de la comunidad se revisan y se fijan en una
versión antes de usarlos; ningún token tiene más permisos de los necesarios.

---
name: godot-component
description: Crea un componente o sistema de gameplay nuevo en el proyecto Godot de Pachacútec siguiendo AGENTS.md — Resource de tuning, lógica pura testeable, nodo delgado con dependencias inyectadas y señales, escena si hace falta, y pruebas gdUnit4 (unitarias + integración) con lint y formato en verde. Úsala siempre que haya que crear o esqueletar un componente o controlador (HealthComponent, StaminaComponent, PostureComponent, CameraController, Hitbox/Hurtbox, CombatComponent, EnemyAI, InteractionSystem…), añadir un script de gameplay con valores ajustables, o cuando el usuario diga «crea el componente X», «nuevo sistema», «implementa el controlador de…», aunque no mencione la palabra «componente».
---

# godot-component

Crea un componente de gameplay con la forma que el proyecto ya validó en
`PlayerController` (F1, tarea 1). La idea es que cada componente sea pequeño, se
pruebe sin abrir el editor y se ajuste sin tocar código, para que los agentes puedan
trabajar en un sistema sin romper otro (GDD §13).

## Antes de escribir

1. Lee `AGENTS.md` (fase actual, reglas, comandos) y la parte del `docs/GDD.md` que
   define el sistema: tabla de §13.3, y si es combate §6 (tabla de tuning §6.5) o IA §7.
2. Comprueba que el componente pertenece a la **fase actual**. Si no, para y dilo.
3. Revisa el código existente en `scripts/` para reutilizar y no duplicar.
4. Lee el ejemplo de referencia, que es la fuente de verdad del estilo:
   - `scripts/player/movement_tuning.gd` — Resource de tuning
   - `scripts/player/locomotion_math.gd` — lógica pura estática
   - `scripts/player/player_controller.gd` — nodo delgado (cuerpo físico)
   - `tests/player/test_locomotion_math.gd` y `tests/player/test_player_controller.gd`

   Si no están en tu checkout (rama antigua), las plantillas de `assets/` bastan: son
   el mismo patrón para un componente de estado (`Node`) y están probadas.
5. Propón un plan corto (piezas, archivos, señales, pruebas) y espera aprobación,
   salvo que el usuario ya lo haya aprobado.

## Decidir las piezas

No todo componente necesita las cinco piezas. Usa solo las que aporten:

| Pieza | Cuándo | Archivo |
| --- | --- | --- |
| `XTuning` (Resource) | Hay números de diseño (velocidades, costes, tiempos, umbrales) | `scripts/<area>/x_tuning.gd` + `resources/tuning/<nombre>.tres` |
| `XMath` / `XRules` (RefCounted, estático) | Hay cálculos o reglas que se pueden probar sin nodos | `scripts/<area>/x_math.gd` |
| Nodo `X` | Siempre: lee input/estado, llama a la lógica, emite señales | `scripts/<area>/x.gd` |
| Escena | Necesita hijos (formas, mallas, áreas) o se instancia en niveles | `scenes/<area>/x.tscn` |
| Pruebas | Siempre | `tests/<area>/test_x.gd` (+ `test_x_math.gd`) |

`<area>` sigue GDD §13.4: `core`, `player`, `combat`, `enemies`, `systems`.
Crea carpetas solo cuando se usan. Reglas de reparto:

- `player`: lo que solo tiene sentido en el jugador y no es combate (locomoción,
  cámara, interacción del jugador).
- `combat`: recursos y piezas de combate aunque hoy solo los use el jugador
  (Health, Stamina, Posture, Hitbox/Hurtbox, CombatComponent).
- `enemies`: IA, percepción, EncounterDirector.
- `systems`: Support, Narrative, Save, Codex (normalmente autoloads o servicios).
- `core`: utilidades compartidas sin dominio de juego.

**Por qué la lógica va aparte:** las funciones estáticas puras se prueban en
milisegundos y sin física; el nodo queda tan fino que su prueba de integración solo
confirma el cableado.

## Reglas del nodo

- `class_name` en PascalCase, archivo en snake_case, docstring `##` de una o dos líneas.
- Dependencias por `@export` (otro nodo, la cámara, el Resource). Nada de `get_node()`
  hacia otros sistemas, `get_parent()` encadenado ni buscar por grupo para acoplar.
- Hacia fuera, **señales en pasado** (`damage_taken(amount: float)`, `depleted`,
  `posture_broken`). Quien escucha conecta; el componente no conoce a sus oyentes.
- Valores de diseño solo en el Resource. Constantes en código solo para cosas
  técnicas (umbrales numéricos, nombres de acciones como `StringName`).
- Comprueba dependencias obligatorias en `_ready()` con `assert(... , "mensaje")`.
- Si el componente avanza con el tiempo, pon la lógica en un `tick(delta)` público y
  llámalo desde `_physics_process`. Las pruebas lo apagan y avanzan el tiempo a mano.
- Distingue **gasto opcional** (`try_spend`: todo o nada, el jugador decide) de
  **gasto obligatorio** (`drain`: siempre se aplica, recorta en 0 y avisa si no
  alcanzaba, p. ej. un golpe bloqueado que rompe la guardia).
- Señales de umbral (`depleted`, `posture_broken`) se emiten al **cruzar** el umbral,
  una sola vez, no en cada frame que se está por debajo.
- Tipado estático en todo: variables, parámetros, retornos y **variables de bucle**
  (`for i: int in 10`). `untyped_declaration` es error en este proyecto.
- Menos de ~300 líneas. Si crece, divide.
- Texto visible al jugador, siempre con `tr()`.

Plantillas listas para copiar en `assets/`:
`tuning_template.gd`, `logic_template.gd`, `component_template.gd`,
`test_logic_template.gd`, `test_component_template.gd`, `build_scene_template.gd`.

## Resources y escenas: generarlos, no escribirlos a mano

Los `.tres` y `.tscn` escritos a mano fallan con facilidad (ids, uids, formato de
sub-recursos). Genéralos con un script de un solo uso que se ejecuta en headless y se
guarda **fuera del repo** (scratchpad), partiendo de `assets/build_scene_template.gd`:

```bash
godot --headless --path . --import          # registra los class_name nuevos primero
godot --headless --path . -s /ruta/scratch/build_x.gd
```

Si solo necesitas el `.tres`, basta con esto:

```gdscript
extends SceneTree
func _init() -> void:
	print(ResourceSaver.save(StaminaTuning.new(), "res://resources/tuning/player_stamina.tres"))
	quit()
```

Notas:
- Para empaquetar un nodo, cada hijo necesita `owner = raíz`; para instanciar una
  escena dentro de otra usa `instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)` y pon
  `owner` solo en la raíz de la instancia.
- Godot no guarda en el `.tres` los valores iguales al default del script. Es normal:
  el inspector los muestra igual. Dilo en el resumen para que nadie se sorprenda.
- Las acciones de InputMap se añaden con `ProjectSettings.set_setting("input/<accion>", ...)`
  y `ProjectSettings.save()`, con `device = -1` en cada evento (todos los dispositivos).
- Las escaleras se resuelven con una pendiente de colisión invisible: una cápsula no
  sube escalones de más de ~0,1 m por sí sola.

## Pruebas

- **Lógica pura:** casos normales, límites (cero, máximo, negativos), no sobrepasar,
  convergencia, independencia del framerate cuando haya `delta`.
- **Nodo de estado** (`Node`): `auto_free(X.new())` + `add_child()` +
  `set_physics_process(false)`, y avanza el tiempo con `tick(FRAME)` en bucle: así las
  aserciones son exactas. Añade como mucho una prueba con física real si aporta.
- **Nodo físico** (`CharacterBody3D`, áreas): escena de prueba con `scene_runner`.
- Comprueba el cableado (`@export` asignados), un camino feliz y las señales:
  - emitida con argumentos: `await assert_signal(monitor_signals(n)).is_emitted("x", [args])`
  - emitida **exactamente una vez**: `is_emitted` no lo garantiza; conecta un contador
    (`n.depleted.connect(_on_depleted)` que hace `_count += 1`) y `assert_int(_count).is_equal(1)`.
    No uses APIs internas de gdUnit4.
- Input simulado con `Input.action_press/release`; libéralo todo en `after_test()`.
- Para esperar física: `await get_tree().physics_frame` en bucle. Calcula la distancia
  recorrida antes de fijar duraciones: pasarse de una plataforma hace caer al jugador
  y la prueba falla por motivos ajenos a lo que se prueba.
- Las pruebas corren en headless sin eventos reales; no dependas de `_input()` /
  `_unhandled_input()` en ellas. Si el componente los necesita, sepáralo en un método
  público que la prueba pueda llamar.

## Verificar (todo debe pasar)

Ejecuta cada comando por separado. `gdlint`/`gdformat` vienen de `.venv/bin/` del
checkout principal (un worktree no tiene `.venv`; usa la ruta absoluta del principal o
el que esté en el PATH). Pásales tus directorios de trabajo, no los de `addons/`:

```bash
godot --headless --path . --import    # genera los .uid de scripts nuevos: inclúyelos en el commit
.venv/bin/gdformat scripts tests      # formatea
.venv/bin/gdformat --check scripts tests
.venv/bin/gdlint scripts tests
GODOT_BIN=$(command -v godot) bash addons/gdUnit4/runtest.sh --headless --ignoreHeadlessMode -a res://tests
```

Tras el `--import`, `git status` no debe mostrar `.uid` sin añadir.

## Entrega

Trabaja en una rama `feat/<componente>`, salvo que ya estés en una rama o worktree
asignados: entonces usa esa. Termina con un resumen con esta forma:

```markdown
## <Componente>
- Piezas: <tuning / lógica / nodo / escena> con rutas
- Señales: <nombre(args)> — cuándo se emiten
- Valores iniciales del tuning y de dónde salen (GDD §x o «propuesta para ajustar»)
- Pruebas: N unitarias, M de integración, todas en verde; lint y formato OK
- No verificado: <sensación, mando físico, integración con sistemas aún inexistentes…>
```

La sensación de juego la decide el desarrollador: entrega números ajustables, no
opiniones sobre cómo se siente.

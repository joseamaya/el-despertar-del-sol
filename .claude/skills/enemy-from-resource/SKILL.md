---
name: enemy-from-resource
description: Crea un tipo de enemigo nuevo en Pachacútec a partir de datos — EnemyData (.tres) con sus ataques (AttackData), su escena derivada del guerrero chanca (tinte, arma, aviso, estados) y sus pruebas — sin escribir código de IA nuevo, como pide el GDD §7.1 («nuevo enemigo = nuevo Resource + animaciones»). Úsala siempre que el desarrollador pida un enemigo o variante nueva («crea el hondero», «un guerrero más agresivo», «un capitán chanca», «añade el escudero»), o cambiar cómo se comporta un tipo de enemigo existente, aunque no mencione Resources.
---

# enemy-from-resource

El guerrero chanca (F2, tareas 7–8) es la plantilla: `scenes/enemies/chanca_warrior.tscn`
+ `resources/enemies/guerrero_chanca.tres` + `resources/combat/attacks/enemy/*.tres`.
Un enemigo nuevo **reutiliza el mismo código** (EnemyController, PerceptionComponent,
EnemyCombat, EnemyGuard, estados) y cambia datos, aspecto y, si hace falta, qué estados tiene.

## 1. Situarse

1. Lee `AGENTS.md`, GDD §7 (tabla de tipos de enemigo y fase en que entra cada uno) y §6.5
   (tuning). Si el enemigo es de una fase posterior, dilo y para.
2. Lee la plantilla: `scripts/enemies/` (EnemyData, EnemyController, EnemyCombat,
   EnemyGuard, `states/`), la escena del guerrero y sus pruebas en `tests/enemies/`.
3. Decide qué cambia respecto al guerrero:
   - **Solo datos** (más agresivo, más resistente, otros ataques): nuevo `EnemyData` y
     nuevos `AttackData`. Es el caso normal.
   - **Otro comportamiento** (el hondero mantiene distancia; el escudero bloquea siempre de
     frente): primero intenta expresarlo con datos (p. ej. `block_chance` 1, `engage_distance`
     8). Si no se puede, hace falta un estado nuevo: es código, propón plan y usa la skill
     `godot-component` para él. No metas condiciones por tipo de enemigo en los estados
     existentes.

## 2. Datos

- `resources/enemies/<id>.tres` (EnemyData): salud y postura (cada una su `.tres` en
  `resources/tuning/<id>_health.tres` / `_posture.tres`), percepción, movimiento,
  distancias, ataque (`attacks`, rango, distancia de contacto, enfriamiento), defensa y
  reacciones.
- Ataques en `resources/combat/attacks/enemy/<id>_<golpe>.tres` (AttackData). Las fases van
  en **segundos del clip**; mide cuándo la mano va más rápido (ver la tarea 4 de F2 o
  `tests/combat/test_player_attacks.gd`) y ajusta `clip_speed` para que la **anticipación
  real** (`windup_end / clip_speed`) quede en **0,6–0,8 s** para enemigos básicos (GDD §6.5).
- Referencias del GDD §6.5: 5–6 ligeros del jugador para matar a un guerrero básico, 6–8
  golpes enemigos para matar al jugador, 2–3 parries (40 de postura cada uno) para romper
  su postura.
- Genera los `.tres` con un script en headless (ver `godot-component`), no a mano.

## 3. Escena

Genera `scenes/enemies/<id>.tscn` con un script de un solo uso (fuera del repo) que:

1. Instancia `chanca_warrior.tscn` con `GEN_EDIT_STATE_MAIN` y cambia `data`
   (y `data` de Perception, Combat y Guard: todos apuntan al mismo `EnemyData`).
2. Cambia el **tinte** del `Mannequin` (`material_override`) para que se distinga de un
   vistazo (GDD §10.4: los chancas no usan rojo y amarillo, que son incas).
3. Cambia el **arma** si procede (malla bajo `RightHandSocket`, forma y posición del
   `Hitbox`, que siempre va con bando `CHANCA`).
4. Quita o añade estados bajo `States` (cada estado es un nodo; el nombre del nodo es el
   nombre del estado).
5. Lo guarda en una ruta nueva. **No modifiques `chanca_warrior.tscn`** salvo que el cambio
   sea para todos los enemigos.

Trampas conocidas: los recursos se cachean entre generadores (usa procesos separados si
encadenas escenas), las instancias necesitan `set_editable_instance` para cambiar nodos
internos, y en la escena de prueba el objetivo de la percepción se **inyecta**
(`Perception.target = Player`), nunca se busca.

## 4. Pruebas

Copia el patrón de `tests/enemies/test_warrior_combat.gd`:

- Duplica el `EnemyData` en `before_test` si la prueba cambia valores (los recursos son
  compartidos entre pruebas).
- Para probar ataques, congela la IA (`state_machine.set_physics_process(false)`) y lanza
  `combat.start(...)` a mano; reactívala para probar reacciones.
- Mínimo: cableado, anticipación dentro de 0,6–0,8 s (aviso visible solo entonces), daño al
  jugador, el bloqueo del jugador lo para, los parries rompen su postura, y lo que sea
  propio del tipo (p. ej. mantiene la distancia).

Verifica con los comandos de `AGENTS.md` y entrega con el formato de `godot-component`.

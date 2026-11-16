---
name: godot-scene-audit
description: Audita una escena de Pachacútec — coste de dibujo (draw calls, primitivas, luces con sombra) frente al presupuesto de docs/rendimiento, física (cuerpos y formas), nodos vacíos o rotos, scripts largos y acoplamientos prohibidos por AGENTS.md (get_node hacia arriba, get_parent encadenado, grupos, rutas /root) — y propone arreglos sin aplicarlos. Úsala siempre que una escena crezca (niveles, escenarios, kits), antes de cerrar una tarea que añade mucho contenido, cuando el usuario diga «audita la escena», «revisa la escena», «¿cuánto cuesta esta escena?», «¿por qué va lenta?», o al preparar el cierre de una fase.
---

# godot-scene-audit

Una escena puede pasar las pruebas y aun así ser cara de dibujar o estar mal acoplada. Esta
skill lo mide con `tools/scene_audit.gd` y lo compara con las reglas del proyecto. **Propone;
no arregla por su cuenta**: los arreglos van en su propia rama y su propio PR.

## 1. Medir

```bash
godot --headless --path . -s res://tools/scene_audit.gd -- \
    --scene=res://scenes/levels/carmenca.tscn --out=/tmp/audit.json
```

- Espera unos frames (`--frames=10` por defecto) para que los generadores en tiempo de
  ejecución (`SectorLevel`, `StyleVignette`, `KitCatalog`) terminen de construir.
- Imprime un resumen (`SCENE_AUDIT …`) y escribe el JSON completo en `--out`.
- Las primitivas son de **toda la escena**, no solo de lo visible: es una cota superior.
  Lo que se ve en un frame se mide con `tools/scene_benchmark.gd`.
- No mide nodos CSG (las cajas de las escenas de prueba de F1–F2): su coste no aparece.

## 2. Comparar con las reglas

| Qué | Umbral | Fuente |
| --- | --- | --- |
| Draw calls estimadas (superficies + pasada de sombra) | ≤ 350 | `docs/rendimiento/2026-11-carmenca-proxy.md` |
| Primitivas | ≤ 1,2 M | ídem |
| Luces con sombra | ≤ 3 (el sol y dos focos) | ídem, GDD §17 |
| Script | ≤ 300 líneas | `AGENTS.md`, Arquitectura |
| `get_node("../…")`, `$"../…"`, `get_parent().get_parent()` | ninguno | `AGENTS.md`: dependencias por `@export` |
| `get_nodes_in_group`, rutas `/root/` | justificar cada uno | ídem |
| Nodos `Node3D` vacíos, `CollisionShape3D` sin forma | ninguno | limpieza |

Además, revisa a mano lo que el script no ve:

- Mallas repetidas que deberían ir en un **MultiMesh** (muchas `MeshInstance3D` con la
  misma malla).
- Geometría lejana que **proyecta sombras** sin necesidad (`cast_shadow` en apus, fondos).
- Colisiones más finas de lo necesario (`ConcavePolygonShape3D` donde basta una caja o
  un heightmap).
- Materiales duplicados idénticos (cada uno impide agrupar draw calls).

## 3. Informar

Resumen con esta forma, en el PR o en la conversación:

```markdown
## Auditoría de <escena>
- Dibujo: N draw calls estimadas (presupuesto 350), M primitivas (1,2 M), L luces con sombra
- Física: B cuerpos, S formas (tipos)
- Scripts: los que pasan de 300 líneas y los acoplamientos encontrados (archivo:línea)
- Nodos vacíos o rotos
- Propuestas: qué cambiar, por qué y cuánto se gana; ninguna aplicada
- No medido: lo visible por frame (scene_benchmark), CSG, GPU real
```

Si algo está fuera de presupuesto, dilo primero y propone el arreglo como tarea aparte.

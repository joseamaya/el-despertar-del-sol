# Pachacútec: El Despertar del Sol

Action-RPG histórico en tercera persona ambientado en el Cusco de c. 1438.
Diseño completo en [`docs/GDD.md`](docs/GDD.md). Reglas de trabajo en [`AGENTS.md`](AGENTS.md).

**Estado:** Fase 9 · El centro y el lancero. Fases 0–8 cerradas: el vertical slice está jugable y publicado (`0.2-slice`, en prueba con jugadores en paralelo), y el Capítulo I tiene su base: menú, partida guardada, prólogo, Carmenca y centro del Cusco en bruto (`docs/capitulo-1.md`).

## Requisitos

- Godot **4.7.2.stable** (estándar, sin .NET) y sus plantillas de exportación.
- Git y Git LFS.
- Python 3.12+ para gdtoolkit.

## Primeros pasos

```bash
git lfs install
python3 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt
godot --headless --path . --import
```

Abrir el proyecto: `godot --path . -e`.

## Pruebas, lint y exportación

Ver la sección «Comandos» de [`AGENTS.md`](AGENTS.md). La CI (`.github/workflows/ci.yml`)
corre lint, pruebas y exportación para Windows y Linux en cada push y PR a `main`.

## Licencia

© 2026 Miguel Amaya. Todos los derechos reservados. `addons/gdUnit4/` mantiene su
propia licencia (MIT, ver `addons/gdUnit4/LICENSE`).

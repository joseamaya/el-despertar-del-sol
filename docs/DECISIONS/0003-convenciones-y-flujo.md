# 0003 · Convenciones de código y flujo de trabajo

**Fecha:** 2026-11-13 · **Estado:** aceptada

## Decisión
- **Idioma:** identificadores y comentarios en inglés; docs, commits, issues y PRs en español.
- **Tipado:** `untyped_declaration` como error; accesos y casts inseguros como advertencia.
  `inferred_declaration` permitido (`var x := 1` es tipado).
- **Estilo:** gdtoolkit 4.5.0 (`gdlintrc`: líneas de 110, archivos de 400 como máximo).
- **Ramas:** `feat/`, `fix/`, `chore/`, `docs/` con PR a `main`. CI obligatoria; el merge
  lo hace siempre el desarrollador.
- **Repositorio:** GitHub privado `el-despertar-del-sol`, todos los derechos reservados.
- **Herramientas de agente:** `gh` CLI en lugar del MCP de GitHub; `CLAUDE.md` importa
  `AGENTS.md` para tener una sola fuente. Context7 y las skills propias se añaden cuando
  una fase las necesite.
- **Carpeta raíz:** `el-despertar-del-sol/` (el GDD §13.4 decía `pachacutec/`).

## Revisar
Si alguna convención frena el trabajo más de lo que ayuda.

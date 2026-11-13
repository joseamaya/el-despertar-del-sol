# 0002 · gdUnit4 como framework de pruebas

**Fecha:** 2026-11-13 · **Estado:** aceptada

## Contexto
El GDD (§13.1) deja a elegir entre GUT y gdUnit4. El combate (parry, esquiva, lock-on)
necesita pruebas que simulen input y avancen frames.

## Decisión
- **gdUnit4 6.2.3**, vendorizado en `addons/gdUnit4/` (MIT).
- En CI se usa la action oficial `godot-gdunit-labs/gdUnit4-action@v1.4.2` con
  `version: installed`, con display virtual (no headless) para que el input funcione.
- En local, las pruebas sin input corren en headless con `--ignoreHeadlessMode`.

## Consecuencias
- El *scene runner* permite probar escenas completas con input simulado.
- `addons/` queda fuera de LFS y de gdlint/gdformat.
- gdUnit4 v7 permitirá headless real; actualizar requiere nueva decisión.

## Revisar
Si una actualización de Godot rompe el addon.

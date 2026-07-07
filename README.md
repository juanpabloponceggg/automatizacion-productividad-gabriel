# Workspace — Reporte Diario Inventario TD

Workspace para la automatización de Cursor que genera el **reporte diario de productividad** de la plataforma **Seguimiento Inventario TD**.

El agente consulta movimientos del día en Supabase y devuelve un reporte formateado. La notificación a **Microsoft Teams** se configura nativamente en la automatización de Cursor (fuera de este repo).

## Configuración rápida de la automatización

| Campo | Valor |
|-------|-------|
| Repositorio / workspace | `automatizacion-productividad-gabriel` |
| Trigger | Scheduled — cron `0 1 * * *` (7 PM Mérida = 01:00 UTC) |
| MCP | Supabase (proyecto **Seguimiento inventario**) |
| Notificación | Teams (nativo en Cursor Automations) |
| Prompt | Contenido de [`prompts/automation-prompt.md`](./prompts/automation-prompt.md) |

## Base de datos

| Recurso | Valor |
|---------|-------|
| Proyecto Supabase | Seguimiento inventario |
| Project ref | `avrvkghbypqisfpvdqgv` |
| Tabla principal | `movimiento` |
| Función de reporte | `public.reporte_movimientos_diario()` |
| Usuario auditado | Gabriel Gonzalez (`ggonzalezb@grupovive.mx`) |
| Zona horaria | `America/Merida` (UTC-6) |

### Tipos de movimiento

| Tipo | Descripción |
|------|-------------|
| `alta` | Alta de equipo nuevo en inventario |
| `edicion` | Cambios en datos del activo (custodio, specs, sede, etc.) |
| `reasignacion` | Entrega/asignación con carta responsiva |

## Consulta principal

```sql
SELECT public.reporte_movimientos_diario();
```

Devuelve JSON con `resumen` y `usuarios` del día actual (hora Mérida). El agente usa solo esos campos — no lista el detalle individual.

## Estructura del workspace

```
sql/
  reporte_movimientos_diario.sql   # Definición de la función (ya desplegada en Supabase)
queries/
  movimientos_hoy.sql              # Consulta del día
  movimientos_por_usuario.sql      # Desglose por persona
  schema_referencia.sql            # Tablas y columnas relevantes
docs/
  schema.md                        # Documentación del esquema
prompts/
  automation-prompt.md             # ← Prompt para pegar en la automatización
```

## Probar la consulta

Desde el MCP de Supabase o el SQL Editor:

```sql
-- Reporte de hoy
SELECT public.reporte_movimientos_diario();

-- Reporte de una fecha específica
SELECT public.reporte_movimientos_diario('2026-07-07'::date);
```

## Ejemplo de reporte esperado

```
📊 Inventario TD — mar 7 jul 2026

18 movimientos · 11 altas · 5 ediciones · 2 asignaciones

Gabriel Gonzalez — 17 (11 altas, 5 ediciones, 1 asignación)
Samuel Renteria — 1 asignación

→ Gabriel registró 17 movimientos hoy.
```

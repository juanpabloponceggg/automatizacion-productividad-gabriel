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

Devuelve JSON con `resumen`, `usuarios` y `detalle` del día actual (hora Mérida).

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
📊 Reporte Diario — Seguimiento Inventario TD
📅 martes, 7 de julio de 2026

Resumen del día: 16 movimientos totales
• 10 altas · 4 ediciones · 2 asignaciones

👤 Gabriel Gonzalez — 15 movimiento(s)
   10 altas de equipos, 4 ediciones, 1 asignación

Detalle de movimientos:
🆕 GV-LAP-2026-0001 · alta · 12:22 · Gabriel Gonzalez
   → Abraham Ulises May Ruelas
...

> Hoy Gabriel Gonzalez registró 15 movimientos: 10 altas, 4 ediciones y 1 asignación.
```

# Automatización: Reporte Diario de Productividad — Inventario TD

Reporte automático de movimientos en la plataforma **Seguimiento Inventario TD**, enviado cada día a las **7:00 PM (hora Mérida)** a un canal de Microsoft Teams.

## Qué hace

1. Consulta todos los movimientos del día en Supabase (altas, ediciones, asignaciones)
2. Genera un resumen por usuario, destacando la actividad de **Gabriel Gonzalez**
3. Envía el reporte formateado al canal de Teams configurado

## Configuración en Cursor Automations

### Paso 1 — Crear la automatización

1. Abre [cursor.com/automations/new](https://cursor.com/automations/new)
2. Nombre sugerido: `Reporte diario inventario TD — Gabriel`
3. Repositorio: `juanpabloponceggg/automatizacion-productividad-gabriel`

### Paso 2 — Trigger programado

| Campo | Valor |
|-------|-------|
| Tipo | **Scheduled** |
| Cron | `0 1 * * *` |
| Zona horaria | UTC (7 PM Mérida = 01:00 UTC del día siguiente) |

> **Nota:** Mérida (`America/Merida`) es UTC-6 sin horario de verano. 7:00 PM local = 01:00 UTC.

### Paso 3 — Herramientas (Tools)

Habilita:
- **Supabase MCP** — para consultar la base de datos
- **Terminal / Shell** — para ejecutar `send-teams-report.sh`

### Paso 4 — Prompt

Copia el contenido completo de [`prompts/automation-prompt.md`](./prompts/automation-prompt.md) en el campo de instrucciones de la automatización.

### Paso 5 — Secreto: Webhook de Teams

1. En Teams, ve al canal destino → **Conectores** → **Incoming Webhook**
2. Crea un webhook y copia la URL
3. En la automatización de Cursor, agrega el secreto:
   - Nombre: `TEAMS_WEBHOOK_URL`
   - Valor: `https://outlook.office.com/webhook/...`

### Paso 6 — Activar

Guarda y activa la automatización. Puedes probarla manualmente con **Run now** antes de esperar las 7 PM.

---

## Configurar Incoming Webhook en Teams

1. Abre Microsoft Teams
2. Ve al canal donde quieres recibir el reporte (ej. `#inventario-ti`)
3. Click en **⋯** del canal → **Conectores** o **Workflows**
4. Busca **Incoming Webhook** → **Configurar**
5. Nombre: `Reporte Inventario TD`
6. Copia la URL generada → guárdala como `TEAMS_WEBHOOK_URL`

---

## Probar manualmente

### Consulta SQL directa

```sql
SELECT public.reporte_movimientos_diario();
```

### Enviar reporte de prueba

```bash
export TEAMS_WEBHOOK_URL="https://outlook.office.com/webhook/TU-URL"

./scripts/send-teams-report.sh "📊 Reporte de prueba — Seguimiento Inventario TD
Sin movimientos registrados hoy."
```

---

## Ejemplo de reporte

```
📊 Reporte Diario — Seguimiento Inventario TD
📅 martes, 7 de julio de 2026

Resumen del día: 15 movimientos totales
• 9 altas · 4 ediciones · 2 asignaciones

👤 Gabriel Gonzalez — 14 movimiento(s)
   9 altas de equipos, 4 ediciones, 1 asignaciones

👤 Samuel Renteria — 1 movimiento(s)
   1 asignaciones

Detalle de movimientos:

🆕 GV-LAP-2026-0001 · altas de equipos · 12:22 · Gabriel Gonzalez
   → Abraham Ulises May Ruelas
...
```

---

## Base de datos

| Recurso | Valor |
|---------|-------|
| Proyecto Supabase | Seguimiento inventario |
| Project ref | `avrvkghbypqisfpvdqgv` |
| Tabla principal | `movimiento` |
| Función de reporte | `public.reporte_movimientos_diario()` |
| Usuario auditado | Gabriel Gonzalez (`ggonzalezb@grupovive.mx`) |

### Tipos de movimiento

- `alta` — Alta de equipo nuevo en inventario
- `edicion` — Cambios en datos del activo (custodio, specs, etc.)
- `reasignacion` — Entrega/asignación con carta responsiva

---

## Alternativa: Power Automate

Si prefieres no depender del webhook directo, puedes usar **Power Automate**:

1. Trigger: **Recurrence** — Daily at 7:00 PM (Central Standard Time Mexico)
2. Action: **HTTP POST** a la URL del webhook de Cursor Automations
3. La automatización de Cursor genera el reporte y responde

O invertir el flujo: Power Automate llama a una Edge Function de Supabase que genera y envía el reporte (ver `sql/reporte_movimientos_diario.sql`).

---

## Archivos del repositorio

```
sql/
  reporte_movimientos_diario.sql   # Función SQL en Supabase
scripts/
  send-teams-report.sh             # Envío a Teams vía webhook
  format-report.ts                 # Formateador TypeScript (referencia)
prompts/
  automation-prompt.md             # Prompt para Cursor Automations
```

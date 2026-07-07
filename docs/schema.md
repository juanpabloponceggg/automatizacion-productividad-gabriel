# Esquema — Seguimiento Inventario TD

Proyecto Supabase: **Seguimiento inventario** (`avrvkghbypqisfpvdqgv`)

## Tablas relevantes para el reporte

### `movimiento`

Registro de cada acción en la plataforma.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | uuid | PK |
| `activo_id` | uuid | FK → `activo.id` |
| `tipo` | text | `alta`, `edicion`, `reasignacion` |
| `de_texto` | text | Valor anterior (texto legible) |
| `a_texto` | text | Valor nuevo (texto legible) |
| `motivo` | text | Descripción del movimiento |
| `realizado_por` | text | Nombre del usuario (texto) |
| `user_id` | uuid | FK → `usuario_perfil.id` |
| `es_demo` | boolean | Excluir del reporte si `true` |
| `created_at` | timestamptz | Fecha/hora del movimiento |

### `activo`

Equipos registrados en inventario.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | uuid | PK |
| `folio` | text | Identificador visible (ej. `GV-LAP-2026-0001`) |
| `estado` | text | Estado del activo |
| `custodio_id` | uuid | FK → `colaborador.id` |
| `created_at` | timestamptz | Fecha de alta |

### `usuario_perfil`

Usuarios de la plataforma.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | uuid | PK |
| `nombre` | text | Nombre completo |
| `correo` | text | Email |
| `rol` | text | `admin`, `gestor`, etc. |

## Función de reporte

```sql
public.reporte_movimientos_diario(
  p_fecha date DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'America/Merida')::date,
  p_zona text DEFAULT 'America/Merida'
) RETURNS jsonb
```

### Estructura del JSON retornado

```json
{
  "fecha": "2026-07-07",
  "zona_horaria": "America/Merida",
  "resumen": {
    "total_movimientos": 16,
    "total_altas": 10,
    "total_ediciones": 4,
    "total_reasignaciones": 2,
    "por_tipo": { "alta": 10, "edicion": 4, "reasignacion": 2 }
  },
  "usuarios": [
    {
      "nombre": "Gabriel Gonzalez",
      "correo": "ggonzalezb@grupovive.mx",
      "total": 15,
      "por_tipo": { "alta": 10, "edicion": 4, "reasignacion": 1 }
    }
  ],
  "detalle": [
    {
      "tipo": "alta",
      "activo_folio": "GV-LAP-2026-0001",
      "de": "—",
      "a": "Abraham Ulises May Ruelas",
      "motivo": "Alta de equipo nuevo en inventario",
      "usuario": "Gabriel Gonzalez",
      "hora": "12:22"
    }
  ]
}
```

## Usuario auditado

- **Nombre:** Gabriel Gonzalez
- **Correo:** ggonzalezb@grupovive.mx
- **Rol:** gestor
- **Función:** Dar alta de equipos y alimentar inventario Credivive

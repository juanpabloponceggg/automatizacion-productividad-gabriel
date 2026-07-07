-- Reporte diario de movimientos — Seguimiento Inventario TD
-- Proyecto Supabase: avrvkghbypqisfpvdqgv ("Seguimiento inventario")
--
-- Uso:
--   SELECT public.reporte_movimientos_diario();
--   SELECT public.reporte_movimientos_diario('2026-07-07'::date);

CREATE OR REPLACE FUNCTION public.reporte_movimientos_diario(
  p_fecha date DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'America/Merida')::date,
  p_zona text DEFAULT 'America/Merida'
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_inicio timestamptz;
  v_fin timestamptz;
  v_result jsonb;
BEGIN
  v_inicio := (p_fecha::timestamp AT TIME ZONE p_zona);
  v_fin := ((p_fecha + 1)::timestamp AT TIME ZONE p_zona);

  WITH movimientos_dia AS (
    SELECT
      m.id,
      m.tipo,
      m.de_texto,
      m.a_texto,
      m.motivo,
      m.realizado_por,
      m.created_at,
      COALESCE(up.nombre, m.realizado_por, 'Desconocido') AS usuario_nombre,
      up.correo AS usuario_correo,
      a.folio AS activo_folio
    FROM movimiento m
    LEFT JOIN usuario_perfil up ON m.user_id = up.id
    LEFT JOIN activo a ON m.activo_id = a.id
    WHERE m.created_at >= v_inicio
      AND m.created_at < v_fin
      AND m.es_demo = false
  ),
  resumen_tipo AS (
    SELECT tipo, COUNT(*) AS total
    FROM movimientos_dia
    GROUP BY tipo
  ),
  resumen_usuario AS (
    SELECT
      usuario_nombre,
      usuario_correo,
      SUM(cnt) AS total,
      jsonb_object_agg(tipo, cnt) AS por_tipo
    FROM (
      SELECT usuario_nombre, usuario_correo, tipo, COUNT(*) AS cnt
      FROM movimientos_dia
      GROUP BY usuario_nombre, usuario_correo, tipo
    ) sub
    GROUP BY usuario_nombre, usuario_correo
  )
  SELECT jsonb_build_object(
    'fecha', p_fecha,
    'zona_horaria', p_zona,
    'periodo', jsonb_build_object(
      'inicio', v_inicio,
      'fin', v_fin
    ),
    'resumen', jsonb_build_object(
      'total_movimientos', (SELECT COUNT(*) FROM movimientos_dia),
      'por_tipo', COALESCE(
        (SELECT jsonb_object_agg(tipo, total) FROM resumen_tipo),
        '{}'::jsonb
      ),
      'total_altas', COALESCE((SELECT total FROM resumen_tipo WHERE tipo = 'alta'), 0),
      'total_ediciones', COALESCE((SELECT total FROM resumen_tipo WHERE tipo = 'edicion'), 0),
      'total_reasignaciones', COALESCE((SELECT total FROM resumen_tipo WHERE tipo = 'reasignacion'), 0)
    ),
    'usuarios', COALESCE(
      (SELECT jsonb_agg(
        jsonb_build_object(
          'nombre', ru.usuario_nombre,
          'correo', ru.usuario_correo,
          'total', ru.total,
          'por_tipo', ru.por_tipo
        ) ORDER BY ru.total DESC
      ) FROM resumen_usuario ru),
      '[]'::jsonb
    ),
    'detalle', COALESCE(
      (SELECT jsonb_agg(
        jsonb_build_object(
          'tipo', md.tipo,
          'activo_folio', md.activo_folio,
          'de', md.de_texto,
          'a', md.a_texto,
          'motivo', md.motivo,
          'usuario', md.usuario_nombre,
          'hora', to_char(md.created_at AT TIME ZONE p_zona, 'HH24:MI')
        ) ORDER BY md.created_at
      ) FROM movimientos_dia md),
      '[]'::jsonb
    )
  ) INTO v_result;

  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION public.reporte_movimientos_diario IS
  'Genera reporte JSON de movimientos del día para automatización de productividad';

GRANT EXECUTE ON FUNCTION public.reporte_movimientos_diario TO authenticated, service_role;

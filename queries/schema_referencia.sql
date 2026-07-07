-- Tablas y columnas relevantes para el reporte diario

-- movimiento: registro de acciones
--   id, activo_id, tipo (alta|edicion|reasignacion), de_texto, a_texto,
--   motivo, realizado_por, user_id, es_demo, created_at

-- activo: equipos en inventario
--   id, folio, estado, custodio_id, created_at

-- usuario_perfil: usuarios de la plataforma
--   id, nombre, correo, rol

-- Función principal del reporte:
SELECT public.reporte_movimientos_diario();

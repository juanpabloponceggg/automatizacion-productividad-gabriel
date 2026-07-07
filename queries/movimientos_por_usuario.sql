-- Movimientos de hoy desglosados por usuario y tipo
-- Zona horaria: America/Merida

SELECT
  COALESCE(up.nombre, m.realizado_por, 'Desconocido') AS usuario,
  up.correo,
  m.tipo,
  COUNT(*) AS total
FROM movimiento m
LEFT JOIN usuario_perfil up ON m.user_id = up.id
WHERE m.created_at >= (CURRENT_TIMESTAMP AT TIME ZONE 'America/Merida')::date::timestamp AT TIME ZONE 'America/Merida'
  AND m.created_at < ((CURRENT_TIMESTAMP AT TIME ZONE 'America/Merida')::date + 1)::timestamp AT TIME ZONE 'America/Merida'
  AND m.es_demo = false
GROUP BY COALESCE(up.nombre, m.realizado_por, 'Desconocido'), up.correo, m.tipo
ORDER BY usuario, total DESC;

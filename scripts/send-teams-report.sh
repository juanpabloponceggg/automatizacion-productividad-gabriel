#!/usr/bin/env bash
# Envía el reporte diario a un canal de Microsoft Teams vía Incoming Webhook.
#
# Uso:
#   TEAMS_WEBHOOK_URL=https://... ./scripts/send-teams-report.sh "Mensaje del reporte"
#   echo "Mensaje" | ./scripts/send-teams-report.sh

set -euo pipefail

WEBHOOK_URL="${TEAMS_WEBHOOK_URL:-}"

if [[ -z "$WEBHOOK_URL" ]]; then
  echo "Error: define TEAMS_WEBHOOK_URL con la URL del Incoming Webhook de Teams." >&2
  exit 1
fi

if [[ $# -ge 1 ]]; then
  MESSAGE="$*"
else
  MESSAGE="$(cat)"
fi

if [[ -z "$MESSAGE" ]]; then
  echo "Error: no hay mensaje para enviar." >&2
  exit 1
fi

# Escapar comillas y saltos de línea para JSON
JSON_TEXT=$(python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))" <<< "$MESSAGE")

HTTP_CODE=$(curl -s -o /tmp/teams-response.txt -w "%{http_code}" \
  -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{\"text\": $JSON_TEXT}")

if [[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 300 ]]; then
  echo "Reporte enviado a Teams (HTTP $HTTP_CODE)"
else
  echo "Error al enviar a Teams (HTTP $HTTP_CODE):" >&2
  cat /tmp/teams-response.txt >&2
  exit 1
fi

/**
 * Formatea el JSON del reporte diario como mensaje legible para Microsoft Teams.
 */

export interface ReporteMovimientos {
  fecha: string;
  zona_horaria: string;
  resumen: {
    total_movimientos: number;
    total_altas: number;
    total_ediciones: number;
    total_reasignaciones: number;
    por_tipo: Record<string, number>;
  };
  usuarios: Array<{
    nombre: string;
    correo?: string;
    total: number;
    por_tipo: Record<string, number>;
  }>;
  detalle: Array<{
    tipo: string;
    activo_folio: string;
    de: string;
    a: string;
    motivo: string;
    usuario: string;
    hora: string;
  }>;
}

const TIPO_LABELS: Record<string, string> = {
  alta: "altas de equipos",
  edicion: "ediciones",
  reasignacion: "asignaciones",
};

const TIPO_EMOJI: Record<string, string> = {
  alta: "🆕",
  edicion: "✏️",
  reasignacion: "📋",
};

function formatFecha(fecha: string): string {
  const [year, month, day] = fecha.split("-").map(Number);
  const date = new Date(year, month - 1, day);
  return date.toLocaleDateString("es-MX", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

function formatTipoCounts(porTipo: Record<string, number>): string {
  return Object.entries(porTipo)
    .map(([tipo, count]) => `${count} ${TIPO_LABELS[tipo] ?? tipo}`)
    .join(", ");
}

export function formatReporteTeams(reporte: ReporteMovimientos): string {
  const lines: string[] = [];
  const fechaLegible = formatFecha(reporte.fecha);

  lines.push(`📊 **Reporte Diario — Seguimiento Inventario TD**`);
  lines.push(`📅 ${fechaLegible}`);
  lines.push("");

  const { resumen } = reporte;

  if (resumen.total_movimientos === 0) {
    lines.push("Sin movimientos registrados hoy en la plataforma.");
    return lines.join("\n");
  }

  lines.push(
    `**Resumen del día:** ${resumen.total_movimientos} movimientos totales`
  );
  lines.push(
    `• ${resumen.total_altas} altas · ${resumen.total_ediciones} ediciones · ${resumen.total_reasignaciones} asignaciones`
  );
  lines.push("");

  for (const usuario of reporte.usuarios) {
    lines.push(`👤 **${usuario.nombre}** — ${usuario.total} movimiento(s)`);
    lines.push(`   ${formatTipoCounts(usuario.por_tipo)}`);
    lines.push("");
  }

  lines.push("**Detalle de movimientos:**");
  lines.push("");

  for (const mov of reporte.detalle) {
    const emoji = TIPO_EMOJI[mov.tipo] ?? "•";
    const tipoLabel = TIPO_LABELS[mov.tipo] ?? mov.tipo;
    lines.push(
      `${emoji} \`${mov.activo_folio}\` · ${tipoLabel} · ${mov.hora} · ${mov.usuario}`
    );
    if (mov.tipo === "alta") {
      lines.push(`   → ${mov.a}`);
    } else if (mov.tipo === "reasignacion") {
      lines.push(`   ${mov.de} → ${mov.a}`);
    } else {
      lines.push(`   ${mov.motivo}`);
    }
  }

  lines.push("");
  lines.push("_Reporte generado automáticamente · Plataforma Seguimiento Inventario TD_");

  return lines.join("\n");
}

export function buildTeamsPayload(text: string) {
  return {
    type: "message",
    attachments: [
      {
        contentType: "application/vnd.microsoft.card.adaptive",
        content: {
          type: "AdaptiveCard",
          $schema: "http://adaptivecards.io/schemas/adaptive-card.json",
          version: "1.4",
          body: [
            {
              type: "TextBlock",
              text: text.replace(/\*\*/g, ""),
              wrap: true,
            },
          ],
        },
      },
    ],
  };
}

export function buildTeamsSimplePayload(text: string) {
  return { text: text.replace(/\*\*/g, "") };
}

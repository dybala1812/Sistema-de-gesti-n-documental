"use client";

import { Download } from "lucide-react";
import { Boton } from "@/components/ui/boton";
import { notificar } from "@/components/ui/notificaciones";
import { UNIVERSIDAD } from "@/lib/datos-demo";

/** El comprobante no incluye datos personales: solo número, trámite y fecha. */
export function BotonComprobante({ numero, tipo, fecha }: { numero: string; tipo: string; fecha: string }) {
  async function descargar() {
    try {
      const { jsPDF } = await import("jspdf");
      const doc = new jsPDF({ unit: "mm", format: "a5" });
      const ancho = doc.internal.pageSize.getWidth();

      doc.setFillColor(36, 59, 142);
      doc.rect(0, 0, ancho, 26, "F");
      doc.setTextColor(255, 255, 255);
      doc.setFont("helvetica", "bold");
      doc.setFontSize(12);
      doc.text("Sistema de Gestión Documental", 12, 12);
      doc.setFont("helvetica", "normal");
      doc.setFontSize(9);
      doc.text(UNIVERSIDAD, 12, 19);

      doc.setTextColor(30, 41, 59);
      doc.setFontSize(9);
      doc.text("COMPROBANTE DE RADICACIÓN", 12, 40);
      doc.setFont("helvetica", "bold");
      doc.setFontSize(24);
      doc.text(numero, 12, 54);
      doc.setDrawColor(244, 180, 0);
      doc.setLineWidth(1);
      doc.line(12, 59, 60, 59);

      doc.setFont("helvetica", "normal");
      doc.setFontSize(10);
      doc.text(`Tipo de trámite: ${tipo}`, 12, 72);
      doc.text(`Fecha de radicación: ${fecha}`, 12, 80);
      doc.setFontSize(9);
      doc.setTextColor(100, 116, 139);
      doc.text(
        doc.splitTextToSize(
          "La respuesta a esta solicitud se enviará únicamente al correo que registraste. Conserva este número para consultar el estado en el portal.",
          ancho - 24,
        ),
        12,
        96,
      );

      doc.save(`comprobante-${numero}.pdf`);
      notificar.exito("Comprobante descargado");
    } catch {
      notificar.error("No se pudo generar el PDF", "Anota el número de radicado mientras tanto.");
    }
  }

  return (
    <Boton tamano="lg" className="flex-1" onClick={descargar}>
      <Download aria-hidden />
      Descargar comprobante (PDF)
    </Boton>
  );
}

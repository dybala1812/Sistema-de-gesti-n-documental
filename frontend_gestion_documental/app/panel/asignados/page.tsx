"use client";

import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aviso } from "@/components/ui/bloques";
import { IndicadorSemaforo, InsigniaEstado } from "@/components/ui/insignia";
import { CeldaConsecutivo, TablaDatos } from "@/components/ui/tabla-datos";
import { RADICADOS } from "@/lib/datos-demo";
import type { Radicado } from "@/lib/tipos";

// En la demo, la dependencia del usuario es Facultad de Ingeniería. Con la API, el filtro lo hace el backend.
const DEPENDENCIA = "Facultad de Ingeniería";

function dias(r: Radicado) {
  if (r.estado === "En comité") return "En espera de comité";
  if (r.diasRestantes === null) return "—";
  return r.diasRestantes < 0 ? `${Math.abs(r.diasRestantes)} días de retraso` : `${r.diasRestantes} días`;
}

export default function Asignados() {
  const propios = [...RADICADOS.filter((r) => r.dependencia === DEPENDENCIA)].sort(
    (a, b) => (a.diasRestantes ?? 999) - (b.diasRestantes ?? 999),
  );

  return (
    <>
      <EncabezadoPantalla titulo="Radicados asignados" objetivo={`Bandeja de trabajo de ${DEPENDENCIA}, ordenada por fecha límite.`} />
      <Aviso className="mb-4">Cada dependencia ve únicamente sus propios radicados asignados.</Aviso>
      <TablaDatos
        filas={propios}
        clave={(r) => r.id}
        enlace={(r) => `/panel/radicados/${r.id}`}
        buscador="Buscar por consecutivo, cédula o nombre"
        textoBusqueda={(r) => `${r.numero} ${r.cedula} ${r.solicitante}`}
        filtros={[
          {
            etiqueta: "Estado",
            opciones: ["Pendiente", "En trámite", "En revisión", "En comité", "Por verificar", "Respondido", "Vencido"],
            valor: (r) => r.estado,
          },
        ]}
        sustantivo="radicados asignados"
        columnas={[
          { titulo: "Consecutivo", celda: (r) => <CeldaConsecutivo texto={r.numero} href={`/panel/radicados/${r.id}`} /> },
          { titulo: "Tipo de trámite", celda: (r) => r.tipoTramite, clase: "whitespace-nowrap" },
          { titulo: "Solicitante", celda: (r) => r.solicitante },
          { titulo: "Estado", celda: (r) => <InsigniaEstado estado={r.estado} /> },
          { titulo: "Plazo", celda: (r) => <IndicadorSemaforo semaforo={r.semaforo} detalle={dias(r)} /> },
        ]}
      />
    </>
  );
}

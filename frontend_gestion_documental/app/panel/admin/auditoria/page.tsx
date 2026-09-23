"use client";

import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { TablaDatos } from "@/components/ui/tabla-datos";
import { AUDITORIA } from "@/lib/datos-demo";

export default function Auditoria() {
  return (
    <>
      <EncabezadoPantalla
        titulo="Panel de auditoría"
        objetivo="Actividad reciente del sistema para control interno. Estos registros no se pueden editar ni borrar."
      />
      <TablaDatos
        filas={AUDITORIA}
        clave={(a) => `${a.cuando}-${a.detalle}`}
        buscador="Buscar en la auditoría"
        textoBusqueda={(a) => `${a.usuario} ${a.accion} ${a.detalle}`}
        filtros={[
          { etiqueta: "Usuario", opciones: [...new Set(AUDITORIA.map((a) => a.usuario))], valor: (a) => a.usuario },
          { etiqueta: "Tipo de acción", opciones: [...new Set(AUDITORIA.map((a) => a.accion))], valor: (a) => a.accion },
        ]}
        sustantivo="registros"
        columnas={[
          { titulo: "Fecha y hora", celda: (a) => a.cuando, clase: "whitespace-nowrap tabular-nums" },
          { titulo: "Usuario", celda: (a) => a.usuario },
          { titulo: "Acción", celda: (a) => a.accion },
          { titulo: "Detalle", celda: (a) => a.detalle },
        ]}
      />
    </>
  );
}

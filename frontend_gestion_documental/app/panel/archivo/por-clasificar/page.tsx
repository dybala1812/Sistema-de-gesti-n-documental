"use client";

import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { InsigniaEstado } from "@/components/ui/insignia";
import { CeldaConsecutivo, TablaDatos } from "@/components/ui/tabla-datos";
import { DEPENDENCIAS, POR_CLASIFICAR } from "@/lib/datos-demo";

export default function PorClasificar() {
  return (
    <>
      <EncabezadoPantalla
        titulo="Documentos por clasificar"
        objetivo="Documentos respondidos o cerrados que faltan por archivar formalmente."
      />
      <TablaDatos
        filas={POR_CLASIFICAR}
        clave={(d) => d.numero}
        enlace={(d) => (d.estado === "Por clasificar" ? `/panel/archivo/clasificar?doc=${d.numero}` : undefined)}
        buscador="Buscar por consecutivo"
        textoBusqueda={(d) => d.numero}
        filtros={[{ etiqueta: "Dependencia", opciones: DEPENDENCIAS, valor: (d) => d.dependencia }]}
        sustantivo="documentos"
        columnas={[
          { titulo: "Consecutivo", celda: (d) => <CeldaConsecutivo texto={d.numero} /> },
          { titulo: "Tipo", celda: (d) => d.tipo },
          { titulo: "Dependencia", celda: (d) => d.dependencia },
          { titulo: "Cerrado el", celda: (d) => d.cerrado, clase: "whitespace-nowrap" },
          { titulo: "Estado", celda: (d) => <InsigniaEstado estado={d.estado} /> },
        ]}
      />
    </>
  );
}

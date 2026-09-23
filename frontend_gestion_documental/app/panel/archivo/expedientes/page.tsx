"use client";

import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { CeldaConsecutivo, TablaDatos } from "@/components/ui/tabla-datos";
import { EXPEDIENTES, SERIES_TRD } from "@/lib/datos-demo";

export default function Expedientes() {
  return (
    <>
      <EncabezadoPantalla titulo="Consulta de expedientes" objetivo="Buscar y revisar expedientes ya clasificados." />
      <TablaDatos
        filas={EXPEDIENTES}
        clave={(x) => x.codigo}
        buscador="Buscar por persona, dependencia o serie"
        textoBusqueda={(x) => `${x.codigo} ${x.serie} ${x.titular}`}
        filtros={[{ etiqueta: "Serie documental", opciones: SERIES_TRD, valor: (x) => x.serie.split(" / ")[0] }]}
        sustantivo="expedientes"
        columnas={[
          { titulo: "Expediente", celda: (x) => <CeldaConsecutivo texto={x.codigo} /> },
          { titulo: "Serie / subserie", celda: (x) => x.serie },
          { titulo: "Titular o dependencia", celda: (x) => x.titular },
          { titulo: "Documentos", celda: (x) => x.documentos, clase: "tabular-nums" },
          { titulo: "Última actualización", celda: (x) => x.actualizado, clase: "whitespace-nowrap" },
        ]}
      />
    </>
  );
}

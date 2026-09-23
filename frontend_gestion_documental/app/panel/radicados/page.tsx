"use client";

import { FilePlus, Package } from "lucide-react";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { BotonEnlace } from "@/components/ui/boton";
import { InsigniaEstado } from "@/components/ui/insignia";
import { CeldaConsecutivo, TablaDatos } from "@/components/ui/tabla-datos";
import { DEPENDENCIAS, RADICADOS, TRAMITES_PORTAL } from "@/lib/datos-demo";

const ESTADOS = ["Radicado", "Pendiente", "En trámite", "En revisión", "En comité", "Por verificar", "Respondido", "Vencido", "Anulado"];

export default function BandejaRadicados() {
  return (
    <>
      <EncabezadoPantalla
        titulo="Bandeja de radicados"
        objetivo="Todo lo que ha entrado a la universidad y su estado."
        acciones={
          <>
            <BotonEnlace href="/panel/sin-consecutivo" variante="fantasma" tamano="sm">
              <Package aria-hidden />
              Registrar sin consecutivo
            </BotonEnlace>
            <BotonEnlace href="/panel/radicados/nuevo" tamano="sm">
              <FilePlus aria-hidden />
              Nueva radicación
            </BotonEnlace>
          </>
        }
      />
      <TablaDatos
        filas={RADICADOS}
        clave={(r) => r.id}
        enlace={(r) => `/panel/radicados/${r.id}`}
        buscador="Buscar por consecutivo, cédula o nombre"
        textoBusqueda={(r) => `${r.numero} ${r.cedula} ${r.solicitante}`}
        filtros={[
          { etiqueta: "Tipo de trámite", opciones: TRAMITES_PORTAL, valor: (r) => r.tipoTramite },
          { etiqueta: "Dependencia", opciones: DEPENDENCIAS, valor: (r) => r.dependencia },
          { etiqueta: "Estado", opciones: ESTADOS, valor: (r) => r.estado },
        ]}
        sustantivo="radicados"
        columnas={[
          { titulo: "Consecutivo", celda: (r) => <CeldaConsecutivo texto={r.numero} href={`/panel/radicados/${r.id}`} /> },
          { titulo: "Tipo", celda: (r) => r.tipoTramite, clase: "whitespace-nowrap" },
          { titulo: "Remitente", celda: (r) => r.solicitante },
          { titulo: "Dependencia", celda: (r) => r.dependencia },
          { titulo: "Estado", celda: (r) => <InsigniaEstado estado={r.estado} /> },
          { titulo: "Fecha", celda: (r) => r.fecha, clase: "whitespace-nowrap" },
        ]}
      />
    </>
  );
}

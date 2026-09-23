"use client";

import { Check, Pencil, Plus, X } from "lucide-react";
import { useState } from "react";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aviso } from "@/components/ui/bloques";
import { Boton } from "@/components/ui/boton";
import { notificar } from "@/components/ui/notificaciones";
import { TablaDatos } from "@/components/ui/tabla-datos";
import { TIPOS_TRAMITE } from "@/lib/datos-demo";
import type { TipoTramite } from "@/lib/tipos";

const PLAZO_MAXIMO = 15; // RN-010: derecho de petición.

function EditorPlazo({ tramite, alGuardar }: { tramite: TipoTramite; alGuardar: (t: TipoTramite) => void }) {
  const [editando, setEditando] = useState(false);
  const [plazo, setPlazo] = useState(String(tramite.plazoDiasHabiles));
  const [comite, setComite] = useState(tramite.requiereComite);

  function guardar() {
    const n = Number(plazo);
    if (!Number.isInteger(n) || n < 1 || n > PLAZO_MAXIMO) {
      notificar.error("Plazo no válido", `Debe ser un número entero entre 1 y ${PLAZO_MAXIMO} días hábiles (RN-010).`);
      return;
    }
    alGuardar({ ...tramite, plazoDiasHabiles: n, requiereComite: comite });
    setEditando(false);
    notificar.exito(`“${tramite.nombre}” actualizado`, "El nuevo plazo aplica a los radicados que entren desde ahora.");
  }

  if (!editando) {
    return (
      <Boton variante="fantasma" tamano="sm" onClick={() => setEditando(true)}>
        <Pencil aria-hidden />
        Editar
      </Boton>
    );
  }

  return (
    <div className="flex flex-wrap items-center gap-2">
      <label className="sr-only" htmlFor={`plazo-${tramite.nombre}`}>
        Plazo en días hábiles
      </label>
      <input
        id={`plazo-${tramite.nombre}`}
        type="number"
        min={1}
        max={PLAZO_MAXIMO}
        value={plazo}
        onChange={(e) => setPlazo(e.target.value)}
        className="w-16 border border-borde-campo px-2 py-1.5 text-[13px]"
      />
      <label className="flex items-center gap-1.5 text-xs">
        <input type="checkbox" checked={comite} onChange={(e) => setComite(e.target.checked)} className="accent-marca" />
        Comité
      </label>
      <Boton tamano="sm" onClick={guardar} aria-label="Guardar">
        <Check aria-hidden />
      </Boton>
      <Boton variante="secundario" tamano="sm" onClick={() => setEditando(false)} aria-label="Cancelar">
        <X aria-hidden />
      </Boton>
    </div>
  );
}

export default function TiposTramite() {
  const [tramites, setTramites] = useState(TIPOS_TRAMITE);

  function actualizar(t: TipoTramite) {
    setTramites((lista) => lista.map((x) => (x.nombre === t.nombre ? t : x)));
  }

  return (
    <>
      <EncabezadoPantalla
        titulo="Tipos de trámite y plazos"
        objetivo="Cuánto se demora y si requiere comité cada tipo de solicitud, sin tocar código."
        acciones={
          <Boton tamano="sm" onClick={() => notificar.info("Pendiente", "El alta de tipos se conecta con POST /api/v1/tramites.")}>
            <Plus aria-hidden />
            Agregar tipo de trámite
          </Boton>
        }
      />
      <Aviso className="mb-4 max-w-[940px]">
        Ningún plazo supera {PLAZO_MAXIMO} días hábiles (RN-010). Cambiar un plazo no modifica la fecha límite de los radicados que ya
        existen.
      </Aviso>
      <TablaDatos
        filas={tramites}
        clave={(t) => t.nombre}
        buscador="Buscar tipo de trámite"
        textoBusqueda={(t) => t.nombre}
        sustantivo="tipos de trámite"
        columnas={[
          { titulo: "Tipo de trámite", celda: (t) => <span className="font-semibold">{t.nombre}</span> },
          { titulo: "Plazo (días hábiles)", celda: (t) => t.plazoDiasHabiles, clase: "tabular-nums" },
          { titulo: "Requiere comité", celda: (t) => (t.requiereComite ? "Sí" : "No") },
          { titulo: "Acción", celda: (t) => <EditorPlazo tramite={t} alGuardar={actualizar} /> },
        ]}
      />
    </>
  );
}

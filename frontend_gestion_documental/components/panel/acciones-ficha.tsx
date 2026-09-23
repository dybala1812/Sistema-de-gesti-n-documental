"use client";

import { Ban, ClipboardCheck, Reply, Share2 } from "lucide-react";
import { useState } from "react";
import { Boton, BotonEnlace } from "@/components/ui/boton";
import { Campo, Seleccion } from "@/components/ui/campos";
import { DialogoConfirmar } from "@/components/ui/dialogo";
import { notificar } from "@/components/ui/notificaciones";
import { DEPENDENCIAS } from "@/lib/datos-demo";
import type { Radicado, Rol } from "@/lib/tipos";
import { useRolDemo } from "./sesion-demo";

const CERRADOS = ["Respondido", "Anulado"];

const BANDEJA: Record<Rol, string> = {
  recepcion: "/panel/radicados",
  dependencia: "/panel/asignados",
  archivo_central: "/panel",
  administrador: "/panel",
};

export function AccionesFicha({ radicado }: { radicado: Radicado }) {
  const rol = useRolDemo();
  const [destino, setDestino] = useState(DEPENDENCIAS.find((d) => d !== radicado.dependencia) ?? DEPENDENCIAS[0]);
  const cerrado = CERRADOS.includes(radicado.estado);

  return (
    <div className="flex flex-wrap gap-2">
      {rol === "recepcion" && !cerrado && (
        <DialogoConfirmar
          titulo="Reasignar radicado"
          descripcion={`${radicado.numero} está asignado a ${radicado.dependencia}. El cambio queda en la trazabilidad.`}
          textoConfirmar="Reasignar"
          pedirMotivo
          alConfirmar={() => notificar.exito("Radicado reasignado", `Enviado a ${destino}. Se notificó a la dependencia.`)}
          disparador={
            <Boton>
              <Share2 aria-hidden />
              Reasignar a otra dependencia
            </Boton>
          }
        >
          <Campo etiqueta="Nueva dependencia" htmlFor="destino" className="mb-4">
            <Seleccion
              id="destino"
              value={destino}
              onChange={(e) => setDestino(e.target.value)}
              opciones={DEPENDENCIAS.filter((d) => d !== radicado.dependencia)}
            />
          </Campo>
        </DialogoConfirmar>
      )}

      {rol === "dependencia" && !cerrado && (
        <>
          <BotonEnlace href={`/panel/radicados/${radicado.id}/responder`}>
            <Reply aria-hidden />
            Responder
          </BotonEnlace>
          {radicado.requiereComite && (
            <BotonEnlace href={`/panel/radicados/${radicado.id}/comite`} variante="contorno">
              <ClipboardCheck aria-hidden />
              Flujo de comité
            </BotonEnlace>
          )}
        </>
      )}

      {rol === "administrador" && radicado.estado !== "Anulado" && (
        <DialogoConfirmar
          titulo={`Anular ${radicado.numero}`}
          descripcion="El documento no se borra: queda con estado “Anulado”, visible en consultas y sin poder editarse (RN-002)."
          textoConfirmar="Anular documento"
          peligroso
          pedirMotivo
          alConfirmar={(motivo) => notificar.aviso("Documento anulado", `Motivo registrado: ${motivo}`)}
          disparador={
            <Boton variante="peligro">
              <Ban aria-hidden />
              Anular
            </Boton>
          }
        />
      )}

      <BotonEnlace href={BANDEJA[rol]} variante="secundario">
        {rol === "recepcion" || rol === "dependencia" ? "Volver a la bandeja" : "Volver al inicio"}
      </BotonEnlace>
    </div>
  );
}

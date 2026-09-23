"use client";

import { CalendarDays, Check, Gavel, X } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Aviso } from "@/components/ui/bloques";
import { Boton } from "@/components/ui/boton";
import { Campo, Entrada, Seleccion } from "@/components/ui/campos";
import { DialogoConfirmar } from "@/components/ui/dialogo";
import { notificar } from "@/components/ui/notificaciones";
import type { Radicado } from "@/lib/tipos";
import { cn } from "@/lib/utils";

type Etapa = "revision" | "comite" | "rechazado";

const PASOS: { id: Etapa | "decidido"; etiqueta: string }[] = [
  { id: "revision", etiqueta: "En revisión de requisitos" },
  { id: "comite", etiqueta: "En comité" },
  { id: "decidido", etiqueta: "Decidido" },
];

export function FlujoComite({ radicado }: { radicado: Radicado }) {
  const router = useRouter();
  const [etapa, setEtapa] = useState<Etapa>(radicado.estado === "En comité" ? "comite" : "revision");
  const [decision, setDecision] = useState("Aprobado");
  const indice = etapa === "comite" ? 1 : 0;

  return (
    <section className="max-w-[780px] border border-borde bg-fondo px-5 py-7 sm:px-8">
      <div className="mb-6 flex flex-wrap items-center gap-3">
        <p className="font-display text-xl font-extrabold text-marca tabular-nums">{radicado.numero}</p>
        <span className="text-xs text-tinta-suave">
          {radicado.tipoTramite} · {radicado.solicitante}
        </span>
      </div>

      <ol className="mb-6 grid grid-cols-3" aria-label="Etapas del comité">
        {PASOS.map((p, i) => {
          const activo = etapa !== "rechazado" && i === indice;
          const hecho = etapa !== "rechazado" && i < indice;
          return (
            <li
              key={p.id}
              aria-current={activo ? "step" : undefined}
              className={cn(
                "border px-2 py-3 text-center font-display text-xs transition-colors duration-300",
                activo && "border-acento bg-acento font-bold text-sobre-acento",
                hecho && "border-acento bg-acento-claro font-semibold text-acento-texto",
                !activo && !hecho && "border-tinta/20 bg-fondo-alt text-tinta-suave",
              )}
            >
              {p.etiqueta}
            </li>
          );
        })}
      </ol>

      {etapa === "rechazado" ? (
        <Aviso tono="peligro" className="mb-6">
          Rechazado por requisitos incompletos, sin pasar por comité. Genera la respuesta para informar al solicitante qué le
          falta.
        </Aviso>
      ) : (
        <Aviso tono="acento" icono={CalendarDays} className="mb-6">
          Próxima reunión del comité: <strong>18 de septiembre de 2026</strong> (estimada). Mientras tanto, la alerta de
          vencimiento indica que el retraso corresponde al comité y no a la dependencia.
        </Aviso>
      )}

      <div className="flex flex-wrap gap-2">
        {etapa === "revision" && (
          <>
            <Boton
              onClick={() => {
                setEtapa("comite");
                notificar.exito("Pasa a comité", "El cambio quedó en la trazabilidad.");
              }}
            >
              <Check aria-hidden />
              Cumple requisitos, pasa a comité
            </Boton>
            <DialogoConfirmar
              titulo="No cumple requisitos"
              descripcion="El radicado pasa a “rechazado por requisitos incompletos” sin ir a comité."
              textoConfirmar="Confirmar rechazo"
              peligroso
              pedirMotivo
              alConfirmar={() => {
                setEtapa("rechazado");
                notificar.aviso("Rechazado por requisitos", "Ahora genera la respuesta al solicitante.");
              }}
              disparador={
                <Boton variante="secundario">
                  <X aria-hidden />
                  No cumple requisitos
                </Boton>
              }
            />
          </>
        )}

        {etapa === "comite" && (
          <DialogoConfirmar
            titulo="Registrar decisión del comité"
            descripcion="La decisión se precarga en el formulario de respuesta."
            textoConfirmar="Registrar y responder"
            alConfirmar={() => router.push(`/panel/radicados/${radicado.id}/responder?decision=${encodeURIComponent(decision)}`)}
            disparador={
              <Boton variante="contorno">
                <Gavel aria-hidden />
                Registrar decisión del comité
              </Boton>
            }
          >
            <div className="mb-5 grid gap-4 sm:grid-cols-2">
              <Campo etiqueta="Decisión" htmlFor="decision">
                <Seleccion id="decision" value={decision} onChange={(e) => setDecision(e.target.value)} opciones={["Aprobado", "No aprobado"]} />
              </Campo>
              <Campo etiqueta="Fecha de la sesión" htmlFor="sesion">
                <Entrada id="sesion" type="date" defaultValue="2026-09-18" />
              </Campo>
            </div>
          </DialogoConfirmar>
        )}

        {etapa === "rechazado" && (
          <Boton onClick={() => router.push(`/panel/radicados/${radicado.id}/responder?decision=Rechazado por requisitos incompletos`)}>
            Generar respuesta
          </Boton>
        )}
      </div>
    </section>
  );
}

"use client";

import { CheckCheck, MailCheck, Undo2 } from "lucide-react";
import { useState } from "react";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aparecer } from "@/components/ui/aparecer";
import { EstadoVacio } from "@/components/ui/bloques";
import { Boton, BotonEnlace } from "@/components/ui/boton";
import { DialogoConfirmar } from "@/components/ui/dialogo";
import { notificar } from "@/components/ui/notificaciones";
import { RADICADOS } from "@/lib/datos-demo";

export default function Verificacion() {
  const [pendientes, setPendientes] = useState(RADICADOS.filter((r) => r.estado === "Por verificar"));

  function quitar(id: string) {
    setPendientes((p) => p.filter((r) => r.id !== id));
  }

  return (
    <>
      <EncabezadoPantalla
        titulo="Respuestas por verificar"
        objetivo="Recepción revisa cada respuesta antes de que se notifique al solicitante (RN-008)."
      />
      {pendientes.length === 0 ? (
        <EstadoVacio icono={MailCheck} titulo="No hay respuestas por verificar" descripcion="Cuando una dependencia responda, aparecerá aquí." />
      ) : (
        <Aparecer como="ul" className="flex max-w-[940px] flex-col gap-3">
          {pendientes.map((r) => (
            <li key={r.id} data-aparecer className="border border-borde bg-fondo px-5 py-4">
              <div className="mb-3 flex flex-wrap items-center gap-x-4 gap-y-1">
                <span className="font-display text-sm font-bold tabular-nums">{r.numero}</span>
                <span className="text-[13px] text-tinta">
                  {r.tipoTramite} <span className="text-tinta-suave">· {r.dependencia} · {r.solicitante}</span>
                </span>
              </div>
              <p className="mb-4 border-l-2 border-borde pl-3 text-[13px] leading-relaxed text-tinta-suave">
                “Se aprueba la homologación de las asignaturas solicitadas según el acta del consejo de facultad…”
              </p>
              <div className="flex flex-wrap gap-2">
                <Boton
                  tamano="sm"
                  onClick={() => {
                    quitar(r.id);
                    notificar.exito("Respuesta verificada", "Se notificará al solicitante por correo.");
                  }}
                >
                  <CheckCheck aria-hidden />
                  Verificar y notificar
                </Boton>
                <DialogoConfirmar
                  titulo="Devolver a la dependencia"
                  descripcion="La respuesta vuelve a la dependencia con estado “requiere corrección”. El solicitante no recibe nada."
                  textoConfirmar="Devolver"
                  pedirMotivo
                  alConfirmar={() => {
                    quitar(r.id);
                    notificar.aviso("Respuesta devuelta", `${r.dependencia} verá tu observación.`);
                  }}
                  disparador={
                    <Boton variante="secundario" tamano="sm">
                      <Undo2 aria-hidden />
                      Devolver con observación
                    </Boton>
                  }
                />
                <BotonEnlace href={`/panel/radicados/${r.id}`} variante="fantasma" tamano="sm">
                  Ver ficha
                </BotonEnlace>
              </div>
            </li>
          ))}
        </Aparecer>
      )}
    </>
  );
}

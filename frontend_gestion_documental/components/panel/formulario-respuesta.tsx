"use client";

import { Info, Send } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { Aviso } from "@/components/ui/bloques";
import { Boton, BotonEnlace } from "@/components/ui/boton";
import { AreaTexto, Campo, Entrada, Seleccion } from "@/components/ui/campos";
import { notificar } from "@/components/ui/notificaciones";
import { ZonaArchivos } from "@/components/ui/zona-archivos";
import type { Radicado } from "@/lib/tipos";

export function FormularioRespuesta({ radicado, decision }: { radicado: Radicado; decision?: string }) {
  const router = useRouter();
  const [error, setError] = useState("");

  function enviar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const texto = String(new FormData(e.currentTarget).get("observaciones") ?? "");
    if (texto.trim().length < 10) {
      setError("Escribe la respuesta o las observaciones (mínimo 10 caracteres).");
      return;
    }
    notificar.exito("Respuesta registrada", "Pasa a Recepción para verificación antes de notificar al solicitante.");
    router.push("/panel/asignados");
  }

  return (
    <form onSubmit={enviar} noValidate className="max-w-[740px] border border-borde bg-fondo px-5 py-7 sm:px-8">
      <Aviso icono={Info} className="mb-6">
        Al enviar, la respuesta queda relacionada con el radicado y pasa a <strong>verificación de Recepción</strong>. Solo
        cuando Recepción la verifica se envía copia a Registro Académico y al solicitante (RN-008).
      </Aviso>
      <div className="grid gap-5 sm:grid-cols-2">
        <Campo etiqueta="Radicado" htmlFor="radicado">
          <Entrada id="radicado" readOnly value={`${radicado.numero} · ${radicado.tipoTramite}`} />
        </Campo>
        <Campo etiqueta="Sentido de la respuesta" htmlFor="sentido">
          <Seleccion
            id="sentido"
            name="sentido"
            defaultValue={decision}
            opciones={["Aprobado", "No aprobado", "Informativa", "Rechazado por requisitos incompletos"]}
          />
        </Campo>
        <Campo etiqueta="Destinatario" htmlFor="destinatario" className="sm:col-span-2">
          <Entrada id="destinatario" readOnly value={`${radicado.solicitante} · correo registrado`} />
        </Campo>
        <div className="sm:col-span-2">
          <ZonaArchivos etiqueta="Documento de respuesta" multiple={false} ayuda="PDF firmado de la respuesta" />
        </div>
        <Campo etiqueta="Respuesta u observaciones" htmlFor="observaciones" error={error} className="sm:col-span-2">
          <AreaTexto id="observaciones" name="observaciones" placeholder="Texto de la respuesta o aclaraciones para el solicitante" />
        </Campo>
      </div>
      <div className="mt-7 flex flex-wrap gap-2 border-t border-borde pt-5">
        <Boton type="submit">
          <Send aria-hidden />
          Enviar respuesta
        </Boton>
        <BotonEnlace href={`/panel/radicados/${radicado.id}`} variante="secundario">
          Cancelar
        </BotonEnlace>
      </div>
    </form>
  );
}

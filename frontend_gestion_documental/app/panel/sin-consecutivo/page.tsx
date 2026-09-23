"use client";

import { Info, PackageCheck, Stamp } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aparecer } from "@/components/ui/aparecer";
import { Aviso } from "@/components/ui/bloques";
import { Boton, BotonEnlace } from "@/components/ui/boton";
import { AreaTexto, Campo, Entrada, Seleccion } from "@/components/ui/campos";
import { notificar } from "@/components/ui/notificaciones";
import { DEPENDENCIAS, TIPOS_ELEMENTO } from "@/lib/datos-demo";

export default function SinConsecutivo() {
  const router = useRouter();
  const [fecha] = useState(() =>
    new Intl.DateTimeFormat("es-CO", { dateStyle: "medium", timeStyle: "short", timeZone: "America/Bogota" }).format(new Date()),
  );

  function guardar(e: FormEvent) {
    e.preventDefault();
    notificar.exito("Constancia guardada", "No se usó ningún consecutivo de radicado.");
    router.push("/panel/radicados");
  }

  return (
    <>
      <EncabezadoPantalla
        titulo="Registro sin consecutivo"
        objetivo="Constancia de entrega de revistas, facturas, paquetes o documentos sin firma."
      />
      <Aparecer>
        <form onSubmit={guardar} className="max-w-[740px] border border-borde bg-fondo px-5 py-7 sm:px-8">
          <Aviso icono={Info} className="mb-6">
            Esta constancia no genera consecutivo ni plazo de respuesta (RN-006).
          </Aviso>
          <div className="grid gap-5 sm:grid-cols-2">
            <Campo etiqueta="Fecha y hora" htmlFor="fecha">
              <Entrada id="fecha" defaultValue={fecha} />
            </Campo>
            <Campo etiqueta="Tipo de elemento" htmlFor="elemento">
              <Seleccion id="elemento" opciones={TIPOS_ELEMENTO} />
            </Campo>
            <Campo etiqueta="Remitente (si se conoce)" htmlFor="remitente">
              <Entrada id="remitente" placeholder="Opcional" />
            </Campo>
            <Campo etiqueta="Dependencia destinataria" htmlFor="dependencia">
              <Seleccion id="dependencia" opciones={DEPENDENCIAS} defaultValue="Biblioteca" />
            </Campo>
            <Campo etiqueta="Observaciones" htmlFor="observaciones" className="sm:col-span-2">
              <AreaTexto id="observaciones" placeholder="Detalle de lo entregado" />
            </Campo>
          </div>
          <div className="mt-7 flex flex-wrap gap-2 border-t border-borde pt-5">
            <Boton type="submit">
              <PackageCheck aria-hidden />
              Guardar constancia
            </Boton>
            <BotonEnlace href="/panel/radicados/nuevo" variante="secundario">
              <Stamp aria-hidden />
              En realidad esto sí debe radicarse
            </BotonEnlace>
          </div>
        </form>
      </Aparecer>
    </>
  );
}

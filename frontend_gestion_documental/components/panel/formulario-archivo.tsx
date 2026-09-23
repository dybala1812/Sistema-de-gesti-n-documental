"use client";

import { FolderCheck, Info } from "lucide-react";
import { useRouter } from "next/navigation";
import type { FormEvent, ReactNode } from "react";
import { Aviso } from "@/components/ui/bloques";
import { Boton, BotonEnlace } from "@/components/ui/boton";
import { AreaTexto, Campo, Seleccion } from "@/components/ui/campos";
import { notificar } from "@/components/ui/notificaciones";
import { EXPEDIENTES, SERIES_TRD } from "@/lib/datos-demo";

/** Campos TRD comunes a "Clasificación de expediente" y "Digitalizar documentos físicos". */
export function FormularioArchivo({
  nota,
  textoGuardar,
  mensajeExito,
  volver,
  children,
}: {
  nota: string;
  textoGuardar: string;
  mensajeExito: string;
  volver: string;
  children?: ReactNode;
}) {
  const router = useRouter();

  function guardar(e: FormEvent) {
    e.preventDefault();
    notificar.exito(mensajeExito, "El documento quedó vinculado al expediente.");
    router.push("/panel/archivo/expedientes");
  }

  return (
    <form onSubmit={guardar} className="max-w-[740px] border border-borde bg-fondo px-5 py-7 sm:px-8">
      <Aviso icono={Info} className="mb-6">
        {nota}
      </Aviso>
      <div className="grid gap-5 sm:grid-cols-2">
        {children}
        <Campo etiqueta="Serie documental (TRD)" htmlFor="serie">
          <Seleccion id="serie" opciones={SERIES_TRD} />
        </Campo>
        <Campo etiqueta="Subserie documental" htmlFor="subserie">
          <Seleccion id="subserie" opciones={["Acciones de tutela", "Homologaciones", "Interinstitucionales", "Reintegros"]} />
        </Campo>
        <Campo etiqueta="Expediente" htmlFor="expediente" ayuda="O crea uno nuevo si no existe." className="sm:col-span-2">
          <Seleccion
            id="expediente"
            opciones={["Crear expediente nuevo…", ...EXPEDIENTES.map((x) => `${x.codigo} · ${x.titular}`)]}
          />
        </Campo>
        <Campo etiqueta="Observaciones de archivo" htmlFor="obs-archivo" className="sm:col-span-2">
          <AreaTexto id="obs-archivo" rows={3} placeholder="Opcional" />
        </Campo>
      </div>
      <p className="mt-4 text-[11px] text-tinta-suave">
        Series y subseries de ejemplo: la TRD vigente y la definición de expediente están pendientes con Archivo Central (P-07).
      </p>
      <div className="mt-6 flex flex-wrap gap-2 border-t border-borde pt-5">
        <Boton type="submit">
          <FolderCheck aria-hidden />
          {textoGuardar}
        </Boton>
        <BotonEnlace href={volver} variante="secundario">
          Cancelar
        </BotonEnlace>
      </div>
    </form>
  );
}

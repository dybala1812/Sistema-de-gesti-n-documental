import { Mail, RotateCcw } from "lucide-react";
import type { Metadata } from "next";
import { BotonComprobante } from "@/components/publico/comprobante-pdf";
import { Progreso } from "@/components/publico/progreso";
import { SelloExito } from "@/components/publico/sello-exito";
import { Antetitulo, Aviso } from "@/components/ui/bloques";
import { BotonEnlace } from "@/components/ui/boton";

export const metadata: Metadata = { title: "Solicitud radicada" };

function texto(valor: string | string[] | undefined, porDefecto: string) {
  return typeof valor === "string" && valor.trim() ? valor : porDefecto;
}

export default async function Confirmacion({ searchParams }: PageProps<"/radicar/confirmacion">) {
  const params = await searchParams;
  const numero = texto(params.n, "2026-CR-01488");
  const tipo = texto(params.t, "Solicitud");
  const fecha = new Intl.DateTimeFormat("es-CO", {
    dateStyle: "long",
    timeStyle: "short",
    timeZone: "America/Bogota",
  }).format(new Date());

  return (
    <div className="mx-auto max-w-[720px] px-4 pt-10 pb-18 sm:px-6">
      <Progreso paso={3} />
      <section className="border border-borde bg-fondo px-5 py-8 sm:px-8">
        <SelloExito />
        <Antetitulo className="mb-3.5 text-info">Solicitud radicada</Antetitulo>
        <h1 className="mb-2 font-display text-[26px] font-extrabold tracking-tight text-marca">Tu solicitud quedó registrada</h1>
        <p className="mb-6 text-sm text-tinta-suave">Guarda este número para cualquier consulta.</p>

        <div className="mb-5 bg-tinta-profunda px-6 py-6">
          <p className="mb-2 font-display text-[11px] font-bold tracking-[0.14em] text-slate-300 uppercase">
            Número de radicado
          </p>
          <p className="font-display text-3xl font-extrabold tracking-tight text-[#ffc526] tabular-nums sm:text-[34px]">
            {numero}
          </p>
          <p className="mt-2 text-[13px] text-slate-300">
            {tipo} · {fecha}
          </p>
        </div>

        <Aviso icono={Mail} className="mb-7">
          Tu respuesta llegará al correo que registraste. No es necesario que vuelvas al portal, pero puedes consultar el
          estado con tu número de radicado y tu cédula.
        </Aviso>

        <div className="flex flex-wrap gap-2.5">
          <BotonComprobante numero={numero} tipo={tipo} fecha={fecha} />
          <BotonEnlace href="/radicar" variante="secundario" tamano="lg">
            <RotateCcw aria-hidden />
            Radicar otra
          </BotonEnlace>
        </div>
      </section>
    </div>
  );
}

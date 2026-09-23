import { Clock, Download, FileText } from "lucide-react";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { AccionesFicha } from "@/components/panel/acciones-ficha";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aparecer } from "@/components/ui/aparecer";
import { Aviso, Dato } from "@/components/ui/bloques";
import { Boton } from "@/components/ui/boton";
import { IndicadorSemaforo, InsigniaEstado } from "@/components/ui/insignia";
import { LineaTiempo } from "@/components/ui/linea-tiempo";
import { buscarRadicado, TIPOS_TRAMITE, TRAZABILIDAD } from "@/lib/datos-demo";

export async function generateMetadata({ params }: PageProps<"/panel/radicados/[id]">): Promise<Metadata> {
  const { id } = await params;
  return { title: `Radicado ${decodeURIComponent(id)}` };
}

export default async function FichaRadicado({ params }: PageProps<"/panel/radicados/[id]">) {
  const { id } = await params;
  const radicado = buscarRadicado(decodeURIComponent(id));
  if (!radicado) notFound();

  const plazo = TIPOS_TRAMITE.find((t) => t.nombre === radicado.tipoTramite)?.plazoDiasHabiles ?? 15;
  const dias = radicado.diasRestantes;

  return (
    <>
      <EncabezadoPantalla titulo="Ficha de radicado" objetivo="Detalle completo y trazabilidad del radicado." />
      <div className="grid items-start gap-5 lg:grid-cols-[1.35fr_1fr]">
        <Aparecer className="border border-borde bg-fondo px-5 py-6 sm:px-7">
          <div data-aparecer className="mb-5 flex flex-wrap items-center gap-3">
            <p className="font-display text-[22px] font-extrabold tracking-tight text-marca tabular-nums">{radicado.numero}</p>
            <InsigniaEstado estado={radicado.estado} />
            <span className="ml-auto">
              <IndicadorSemaforo semaforo={radicado.semaforo} />
            </span>
          </div>

          <dl data-aparecer className="mb-6 grid gap-x-5 gap-y-4 sm:grid-cols-2">
            <Dato etiqueta="Tipo de trámite">{radicado.tipoTramite}</Dato>
            <Dato etiqueta="Solicitante">
              {radicado.solicitante} · {radicado.cedula}
            </Dato>
            <Dato etiqueta="Dependencia asignada">{radicado.dependencia}</Dato>
            <Dato etiqueta="Radicado el">{radicado.fecha}</Dato>
          </dl>

          {dias !== null && (
            <div data-aparecer>
              <Aviso tono={dias < 0 ? "peligro" : "acento"} icono={Clock} className="mb-5">
                <strong className="font-display font-semibold">Plazo de respuesta:</strong> {plazo} días hábiles ·{" "}
                <strong>{dias < 0 ? `${Math.abs(dias)} días de retraso` : `quedan ${dias} días`}</strong>
                {radicado.estado === "En comité" && " · el retraso corresponde a la espera del comité"}
              </Aviso>
            </div>
          )}

          <div data-aparecer className="mb-6 flex flex-wrap items-center justify-between gap-3 border border-borde px-4 py-3 text-[13px]">
            <span className="inline-flex items-center gap-2.5">
              <FileText className="size-4 text-tinta-suave" aria-hidden />
              {radicado.adjunto ? `${radicado.adjunto.nombre} · ${radicado.adjunto.tamano}` : "documento-radicado.pdf · 1,1 MB"}
            </span>
            <Boton variante="secundario" tamano="sm">
              <Download aria-hidden />
              Descargar
            </Boton>
          </div>

          <div data-aparecer>
            <AccionesFicha radicado={radicado} />
          </div>
        </Aparecer>

        <Aparecer retardo={0.1}>
          <LineaTiempo eventos={TRAZABILIDAD} />
        </Aparecer>
      </div>
    </>
  );
}
